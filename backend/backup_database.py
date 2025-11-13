#!/usr/bin/env python3
"""
Database Backup Script for Production
Backs up SQLite database to Google Cloud Storage
"""

import os
import sys
import shutil
from datetime import datetime
import subprocess

def backup_database():
    """Create database backup and upload to Google Cloud Storage"""
    
    print("💾 Starting database backup...")
    
    # Configuration
    DB_PATH = os.environ.get('DATABASE_PATH', 'app.db')
    BACKUP_DIR = os.environ.get('BACKUP_DIR', 'backups')
    GCS_BUCKET = os.environ.get('GCS_BACKUP_BUCKET', 'ustam-backups')
    
    # Create backup directory if it doesn't exist
    os.makedirs(BACKUP_DIR, exist_ok=True)
    
    # Generate backup filename with timestamp
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_filename = f'ustam_db_backup_{timestamp}.db'
    backup_path = os.path.join(BACKUP_DIR, backup_filename)
    
    try:
        # Check if database exists
        if not os.path.exists(DB_PATH):
            print(f"❌ Database not found: {DB_PATH}")
            return False
        
        # Copy database file
        print(f"📁 Copying database: {DB_PATH} -> {backup_path}")
        shutil.copy2(DB_PATH, backup_path)
        
        # Get file size
        file_size = os.path.getsize(backup_path)
        file_size_mb = file_size / (1024 * 1024)
        print(f"✅ Backup created: {backup_filename} ({file_size_mb:.2f} MB)")
        
        # Upload to Google Cloud Storage (if configured)
        if GCS_BUCKET and GCS_BUCKET != 'ustam-backups':
            print(f"\n☁️  Uploading to Google Cloud Storage: gs://{GCS_BUCKET}/")
            try:
                gcs_path = f'gs://{GCS_BUCKET}/database-backups/{backup_filename}'
                result = subprocess.run(
                    ['gsutil', 'cp', backup_path, gcs_path],
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    print(f"✅ Uploaded to: {gcs_path}")
                else:
                    print(f"⚠️  Upload failed: {result.stderr}")
                    print("   Backup saved locally only")
            except FileNotFoundError:
                print("⚠️  gsutil not found. Install Google Cloud SDK to enable cloud backups.")
                print("   Backup saved locally only")
        
        # Clean up old local backups (keep last 7 days)
        print("\n🧹 Cleaning up old backups...")
        cleanup_old_backups(BACKUP_DIR, days=7)
        
        print("\n✅ Backup completed successfully!")
        print(f"   Local backup: {backup_path}")
        return True
        
    except Exception as e:
        print(f"❌ Backup failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def cleanup_old_backups(backup_dir, days=7):
    """Remove backups older than specified days"""
    import time
    
    current_time = time.time()
    max_age = days * 24 * 60 * 60  # Convert days to seconds
    
    removed_count = 0
    total_size = 0
    
    for filename in os.listdir(backup_dir):
        if filename.startswith('ustam_db_backup_') and filename.endswith('.db'):
            filepath = os.path.join(backup_dir, filename)
            file_age = current_time - os.path.getmtime(filepath)
            
            if file_age > max_age:
                file_size = os.path.getsize(filepath)
                os.remove(filepath)
                removed_count += 1
                total_size += file_size
                print(f"  🗑️  Removed old backup: {filename}")
    
    if removed_count > 0:
        total_size_mb = total_size / (1024 * 1024)
        print(f"✅ Cleaned up {removed_count} old backups ({total_size_mb:.2f} MB freed)")
    else:
        print("ℹ️  No old backups to clean up")

def setup_cron_job():
    """Instructions for setting up automated backups"""
    print("""
📅 AUTOMATED BACKUP SETUP

To run backups automatically, add to crontab:

# Daily backup at 2 AM
0 2 * * * cd /path/to/ustam/backend && /path/to/python3 backup_database.py >> /var/log/ustam/backup.log 2>&1

# Hourly backup (for high-traffic production)
0 * * * * cd /path/to/ustam/backend && /path/to/python3 backup_database.py >> /var/log/ustam/backup.log 2>&1

For Google Cloud:
1. Create a Cloud Storage bucket:
   gsutil mb -l europe-west3 gs://ustam-production-backups

2. Set environment variable:
   export GCS_BACKUP_BUCKET=ustam-production-backups

3. Set up Cloud Scheduler for automated backups:
   gcloud scheduler jobs create http backup-database \\
     --schedule="0 2 * * *" \\
     --uri="https://YOUR-PROJECT.appspot.com/api/admin/backup" \\
     --http-method=POST

4. Enable lifecycle management to delete old backups:
   gsutil lifecycle set lifecycle.json gs://ustam-production-backups
   
   # lifecycle.json example:
   {
     "lifecycle": {
       "rule": [{
         "action": {"type": "Delete"},
         "condition": {"age": 90}
       }]
     }
   }
""")

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Backup ustam database')
    parser.add_argument('--setup-cron', action='store_true', help='Show cron setup instructions')
    parser.add_argument('--db-path', help='Path to database file')
    parser.add_argument('--backup-dir', help='Backup directory')
    parser.add_argument('--gcs-bucket', help='Google Cloud Storage bucket name')
    
    args = parser.parse_args()
    
    if args.setup_cron:
        setup_cron_job()
        sys.exit(0)
    
    # Override environment variables if provided
    if args.db_path:
        os.environ['DATABASE_PATH'] = args.db_path
    if args.backup_dir:
        os.environ['BACKUP_DIR'] = args.backup_dir
    if args.gcs_bucket:
        os.environ['GCS_BACKUP_BUCKET'] = args.gcs_bucket
    
    success = backup_database()
    sys.exit(0 if success else 1)
