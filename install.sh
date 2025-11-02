#!/bin/bash
set -e

echo "?? PULSE BAR AI ? INSTALLING..."

# Install system dependencies
sudo apt-get update -qq
sudo apt-get install -y python3-pip python3-venv nodejs npm git sqlite3 ffmpeg v4l-utils

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
opencv-python==4.8.1.78
numpy==1.24.3
pillow==10.1.0
python-socketio==5.10.0
requests==2.31.0
board==1.0
adafruit-circuitpython-bme280==2.6.18
pyaudio==0.2.13
scipy==1.11.4
RPi.GPIO==0.7.1
smbus2==0.4.2
EOF

# Install Python dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r backend/requirements.txt

# Create frontend
mkdir -p frontend
cd frontend
npm init -y
npm install react react-dom vite @vitejs/plugin-react react-router-dom recharts socket.io-client axios lucide-react

# Create start script
cd ..
cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
source venv/bin/activate
python3 backend/app.py &
cd frontend && npm run dev &
echo "?? PULSE BAR AI RUNNING"
echo "?? Dashboard: http://localhost:5173"
echo "?? Camera: http://localhost:8000/stream"
wait
EOF

chmod +x start.sh

echo "? INSTALLATION COMPLETE"
echo "Run: cd pulse-bar-ai && ./start.sh"
