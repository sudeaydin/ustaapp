@echo off
echo 🚀 ustam Backend Setup (Windows)
echo =================================

REM Check if virtual environment exists
if not exist "venv" (
    echo 📦 Creating virtual environment...
    python -m venv venv
    echo ✅ Virtual environment created
) else (
    echo ✅ Virtual environment already exists
)

REM Activate virtual environment
echo 🔧 Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo 📥 Upgrading pip...
python -m pip install --upgrade pip

REM Install dependencies
echo 📥 Installing dependencies...
pip install -r requirements.txt

REM Check Flask installation
echo 🔍 Checking Flask installation...
python -c "import flask; print('✅ Flask version:', flask.__version__)"

REM Create database
echo 🗄️ Creating database...
python create_db_with_data.py
echo ✅ Database created with sample data

echo.
echo 🎉 Backend setup complete!
echo To start the server:
echo   venv\Scripts\activate
echo   python run.py
echo.
pause