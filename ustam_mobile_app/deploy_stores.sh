#!/bin/bash

# ================================================
# ustam Mobile App - Store Deployment Script
# ================================================

set -e

echo "📱 ustam - MOBILE APP DEPLOYMENT"
echo "================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    log_error "Flutter is not installed!"
    exit 1
fi

log_info "Flutter version:"
flutter --version

# Clean and get dependencies
log_info "Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Generate app icons
log_info "Generating app icons..."
flutter pub run flutter_launcher_icons:main

# Android Build
build_android() {
    log_info "Building Android release..."
    
    # Check if keystore exists
    if [ ! -f "android/keystores/ustam-release-keystore.jks" ]; then
        log_error "Release keystore not found!"
        log_info "Create keystore with: keytool -genkey -v -keystore android/keystores/ustam-release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ustam-release-key"
        exit 1
    fi
    
    # Build AAB for Play Store
    flutter build appbundle --release
    log_success "Android App Bundle created: build/app/outputs/bundle/release/app-release.aab"
    
    # Build APK for testing
    flutter build apk --release --split-per-abi
    log_success "APK files created in: build/app/outputs/flutter-apk/"
}

# iOS Build
build_ios() {
    log_info "Building iOS release..."
    
    # Check if on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "iOS build requires macOS!"
        return 1
    fi
    
    # Build iOS
    flutter build ios --release --no-codesign
    log_success "iOS build completed. Open ios/Runner.xcworkspace in Xcode to archive."
    
    log_info "Next steps for iOS:"
    log_info "1. Open ios/Runner.xcworkspace in Xcode"
    log_info "2. Select 'Any iOS Device' as target"
    log_info "3. Product → Archive"
    log_info "4. Distribute App → App Store Connect"
}

# Main execution
case "$1" in
    "android")
        build_android
        ;;
    "ios")
        build_ios
        ;;
    "both")
        build_android
        build_ios
        ;;
    *)
        log_info "Usage: $0 {android|ios|both}"
        log_info "Example: ./deploy_stores.sh android"
        exit 1
        ;;
esac

log_success "Deployment build completed!"

# Store submission checklist
echo ""
log_info "📋 STORE SUBMISSION CHECKLIST:"
echo "✅ App icons generated"
echo "✅ Release builds created"
echo "⚠️  Upload to stores manually"
echo "⚠️  Update app descriptions"
echo "⚠️  Add screenshots"
echo "⚠️  Set pricing and availability"
echo "⚠️  Submit for review"