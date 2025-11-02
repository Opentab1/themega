# ?? PULSE BAR AI ? Real-Time Bar Monitoring System

**Prison-proof monitoring system with 16 live features, 30-day memory, and live camera feed.**

## ? INSTALLATION

### Method 1: Clone and Run (RECOMMENDED)

```bash
# Clone the repository
git clone https://github.com/opentab1/themega.git pulse-bar-ai
cd pulse-bar-ai

# Run the local installation script
chmod +x local-install.sh
./local-install.sh

# Start the application
cd ~/pulse-bar-ai
./run.sh

# OR if you're in the repository directory
./start.sh
```

### Method 2: One-Line Remote Install

```bash
curl -fsSL https://raw.githubusercontent.com/opentab1/themega/main/install.sh | bash
```

**This will automatically:**
1. Install all system dependencies
2. Download application files
3. Set up Python virtual environment
4. Install Python packages
5. Install Node packages
6. Start the system immediately

> **Note**: If you encounter issues with the remote install, use Method 1 instead. See [INSTALLATION_FIX.md](INSTALLATION_FIX.md) for troubleshooting.

## ?? QUICK START

```bash
# If installed via local-install.sh
cd ~/pulse-bar-ai
./run.sh

# If running from repository directory
./start.sh
```

Access:
- **Dashboard**: http://localhost:5173
- **Camera Stream**: http://localhost:8000/stream
- **API**: http://localhost:8000/api/dashboard

> **Note**: If you encounter a Werkzeug production error, see [BACKEND_FIX.md](BACKEND_FIX.md) for the solution (already applied to latest version).

## 16 FEATURES

### 1. ?? Live Heatmap
Real-time foot traffic visualization. Click anywhere to add data points.

### 2. ?? FlowPath? Arrows
Customer movement patterns with directional arrows showing traffic flow.

### 3. ?? Glass Flow? Lifecycle
Complete drink journey: Order ? Pour ? Serve ? Delivered with timings.

### 4. ?? Service Timer? Per Table
20 tables with live service timers. Click to cycle: Empty ? Occupied ? Service.

### 5. ?? Pour Counter Leaderboard
Staff performance tracking with pour counts. Click staff members to add pours.

### 6. ?? Decibel Meter
Real-time sound level monitoring (60-95 dB typical bar range).

### 7. ?? Lux Meter
Ambient light level monitoring (200-700 lux).

### 8. ?? People Counter ? IN/OUT
**Big numbers**: IN: 47 | OUT: 12  
Click to increment counts.

### 9. ?? Total Occupancy
**Huge display**: OCCUPANCY: 35  
Auto-calculated from in/out counts.

### 10. ??? Indoor Temperature (BME280)
Live temperature monitoring with overheat protection (150?C threshold).

### 11. ?? Song Detection
Currently playing music with title + artist display.

### 12. ?? Tamper Alert
Physical tampering detection with photo logging and alerts.

### 13. ?? Overheat Auto-Shutdown
Automatic safety shutdown at 150?C with prominent alert.

### 14. ?? Staff Leaderboard
Full rankings with pours, tables served, and ratings.

### 15. ?? 30-Day History Tab
- Interactive charts with Recharts
- CSV export functionality
- Trend analysis
- Statistics summary

### 16. ?? LIVE CAMERA FEED
**Full-screen MJPEG stream on dashboard**  
Real-time video monitoring integrated into main view.

## ??? ARCHITECTURE

### Backend (Python/Flask)
- **Framework**: Flask + Flask-SocketIO
- **Camera**: OpenCV (MJPEG streaming)
- **Database**: SQLite (30-day retention)
- **Sensors**: BME280, Audio, Light, IR
- **API**: RESTful + WebSocket

### Frontend (React)
- **Framework**: React 18 + Vite
- **Charts**: Recharts
- **Real-time**: Socket.IO Client
- **Styling**: Modern CSS with glassmorphism
- **Icons**: Lucide React

### Database Schema
```sql
events          - All system events
heatmap         - Foot traffic data
staff           - Staff performance
tables          - Table status + timers
occupancy       - People counting history
```

## ?? API ENDPOINTS

### GET Endpoints
```
GET /stream                  - MJPEG camera stream
GET /api/dashboard          - All dashboard data
GET /api/history            - 30-day history
GET /api/history/csv        - Export CSV
```

