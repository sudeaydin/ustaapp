#!/bin/bash

echo "🚀 Starting ustam App - All Components"
echo "========================================"

# Check if we're in the right directory
if [ ! -d "backend" ]; then
    echo "❌ Backend folder not found. Make sure you're in the ustaapp root directory."
    exit 1
fi

if [ ! -d "web" ]; then
    echo "❌ Web folder not found. Make sure you're in the ustaapp root directory."
    exit 1
fi

echo "📋 Starting all components..."
echo ""

# Start Backend
echo "🔧 Starting Backend (Flask API)..."
osascript -e 'tell app "Terminal" to do script "cd '"$(pwd)"'/backend && source venv/bin/activate && python run.py"' &

# Wait a bit
sleep 3

# Start Web Frontend
echo "🌐 Starting Web Frontend (React)..."
osascript -e 'tell app "Terminal" to do script "cd '"$(pwd)"'/web && npm run dev"' &

# Wait a bit  
sleep 3

# Start Mobile (optional)
echo "📱 Starting Mobile App (Flutter)..."
osascript -e 'tell app "Terminal" to do script "cd '"$(pwd)"'/ustam_mobile_app && flutter run"' &

echo ""
echo "✅ All components started!"
echo "========================================"
echo "🔧 Backend: http://localhost:5000"
echo "🌐 Web: http://localhost:5173"
echo "📱 Mobile: Flutter simulator"
echo ""
echo "Press Ctrl+C to stop this script"

# Keep script running
while true; do
    sleep 1
done