#!/usr/bin/env python3
"""
Production Database Setup Script
Creates and initializes the production database with proper schema and data
"""

import os
import sys
import sqlite3
from datetime import datetime, timedelta
from decimal import Decimal
import json
import hashlib
import secrets

# Add the backend directory to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from werkzeug.security import generate_password_hash

def create_production_database():
    """Create production database with complete schema"""
    
    print("🚀 Starting production database setup...")
    
    # Create Flask app context
    app = create_app()
    
    with app.app_context():
        # Drop all existing tables (fresh start)
        print("📋 Dropping existing tables...")
        db.drop_all()
        
        # Create all tables with updated schema
        print("🏗️  Creating database tables...")
        db.create_all()
        
        # Execute SQL schema file for additional constraints and indexes
        schema_file = os.path.join(os.path.dirname(__file__), 'database_schema.sql')
        if os.path.exists(schema_file):
            print("📄 Executing additional SQL schema...")
            with open(schema_file, 'r', encoding='utf-8') as f:
                sql_content = f.read()
                
            # Split and execute SQL statements
            statements = sql_content.split(';')
            with db.engine.connect() as connection:
                for statement in statements:
                    statement = statement.strip()
                    if statement and not statement.startswith('--') and len(statement) > 10:
                        try:
                            connection.execute(db.text(statement))
                        except Exception as e:
                            # Skip errors for statements that might already exist
                            pass
                connection.commit()
        
        # Create production data
        create_production_data()
        
        # Commit all changes
        db.session.commit()
        
        print("✅ Production database setup completed successfully!")
        print_database_info()