### POST Endpoints
```
POST /api/pour              - Add pour count
POST /api/table/:id         - Update table status
POST /api/occupancy         - Update occupancy
POST /api/heatmap           - Add heatmap point
POST /api/tamper            - Record tamper alert
```

### WebSocket Events
```
connect              - Client connected
dashboard_update     - Live data update
sensor_update        - Sensor readings
alert                - System alerts
```

## ?? CONFIGURATION

### Hardware Requirements
- **Raspberry Pi 4** (recommended) or any Linux system
- **USB Camera** or Pi Camera Module
- **BME280 Sensor** (optional, simulation fallback)
- **USB Microphone** (optional, simulation fallback)
- **Lux Sensor** (optional, simulation fallback)

### Software Requirements
- Python 3.8+
- Node.js 16+
- npm 8+
- SQLite 3

### Environment Variables
```bash
CAMERA_DEVICE=0              # Camera device ID
SIMULATION_MODE=false        # Use real sensors
DB_PATH=pulse_bar.db         # Database location
PORT=8000                    # Backend port
```

## ?? UI FEATURES

### Glass Flow Design
- Glassmorphism effects
- Neon green (#00ff88) accent color
- Dark mode optimized
- Responsive grid layout
- Smooth transitions
- Hover effects
- Real-time animations

### Interactive Elements
- Click tables to change status
- Click staff to add pours
- Click heatmap to add traffic
- Click occupancy counters to increment

## ?? SECURITY FEATURES

### Tamper Detection
- Physical switch monitoring
- GPIO-based detection
- Photo capture on trigger
- Event logging
- Alert broadcasting

### Overheat Protection
- Continuous temperature monitoring
- 150?C shutdown threshold
- Automatic alert system
- WebSocket notifications

## ?? DATA RETENTION

- **Events**: 30 days
- **Heatmap**: 30 days
- **Occupancy**: 30 days
- **Staff Stats**: Persistent
- **Table Status**: Persistent

Auto-cleanup runs daily at midnight.

## ?? DEPLOYMENT

### Development
```bash
./start.sh
```

### Production
```bash
# Install as systemd service
sudo cp pulse-bar-ai.service /etc/systemd/system/
sudo systemctl enable pulse-bar-ai
sudo systemctl start pulse-bar-ai
```

### Docker (Optional)
```bash
docker build -t pulse-bar-ai .
docker run -p 8000:8000 -p 5173:5173 --device=/dev/video0 pulse-bar-ai
```

## ?? TESTING

### Test Sensors
```bash
python3 backend/sensors.py
```

### Test Camera
```bash
curl http://localhost:8000/stream > test.mjpeg
```

### Test API
```bash
curl http://localhost:8000/api/dashboard | jq
```

## ?? TODO / FUTURE FEATURES

- [ ] Face detection for VIP recognition
- [ ] Inventory tracking via barcode
- [ ] POS system integration
- [ ] Mobile app (React Native)
- [ ] Multi-location support
- [ ] AI-powered predictions
- [ ] Voice commands
- [ ] Spotify integration
- [ ] Payment processing
- [ ] Advanced analytics

## ?? TROUBLESHOOTING

### Camera not working
```bash
# Check camera devices
ls -l /dev/video*
v4l2-ctl --list-devices

# Test with simulation mode
SIMULATION_MODE=true ./start.sh
```

### Sensors not detected
The system automatically falls back to simulation mode if hardware sensors aren't detected.

### Port already in use
```bash
# Kill existing processes
pkill -f "python3 backend/app.py"
pkill -f "npm run dev"
```

### Database locked
```bash
# Reset database
rm pulse_bar.db
python3 backend/app.py  # Will recreate
```

## ?? LICENSE

MIT License - See LICENSE file for details

## ?? CONTRIBUTING

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

## ?? SUPPORT

- Issues: https://github.com/yourname/pulse-bar-ai/issues
- Discussions: https://github.com/yourname/pulse-bar-ai/discussions

## ?? BUILT WITH

- Flask 3.0
- React 18
- OpenCV 4.8
- Socket.IO 5.3
- Recharts 2.10
- Vite 5.0

---

**Made with ?? for the bar industry**