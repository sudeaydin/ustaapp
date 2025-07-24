#!/bin/bash

echo "🚀 Ustam Backend Setup"
echo "====================="

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt
echo "✅ Dependencies installed"

# Create database
echo "🗄️ Creating database..."
python create_db_with_data.py
echo "✅ Database created with sample data"

echo ""
echo "🎉 Backend setup complete!"
echo "To start the server:"
echo "  source venv/bin/activate"
echo "  python run.py"
echo ""