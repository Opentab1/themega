#!/bin/bash

echo "?? PULSE BAR AI ? INSTALLING..."

# Install system dependencies
sudo apt-get update -qq
sudo apt-get install -y python3-pip python3-venv nodejs npm git sqlite3 ffmpeg v4l-utils portaudio19-dev python3-dev

# Clone or setup project
cd /tmp
if [ -d "pulse-bar-ai" ]; then rm -rf pulse-bar-ai; fi
mkdir -p pulse-bar-ai
cd pulse-bar-ai

# Create backend
mkdir -p backend
cat > backend/requirements.txt << 'EOF'
flask==3.0.0
flask-cors==4.0.0
flask-socketio==5.3.5
opencv-python==4.10.0.84
numpy==1.26.4
pillow==10.4.0
python-socketio==5.10.0
requests==2.31.0
board==1.0
adafruit-circuitpython-bme280==2.6.18
pyaudio==0.2.13
scipy==1.13.1
RPi.GPIO==0.7.1
smbus2==0.4.2
EOF

# Install Python dependencies
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel

# Install core dependencies first
pip install flask==3.0.0 flask-cors==4.0.0 flask-socketio==5.3.5
pip install opencv-python==4.10.0.84 numpy==1.26.4 pillow==10.4.0
pip install python-socketio==5.10.0 requests==2.31.0

# Install hardware-specific packages (may fail on non-RPi systems)
echo "Installing hardware-specific packages (some may fail on non-RPi systems)..."
pip install pyaudio==0.2.13 || echo "Warning: pyaudio installation failed (audio features may not work)"
pip install scipy==1.13.1 || echo "Warning: scipy installation failed"
pip install RPi.GPIO==0.7.1 || echo "Warning: RPi.GPIO installation failed (GPIO features may not work)"
pip install smbus2==0.4.2 || echo "Warning: smbus2 installation failed (I2C features may not work)"
pip install board==1.0 || echo "Warning: board installation failed"
pip install adafruit-circuitpython-bme280==2.6.18 || echo "Warning: BME280 sensor support installation failed"

# Create frontend
mkdir -p frontend
cd frontend
npm init -y
npm install react react-dom vite @vitejs/plugin-react react-router-dom recharts socket.io-client axios lucide-react

# Create start script
cd ..
cat > start.sh << 'EOF'
#!/bin/bash
set -e

echo "?? PULSE BAR AI ? STARTING..."
echo ""

cd "$(dirname "$0")"
source venv/bin/activate

echo "? Starting backend server..."
python3 backend/app.py &
BACKEND_PID=$!

sleep 3

echo "? Starting frontend dev server..."
cd frontend && npm run dev &
FRONTEND_PID=$!
cd ..

sleep 2
echo ""
echo "???????????????????????????????????"
echo "?? PULSE BAR AI IS NOW RUNNING!"
echo "???????????????????????????????????"
echo ""
echo "?? Dashboard:    http://localhost:5173"
echo "?? Camera Feed:  http://localhost:8000/stream"
echo "?? API Docs:     http://localhost:8000/api/dashboard"
echo ""
echo "???????????????????????????????????"
echo "Press Ctrl+C to stop all services"
echo ""

# Handle shutdown gracefully
trap "echo ''; echo '? Stopping services...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT TERM

wait
EOF

chmod +x start.sh

echo "? INSTALLATION COMPLETE"
echo ""
echo "?? AUTO-STARTING PULSE BAR AI..."
echo ""
sleep 2

# Auto-start the system
./start.sh
