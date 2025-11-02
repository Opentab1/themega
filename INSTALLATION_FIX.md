# Pulse Bar AI - Installation Fix Guide

## What Went Wrong

The remote installation script (`curl -fsSL https://raw.githubusercontent.com/opentab1/themega/main/install.sh | bash`) had a critical bug:

1. ? It correctly installed all system dependencies
2. ? It correctly set up Python virtual environment  
3. ? It correctly installed Python packages
4. ? It correctly installed Node packages
5. ? **It never downloaded the actual application code files!**

This meant the backend (`app.py`, `sensors.py`) and frontend (`src/` folder with all React components) were missing, so nothing could run.

## Solution Options

### Option 1: Clone and Run Locally (RECOMMENDED)

This is the most reliable method. Run these commands on your Raspberry Pi:

```bash
# Clone the repository
cd ~
git clone https://github.com/opentab1/themega.git pulse-bar-ai
cd pulse-bar-ai

# Run the local installation script
./local-install.sh

# Start the application
cd ~/pulse-bar-ai
./run.sh
```

### Option 2: Use the Fixed Install Script

I've updated `install.sh` to download all application files from GitHub. Once these changes are merged to the main branch, you can run:

```bash
curl -fsSL https://raw.githubusercontent.com/opentab1/themega/main/install.sh | bash
```

The fixed script now includes a section that downloads:
- Backend files (`app.py`, `sensors.py`)
- Frontend package configuration
- All React components
- Configuration files

### Option 3: Manual Installation

If you prefer to do it manually:

```bash
# 1. Create installation directory
mkdir -p ~/pulse-bar-ai
cd ~/pulse-bar-ai

# 2. Install system dependencies
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv nodejs npm git sqlite3 ffmpeg v4l-utils portaudio19-dev python3-dev

# 3. Clone or download the application files
git clone https://github.com/opentab1/themega.git temp
mv temp/backend temp/frontend temp/start.sh .
rm -rf temp

# 4. Set up Python environment
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install -r backend/requirements.txt

# 5. Set up Node environment
cd frontend
npm install
cd ..

# 6. Start the application
./start.sh
```

## Accessing the Application

Once started, you can access:

- **Dashboard**: http://localhost:5173 (or http://YOUR_PI_IP:5173 from another device)
- **Camera Feed**: http://localhost:8000/stream
- **API Docs**: http://localhost:8000/api/dashboard

## Troubleshooting

### Dependencies Failed to Install

Some hardware-specific packages (PyAudio, SciPy) may fail on certain systems. The application will still run with core features - just some advanced audio/sensor features may not work.

### Port Already in Use

If you see "port already in use" errors:
```bash
# Kill any existing processes
pkill -f "python3 backend/app.py"
pkill -f "npm run dev"

# Then restart
./start.sh
```

### Camera Not Working

Make sure your camera is connected and accessible:
```bash
# Test camera
ls /dev/video*

# If no camera found, the app will still run but without camera features
```

## What's Fixed

The updated `install.sh` script now includes this section:

```bash
# Download application files from GitHub
echo "Downloading application files..."
REPO_URL="https://raw.githubusercontent.com/opentab1/themega/main"

# Download backend files
curl -fsSL "${REPO_URL}/backend/app.py" -o backend/app.py
curl -fsSL "${REPO_URL}/backend/sensors.py" -o backend/sensors.py

# Download frontend files  
mkdir -p frontend/src/components
curl -fsSL "${REPO_URL}/frontend/package.json" -o frontend/package.json
curl -fsSL "${REPO_URL}/frontend/vite.config.js" -o frontend/vite.config.js
curl -fsSL "${REPO_URL}/frontend/index.html" -o frontend/index.html
curl -fsSL "${REPO_URL}/frontend/src/main.jsx" -o frontend/src/main.jsx
curl -fsSL "${REPO_URL}/frontend/src/App.jsx" -o frontend/src/App.jsx
curl -fsSL "${REPO_URL}/frontend/src/index.css" -o frontend/src/index.css

# Download all React components
for component in Dashboard CameraFeed OccupancyCounter TableGrid FlowPath Heatmap GlassFlow SongDetector StaffLeaderboard History SensorPanel TamperAlerts; do
    curl -fsSL "${REPO_URL}/frontend/src/components/${component}.jsx" -o "frontend/src/components/${component}.jsx"
done

# Install frontend dependencies
cd frontend
npm install
cd ..
```

This ensures all necessary application files are downloaded before attempting to start the services.

## Need Help?

If you encounter any issues:
1. Check the troubleshooting section above
2. Ensure all system dependencies are installed
3. Check the logs when running `./start.sh`
4. Make sure ports 5173 (frontend) and 8000 (backend) are available
