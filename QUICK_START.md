# 🚀 ustam App - Quick Start Guide

## ⚡ **SUPER FAST SETUP (Windows)**

```cmd
# 1. Clone repository (ilk kez)
git clone https://github.com/sudeaydin/ustaapp.git
cd ustaapp

# VEYA güncel kodu çek (varsa)
git pull origin main

# 2. Run quick setup
quick_setup.bat

# 3. Start all components
start_all_windows.bat
```

## ⚡ **SUPER FAST SETUP (Mac/Linux)**

```bash
# 1. Clone repository
git clone https://github.com/sudeaydin/ustaapp.git
cd ustaapp

# 2. Make scripts executable
chmod +x start_all_unix.sh
chmod +x setup.sh

# 3. Run setup
./setup.sh

# 4. Start all components
./start_all_unix.sh
```

---

## 🔧 **MANUAL SETUP**

### **Prerequisites:**
- **Python 3.8+** → https://www.python.org/downloads/
- **Node.js 16+** → https://nodejs.org/
- **Flutter 3.8+** → https://flutter.dev/docs/get-started/install

### **Backend (Flask API):**
```cmd
cd backend
python -m venv venv
venv\Scripts\activate          # Windows
# source venv/bin/activate     # Mac/Linux
pip install -r requirements.txt
setup_env.bat                  # Windows
python create_db_with_data.py
python run.py
```

### **Web Frontend (React):**
```cmd
cd web
npm install
npm run dev
```

### **Mobile App (Flutter):**
```cmd
cd ustam_mobile_app
flutter pub get
flutter run
```

---

## 🌐 **ACCESS URLS**

After starting all components:

- **🔧 Backend API:** http://localhost:5000
- **🌐 Web App:** http://localhost:5173
- **📱 Mobile App:** Flutter simulator/device
- **📊 API Health:** http://localhost:5000/api/health

---

## 🧪 **TEST ACCOUNTS**

```
Customer Account:
Email: customer@example.com
Password: password123

Craftsman Account:
Email: craftsman@example.com  
Password: password123

Admin Account:
Email: admin@example.com
Password: admin123
```

---

## 🚨 **TROUBLESHOOTING**

### **"Python not found"**
```
✅ Install Python 3.8+ from https://www.python.org/downloads/
✅ Make sure "Add Python to PATH" is checked during installation
```

### **"npm not found"**
```
✅ Install Node.js from https://nodejs.org/
✅ Restart terminal after installation
```

### **"flutter not found"**
```
✅ Install Flutter from https://flutter.dev/docs/get-started/install
✅ Add Flutter to PATH
```

### **"Backend fails to start"**
```
✅ Make sure you're in backend/ directory
✅ Activate virtual environment first
✅ Run: pip install -r requirements.txt
✅ Check if .env file exists (run setup_env.bat)
```

### **"Web fails to start"**
```
✅ Make sure you're in web/ directory  
✅ Run: npm install
✅ Check if node_modules/ folder exists
```

### **"Port already in use"**
```
Backend (5000): netstat -ano | findstr :5000
Web (5173): netstat -ano | findstr :5173
Kill process: taskkill /PID <PID> /F
```

---

## 🎉 **SUCCESS!**

When everything is running:
- ✅ Backend logs show "Running on http://127.0.0.1:5000"
- ✅ Web shows "Local: http://localhost:5173/"
- ✅ Mobile shows device/simulator selection
- ✅ You can access the web app in browser

**Happy coding! 🚀**