def create_production_data():
    """Create initial production data"""
    
    print("📊 Creating production data...")
    
    # Import models
    from app.models.user import User
    from app.models.customer import Customer
    from app.models.craftsman import Craftsman
    from app.models.category import Category
    
    # Create system admin user
    admin_user = User(
        email='admin@ustam.com',
        phone='+905551234567',
        first_name='System',
        last_name='Admin',
        user_type='admin',
        is_active=True,
        is_verified=True,
        phone_verified=True,
        email_verified=True,
        city='İstanbul',
        district='Kadıköy'
    )
    admin_user.set_password('ustamAdmin2024!')
    db.session.add(admin_user)
    
    # Create service categories
    categories_data = [
        {
            'name': 'Elektrikçi',
            'name_en': 'Electrician',
            'slug': 'elektrikci',
            'description': 'Elektrik tesisatı kurulum, onarım ve bakım hizmetleri',
            'icon': '⚡',
            'color': '#f59e0b',
            'sort_order': 1,
            'is_featured': True
        },
        {
            'name': 'Tesisatçı',
            'name_en': 'Plumber',
            'slug': 'tesisatci',
            'description': 'Su, doğalgaz ve ısıtma tesisatı hizmetleri',
            'icon': '🔧',
            'color': '#3b82f6',
            'sort_order': 2,
            'is_featured': True
        },
        {
            'name': 'Boyacı',
            'name_en': 'Painter',
            'slug': 'boyaci',
            'description': 'İç ve dış cephe boyama, badana hizmetleri',
            'icon': '🎨',
            'color': '#ef4444',
            'sort_order': 3,
            'is_featured': True
        },
        {
            'name': 'Marangoz',
            'name_en': 'Carpenter',
            'slug': 'marangoz',
            'description': 'Ahşap işleri, mobilya yapım ve onarım',
            'icon': '🔨',
            'color': '#8b5cf6',
            'sort_order': 4,
            'is_featured': True
        },
        {
            'name': 'Temizlik',
            'name_en': 'Cleaning',
            'slug': 'temizlik',
            'description': 'Ev, ofis ve inşaat sonrası temizlik hizmetleri',
            'icon': '🧹',
            'color': '#10b981',
            'sort_order': 5,
            'is_featured': True
        },
        {
            'name': 'Bahçıvan',
            'name_en': 'Gardener',
            'slug': 'bahcivan',
            'description': 'Bahçe düzenleme, peyzaj ve bakım hizmetleri',
            'icon': '🌱',
            'color': '#22c55e',
            'sort_order': 6,
            'is_featured': True
        },
        {
            'name': 'Klima Teknisyeni',
            'name_en': 'AC Technician',
            'slug': 'klima-teknisyeni',
            'description': 'Klima montaj, bakım ve onarım hizmetleri',
            'icon': '❄️',
            'color': '#06b6d4',
            'sort_order': 7,
            'is_featured': False
        },
        {
            'name': 'Cam Ustası',
            'name_en': 'Glazier',
            'slug': 'cam-ustasi',
            'description': 'Cam kesim, montaj ve onarım hizmetleri',
            'icon': '🪟',
            'color': '#84cc16',
            'sort_order': 8,
            'is_featured': False
        },
        {
            'name': 'Fayansçı',
            'name_en': 'Tiler',
            'slug': 'fayansci',
            'description': 'Fayans, seramik ve mozaik döşeme hizmetleri',
            'icon': '🔲',
            'color': '#f97316',
            'sort_order': 9,
            'is_featured': False
        },
        {
            'name': 'Nakliyeci',
            'name_en': 'Mover',
            'slug': 'nakliyeci',
            'description': 'Ev ve ofis taşıma hizmetleri',
            'icon': '🚚',
            'color': '#6b7280',
            'sort_order': 10,
            'is_featured': False
        }
    ]
    
    for cat_data in categories_data:
        category = Category(
            name=cat_data['name'],
            name_en=cat_data['name_en'],
            slug=cat_data['slug'],
            description=cat_data['description'],
            icon=cat_data['icon'],
            color=cat_data['color'],
            sort_order=cat_data['sort_order'],
            is_active=True,
            is_featured=cat_data['is_featured']
        )
        db.session.add(category)
    
    print("✅ Categories created")
    
    # Create sample demo users for testing
    demo_users = [
        {
            'email': 'demo.musteri@ustam.com',
            'phone': '+905551234568',
            'first_name': 'Demo',
            'last_name': 'Müşteri',
            'user_type': 'customer',
            'password': 'demo123',
            'city': 'İstanbul',
            'district': 'Beşiktaş'
        },
        {
            'email': 'demo.usta@ustam.com',
            'phone': '+905551234569',
            'first_name': 'Demo',
            'last_name': 'Usta',
            'user_type': 'craftsman',
            'password': 'demo123',
            'city': 'İstanbul',
            'district': 'Şişli'
        }
    ]
    
    for user_data in demo_users:
        user = User(
            email=user_data['email'],
            phone=user_data['phone'],
            first_name=user_data['first_name'],
            last_name=user_data['last_name'],
            user_type=user_data['user_type'],
            is_active=True,
            is_verified=True,
            phone_verified=True,
            email_verified=True,
            city=user_data['city'],
            district=user_data['district']
        )
        user.set_password(user_data['password'])
        db.session.add(user)
        
        # Create corresponding profile
        if user_data['user_type'] == 'customer':
            customer = Customer(
                user=user,
                preferred_contact_method='phone'
            )
            db.session.add(customer)
        elif user_data['user_type'] == 'craftsman':
            craftsman = Craftsman(
                user=user,
                business_name='Demo Usta İşleri',
                description='Demo usta hesabı - test amaçlı kullanım',
                hourly_rate=Decimal('150.00'),
                is_available=True,
                is_verified=True
            )
            db.session.add(craftsman)
    
    print("✅ Demo users created")

