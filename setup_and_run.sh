#!/bin/bash

echo "========================================"
echo "       UstamApp Setup & Run Script"
echo "========================================"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}[$1/8]${NC} $2"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

print_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

# Change to project directory
print_step 1 "Changing to project directory..."
PROJECT_DIR="$HOME/FlutterProjects/ustam_mobile_app"
if [ ! -d "$PROJECT_DIR" ]; then
    PROJECT_DIR="./ustam_mobile_app"
    if [ ! -d "$PROJECT_DIR" ]; then
        PROJECT_DIR="."
    fi
fi

cd "$PROJECT_DIR"
if [ $? -ne 0 ]; then
    print_error "Could not find project directory!"
    echo "Please run this script from the project root or ensure project exists"
    exit 1
fi

# Pull latest changes
print_step 2 "Pulling latest changes from Git..."
git pull origin main
if [ $? -ne 0 ]; then
    print_warning "Git pull failed. Continuing anyway..."
fi

# Setup Backend
echo
print_step 3 "Setting up Backend..."
cd backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        print_error "Failed to create virtual environment!"
        exit 1
    fi
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate
if [ $? -ne 0 ]; then
    print_error "Failed to activate virtual environment!"
    exit 1
fi

# Install dependencies
print_step 4 "Installing Python dependencies..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    print_error "Failed to install Python dependencies!"
    exit 1
fi

# Create database
print_step 5 "Creating database with sample data..."
python create_db_with_data.py
if [ $? -ne 0 ]; then
    print_error "Failed to create database!"
    exit 1
fi

# Setup Flutter
echo
print_step 6 "Setting up Flutter..."
cd ../ustam_mobile_app
flutter pub get
if [ $? -ne 0 ]; then
    print_error "Flutter pub get failed!"
    exit 1
fi

# Start Backend Server
echo
print_step 7 "Starting Backend Server..."
cd ../backend

# Start backend in background
echo "Starting backend server in background..."
source venv/bin/activate && python run.py &
BACKEND_PID=$!

echo "Backend server started with PID: $BACKEND_PID"
echo "Waiting 5 seconds for server to start..."
sleep 5

# Test if backend is running
if curl -s http://localhost:5000/api/search/categories > /dev/null; then
    print_success "Backend server is running!"
else
    print_warning "Backend server might not be ready yet..."
fi

# Start Flutter App
echo
print_step 8 "Starting Flutter App..."
cd ../ustam_mobile_app
echo
echo "========================================"
echo "     Setup Complete! Starting App..."
echo "========================================"
echo
echo "Backend Server: http://localhost:5000"
echo "Flutter App: Starting now..."
echo
echo "Press Ctrl+C to stop the Flutter app"
echo "Backend PID: $BACKEND_PID"
echo

# Trap Ctrl+C to cleanup
cleanup() {
    echo
    echo "========================================"
    echo "          Cleaning Up..."
    echo "========================================"
    echo "Stopping backend server (PID: $BACKEND_PID)..."
    kill $BACKEND_PID 2>/dev/null
    echo "Cleanup complete!"
    exit 0
}

trap cleanup INT

# Start Flutter
flutter run

# If flutter run exits normally, also cleanup
cleanup