#!/usr/bin/env python3
"""
Update Mobile App URLs for Production Deployment
Updates Flutter app API URLs to point to production backend
"""

import os
import sys
import re
import json
from pathlib import Path

def update_flutter_api_urls(project_id: str, custom_domain: str = None):
    """Update Flutter app API URLs for production"""
    
    # Determine production URL
    if custom_domain:
        production_url = f"https://{custom_domain}"
    else:
        production_url = f"https://{project_id}.appspot.com"
    
    print(f"🔄 Updating mobile app URLs to: {production_url}")
    
    # Flutter app paths
    flutter_path = Path("ustam_mobile_app")
    
    if not flutter_path.exists():
        print("❌ Flutter app directory not found")
        return False
    
    # Files to update
    files_to_update = [
        "lib/services/api_service.dart",
        "lib/config/api_config.dart", 
        "lib/constants/api_constants.dart",
        "lib/utils/constants.dart"
    ]
    
    # Search for API configuration files
    api_files = []
    for root, dirs, files in os.walk(flutter_path):
        for file in files:
            if file.endswith('.dart') and any(keyword in file.lower() for keyword in ['api', 'config', 'constant']):
                api_files.append(os.path.join(root, file))
    
    updated_files = []
    
    for file_path in api_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Common URL patterns to replace
            patterns = [
                (r'http://localhost:5000', production_url),
                (r'http://127\.0\.0\.1:5000', production_url),
                (r'http://10\.0\.2\.2:5000', production_url),  # Android emulator
                (r'https://.*\.appspot\.com', production_url),  # Previous App Engine URLs
                (r'baseUrl\s*=\s*["\'].*?["\']', f'baseUrl = "{production_url}"'),
                (r'BASE_URL\s*=\s*["\'].*?["\']', f'BASE_URL = "{production_url}"'),
                (r'apiUrl\s*=\s*["\'].*?["\']', f'apiUrl = "{production_url}"'),
            ]
            
            original_content = content
            
            for pattern, replacement in patterns:
                content = re.sub(pattern, replacement, content)
            
            # If content changed, write back
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                updated_files.append(file_path)
                print(f"✅ Updated: {file_path}")
        
        except Exception as e:
            print(f"⚠️ Error updating {file_path}: {e}")
    
    # Update pubspec.yaml if needed
    pubspec_path = flutter_path / "pubspec.yaml"
    if pubspec_path.exists():
        try:
            with open(pubspec_path, 'r', encoding='utf-8') as f:
                pubspec_content = f.read()
            
            # Update version number
            version_pattern = r'version:\s*(\d+\.\d+\.\d+)\+(\d+)'
            match = re.search(version_pattern, pubspec_content)
            
            if match:
                current_version = match.group(1)
                current_build = int(match.group(2))
                new_build = current_build + 1
                
                new_version_line = f"version: {current_version}+{new_build}"
                pubspec_content = re.sub(version_pattern, new_version_line, pubspec_content)
                
                with open(pubspec_path, 'w', encoding='utf-8') as f:
                    f.write(pubspec_content)
                
                print(f"✅ Updated app version: {current_version}+{new_build}")
        
        except Exception as e:
            print(f"⚠️ Error updating pubspec.yaml: {e}")
    
    # Create build configuration
    config_file = flutter_path / "lib" / "config" / "production_config.dart"
    config_file.parent.mkdir(exist_ok=True)
    
    config_content = f'''// Production Configuration - Auto-generated
class ProductionConfig {{
  static const String baseUrl = '{production_url}';
  static const String apiVersion = 'v1';
  static const String environment = 'production';
  static const bool debugMode = false;
  
  // API Endpoints
  static const String authEndpoint = '${{baseUrl}}/api/auth';
  static const String jobsEndpoint = '${{baseUrl}}/api/jobs';
  static const String craftsmenEndpoint = '${{baseUrl}}/api/craftsmen';
  static const String searchEndpoint = '${{baseUrl}}/api/search';
  static const String paymentEndpoint = '${{baseUrl}}/api/payment';
  static const String messagesEndpoint = '${{baseUrl}}/api/messages';
  static const String analyticsEndpoint = '${{baseUrl}}/api/analytics';
  
  // WebSocket
  static const String socketUrl = '{production_url}';
  
  // File Upload
  static const String uploadEndpoint = '${{baseUrl}}/api/upload';
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
}}
'''
    
    with open(config_file, 'w', encoding='utf-8') as f:
        f.write(config_content)
    
    print(f"✅ Created production config: {config_file}")
    
    print(f"\n📱 Mobile App Update Summary:")
    print(f"   Production URL: {production_url}")
    print(f"   Updated files: {len(updated_files)}")
    print(f"   Config created: {config_file}")
    
    print(f"\n🔄 Next Steps:")
    print(f"   1. cd ustam_mobile_app")
    print(f"   2. flutter clean && flutter pub get")
    print(f"   3. flutter build apk --release")
    print(f"   4. Test the app with production backend")
    
    return True

def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Usage: python update_mobile_urls_production.py PROJECT_ID [CUSTOM_DOMAIN]")
        print("\nExamples:")
        print("  python update_mobile_urls_production.py ustam-production")
        print("  python update_mobile_urls_production.py ustam-production api.ustam.com")
        sys.exit(1)
    
    project_id = sys.argv[1]
    custom_domain = sys.argv[2] if len(sys.argv) > 2 else None
    
    print("🚀 ustam - Mobile App URL Update for Production")
    print("=" * 50)
    
    success = update_flutter_api_urls(project_id, custom_domain)
    
    if success:
        print("\n✅ Mobile app URLs updated successfully!")
    else:
        print("\n❌ Failed to update mobile app URLs")
        sys.exit(1)

if __name__ == '__main__':
    main()