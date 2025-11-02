#!/bin/bash

echo "?? PULSE BAR AI ? LOCAL INSTALLATION"
echo ""

# Set installation directory
INSTALL_DIR="$HOME/pulse-bar-ai"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing to: $INSTALL_DIR"
echo "Source code at: $SCRIPT_DIR"
echo ""

# Create installation directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Copy application files
echo "?? Copying application files..."
cp -r "$SCRIPT_DIR/backend" .
cp -r "$SCRIPT_DIR/frontend" .

# Create Python virtual environment
echo "?? Setting up Python environment..."
python3 -m venv venv
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

# Install Python dependencies
echo "?? Installing Python dependencies..."
pip install -r backend/requirements.txt || {
    echo "?? Some packages failed to install. Installing core packages..."
    pip install flask==3.0.0 flask-cors==4.0.0 flask-socketio==5.3.5
    pip install opencv-python==4.10.0.84 numpy==1.26.4 pillow==10.4.0
    pip install python-socketio==5.10.0 requests==2.31.0
    
    # Optional hardware packages
    pip install RPi.GPIO==0.7.1 2>/dev/null || echo "?? RPi.GPIO skipped"
    pip install smbus2==0.4.2 2>/dev/null || echo "?? smbus2 skipped"
}

# Install Node dependencies
echo "?? Installing Node dependencies..."
cd frontend
npm install
cd ..

# Create convenient start script
cat > run.sh << 'RUNSCRIPT'
#!/bin/bash
set -e

echo "?? PULSE BAR AI ? STARTING..."
echo ""

cd "$(dirname "$0")"
source venv/bin/activate

# Start backend
echo "?? Starting backend server..."
python3 backend/app.py &
BACKEND_PID=$!

# Wait for backend
sleep 3

# Start frontend
echo "?? Starting frontend dev server..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

sleep 2
echo ""
echo "???????????????????????????????"
echo "?? PULSE BAR AI IS NOW RUNNING!"
echo "???????????????????????????????"
echo ""
echo "?? Dashboard:    http://localhost:5173"
echo "?? Camera Feed:  http://localhost:8000/stream"
echo "?? API Docs:     http://localhost:8000/api/dashboard"
echo ""
echo "???????????????????????????????"
echo "Press Ctrl+C to stop all services"
echo ""

# Handle shutdown
trap "echo ''; echo '?? Stopping services...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT TERM

wait
RUNSCRIPT

chmod +x run.sh

echo ""
echo "? INSTALLATION COMPLETE!"
echo ""
echo "To start Pulse Bar AI, run:"
echo "  cd $INSTALL_DIR"
echo "  ./run.sh"
echo ""
