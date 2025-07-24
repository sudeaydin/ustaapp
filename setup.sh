#!/bin/bash

echo "🏗️  USTAM PROJECT SETUP"
echo "======================="
echo ""

# Check if we're in the right directory
if [ ! -f "setup.sh" ]; then
    echo "❌ Please run this script from the Ustam project root directory"
    exit 1
fi

# Setup Backend
echo "🔧 Setting up Backend..."
cd backend
chmod +x setup.sh
./setup.sh
cd ..

echo ""
echo "========================"
echo ""

# Setup Frontend
echo "🌐 Setting up Frontend..."
cd web
chmod +x setup.sh
./setup.sh
cd ..

echo ""
echo "🎉 USTAM PROJECT SETUP COMPLETE!"
echo "================================"
echo ""
echo "🚀 To start the application:"
echo ""
echo "1. Start Backend (Terminal 1):"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   python run.py"
echo ""
echo "2. Start Frontend (Terminal 2):"
echo "   cd web"
echo "   npm start"
echo ""
echo "3. Open browser:"
echo "   http://localhost:5173"
echo ""
echo "📝 Test Users:"
echo "   Customer: customer@example.com / password123"
echo "   Craftsman: craftsman@example.com / password123"
echo "   Admin: admin@example.com / admin123"
echo ""