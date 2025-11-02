# ?? PULSE BAR AI ? QUICKSTART GUIDE

## Installation (Choose One Method)

### Method 1: One-Line Install (AUTO-STARTS!)
```bash
curl -fsSL https://raw.githubusercontent.com/opentab1/themega/main/install.sh | bash
```
**That's it!** The system will automatically start after installation.

To restart later:
```bash
cd /tmp/pulse-bar-ai
./start.sh
```

### Method 2: Git Clone
```bash
git clone https://github.com/yourname/pulse-bar-ai.git
cd pulse-bar-ai
chmod +x start.sh
./start.sh
```

### Method 3: Local Setup (Current Directory)
```bash
chmod +x start.sh
./start.sh
```

## First Time Setup

The start script will automatically:
1. Create Python virtual environment
2. Install Python dependencies (Flask, OpenCV, etc.)
3. Install Node.js dependencies (React, Vite, etc.)
4. Initialize SQLite database
5. Start backend server (port 8000)
6. Start frontend dev server (port 5173)

**First launch takes 2-3 minutes for installation.**

## Access Points

Once running, open these URLs:

| Service | URL | Description |
|---------|-----|-------------|
| **Main Dashboard** | http://localhost:5173 | Full UI with all 16 features |
| **Camera Stream** | http://localhost:8000/stream | Raw MJPEG video feed |
| **API Docs** | http://localhost:8000/api/dashboard | JSON data endpoint |
| **30-Day History** | http://localhost:5173 (History tab) | Charts & analytics |
| **CSV Export** | http://localhost:8000/api/history/csv | Download data |

## Demo Mode

To populate with test data:
```bash
chmod +x demo.sh
./demo.sh
```

This simulates:
- 10 heatmap points
- 3 occupied tables
- 15 staff pours
- 7 occupancy events
- 1 tamper alert

## Quick Feature Guide

### Interactive Features (Click to Use)

1. **Tables** - Click any table to cycle: Empty ? Occupied ? Service
2. **Staff Names** - Click to add +1 pour count
3. **Heatmap** - Click anywhere to add foot traffic point
4. **Occupancy IN/OUT** - Click to increment counters

### Auto-Updating Features

These update automatically every 5 seconds:
- Temperature, Decibel, Lux readings
- Song detection
- Service timers
- Occupancy total

### Camera Feed

The camera auto-detects:
- USB webcams at `/dev/video0`
- Pi Camera Module
- Falls back to simulation if none found

To test camera:
```bash
# Check available cameras
ls -l /dev/video*

# Test stream
curl http://localhost:8000/stream > test.mjpeg
```

## Stopping the System

Press `Ctrl+C` in the terminal where you ran `./start.sh`

Or kill manually:
```bash
pkill -f "python3 backend/app.py"
pkill -f "npm run dev"
```

## Troubleshooting

### "Port 8000 already in use"
```bash
pkill -f "python3 backend/app.py"
./start.sh
```

### "Port 5173 already in use"
```bash
pkill -f "npm run dev"
./start.sh
```

### Dependencies not installing
```bash
# Python issues
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r backend/requirements.txt

# Node issues
cd frontend
rm -rf node_modules package-lock.json
npm install
cd ..
```

### Camera not working
System automatically uses simulation mode. To force:
```bash
SIMULATION_MODE=true ./start.sh
```

### Database issues
```bash
rm pulse_bar.db
./start.sh  # Will recreate fresh database
```

## System Requirements

**Minimum:**
- Linux/macOS/WSL2
- Python 3.8+
- Node.js 16+
- 2GB RAM
- 1GB disk space

**Recommended:**
- Raspberry Pi 4 (4GB)
- USB Camera
- BME280 sensor
- USB microphone

**All sensors are optional** - system uses simulation fallbacks.

## Next Steps

1. ? Start system: `./start.sh`
2. ? Open dashboard: http://localhost:5173
3. ? Run demo: `./demo.sh`
4. ? Click around and explore!
5. ? Check 30-day history tab
6. ? Export CSV data

## Production Deployment

For 24/7 operation:
```bash
sudo cp pulse-bar-ai.service /etc/systemd/system/
sudo systemctl enable pulse-bar-ai
sudo systemctl start pulse-bar-ai
```

## API Usage Examples

```bash
# Get all dashboard data
curl http://localhost:8000/api/dashboard | jq

# Add a pour for staff member
curl -X POST http://localhost:8000/api/pour \
  -H "Content-Type: application/json" \
  -d '{"staff":"Alex"}'

# Update table status
curl -X POST http://localhost:8000/api/table/1 \
  -H "Content-Type: application/json" \
  -d '{"status":"occupied"}'

# Record person entering
curl -X POST http://localhost:8000/api/occupancy \
  -H "Content-Type: application/json" \
  -d '{"direction":"in"}'

# Add heatmap point
curl -X POST http://localhost:8000/api/heatmap \
  -H "Content-Type: application/json" \
  -d '{"x":5,"y":10"}'
```

## File Structure

```
pulse-bar-ai/
??? backend/
?   ??? app.py              # Flask server + camera
?   ??? sensors.py          # Sensor integrations
?   ??? requirements.txt    # Python deps
??? frontend/
?   ??? src/
?   ?   ??? components/     # React components
?   ?   ??? App.jsx         # Main app
?   ?   ??? index.css       # Styles
?   ??? package.json        # Node deps
?   ??? vite.config.js      # Vite config
??? start.sh                # Startup script
??? demo.sh                 # Demo data script
??? install.sh              # One-line installer
??? README.md               # Full documentation
```

## Support

- ?? Full docs: `README.md`
- ?? Issues: GitHub Issues
- ?? Discord: [Link]
- ?? Email: support@pulsebar.ai

---

**Ready to monitor your bar like never before! ??**
