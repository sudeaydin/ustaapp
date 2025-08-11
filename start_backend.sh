#!/bin/bash

echo "========================================"
echo "       Starting Backend Server"
echo "========================================"

cd /workspace/backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies (skip problematic ones for now)
echo "Installing basic dependencies..."
pip install Flask==2.3.3 Flask-SQLAlchemy==3.0.5 Flask-JWT-Extended==4.5.3 Flask-CORS==4.0.0 Flask-SocketIO==5.3.6 Werkzeug==2.3.7 python-dotenv==1.0.0 marshmallow==3.20.1 marshmallow-sqlalchemy==0.29.0

# Create database if it doesn't exist
if [ ! -f "ustam_app.db" ]; then
    echo "Creating database with sample data..."
    python create_db_with_data.py
fi

# Start backend server
echo "Starting backend server..."
echo "Backend will be available at: http://localhost:5000"
echo "Press Ctrl+C to stop"
python run.py