def create_system_settings():
    """Create system settings for production"""
    
    settings = [
        ('app_name', 'ustam', 'Application name', 'string', True),
        ('app_version', '1.0.0', 'Application version', 'string', True),
        ('maintenance_mode', 'false', 'Maintenance mode status', 'boolean', True),
        ('platform_fee_rate', '0.05', 'Platform fee rate (5%)', 'float', False),
        ('min_job_price', '50.00', 'Minimum job price', 'float', True),
        ('max_job_price', '50000.00', 'Maximum job price', 'float', True),
        ('currency', 'TRY', 'Default currency', 'string', True),
        ('timezone', 'Europe/Istanbul', 'Default timezone', 'string', True),
        ('max_file_size', '10485760', 'Maximum file size in bytes (10MB)', 'integer', True),
        ('allowed_file_types', '["jpg", "jpeg", "png", "pdf", "doc", "docx"]', 'Allowed file types', 'json', True),
        ('smtp_host', '', 'SMTP server host', 'string', False),
        ('smtp_port', '587', 'SMTP server port', 'integer', False),
        ('smtp_username', '', 'SMTP username', 'string', False),
        ('smtp_password', '', 'SMTP password', 'string', False),
        ('sms_api_key', '', 'SMS API key', 'string', False),
        ('payment_test_mode', 'true', 'Payment system test mode', 'boolean', False),
        ('iyzico_api_key', '', 'Iyzico API key', 'string', False),
        ('iyzico_secret_key', '', 'Iyzico secret key', 'string', False),
        ('google_maps_api_key', '', 'Google Maps API key', 'string', False),
        ('firebase_server_key', '', 'Firebase server key for push notifications', 'string', False)
    ]
    
    # Execute raw SQL for system settings
    with db.engine.connect() as connection:
        for key, value, description, setting_type, is_public in settings:
            sql = db.text("""
            INSERT OR IGNORE INTO system_settings (key, value, description, type, is_public) 
            VALUES (:key, :value, :description, :setting_type, :is_public)
            """)
            connection.execute(sql, {
                'key': key, 
                'value': value, 
                'description': description, 
                'setting_type': setting_type, 
                'is_public': is_public
            })
        connection.commit()

def print_database_info():
    """Print database information"""
    
    print("\n" + "="*50)
    print("📊 DATABASE INFORMATION")
    print("="*50)
    
    # Get table information
    with db.engine.connect() as connection:
        tables_info = connection.execute(db.text("""
            SELECT name FROM sqlite_master 
            WHERE type='table' AND name NOT LIKE 'sqlite_%'
            ORDER BY name
        """)).fetchall()
        
        print(f"📋 Total Tables: {len(tables_info)}")
        for table in tables_info:
            table_name = table[0]
            count_result = connection.execute(db.text(f"SELECT COUNT(*) FROM {table_name}")).fetchone()
            count = count_result[0] if count_result else 0
            print(f"   • {table_name}: {count} records")
    
    print("\n🔑 DEFAULT LOGIN CREDENTIALS:")
    print("   • Admin: admin@ustam.com / ustamAdmin2024!")
    print("   • Demo Customer: demo.musteri@ustam.com / demo123")
    print("   • Demo Craftsman: demo.usta@ustam.com / demo123")
    
    print("\n📁 Database Location:")
    print(f"   • {os.path.abspath('app.db')}")
    
    print("\n🌐 Next Steps:")
    print("   1. Configure system settings in admin panel")
    print("   2. Set up payment gateway credentials")
    print("   3. Configure email/SMS services")
    print("   4. Upload category images")
    print("   5. Test all functionality")
    print("="*50)

def backup_existing_database():
    """Backup existing database if it exists"""
    
    db_path = 'app.db'
    if os.path.exists(db_path):
        backup_path = f'app_backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}.db'
        print(f"💾 Backing up existing database to {backup_path}")
        
        import shutil
        shutil.copy2(db_path, backup_path)
        return backup_path
    return None

def main():
    """Main setup function"""
    
    print("🔨 ustam - PRODUCTION DATABASE SETUP")
    print("="*50)
    
    # Backup existing database
    backup_path = backup_existing_database()
    if backup_path:
        print(f"✅ Database backed up to: {backup_path}")
    
    try:
        # Create production database
        create_production_database()
        
        # Create system settings
        create_system_settings()
        
        print("\n🎉 Production database setup completed successfully!")
        print("Your ustam application is ready for production deployment.")
        
    except Exception as e:
        print(f"\n❌ Error during database setup: {str(e)}")
        print("Please check the error and try again.")
        
        # Restore backup if available
        if backup_path and os.path.exists(backup_path):
            print(f"🔄 Restoring backup from {backup_path}")
            import shutil
            shutil.copy2(backup_path, 'app.db')
        
        sys.exit(1)

if __name__ == '__main__':
    main()