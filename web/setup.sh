#!/bin/bash

echo "🌐 ustam Frontend Setup"
echo "======================"

# Install dependencies
echo "📥 Installing dependencies..."
npm install
echo "✅ Dependencies installed"

# Check for security vulnerabilities
echo "🔒 Checking for security issues..."
npm audit --audit-level moderate
echo "✅ Security check complete"

echo ""
echo "🎉 Frontend setup complete!"
echo "To start the development server:"
echo "  npm start"
echo ""
echo "To build for production:"
echo "  npm run build"
echo ""