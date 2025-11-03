# ?? IMMEDIATE FIX FOR SENSOR DATA ISSUE

## Problem
Backend server crashes with: `RuntimeError: The Werkzeug web server is not designed to run in production`

This prevents the backend from starting, which means **no sensor data** is transmitted to the frontend.

## ? SOLUTION (30 seconds)

Run this command on your Raspberry Pi:

```bash
cd ~/pulse-bar-ai
./pull-and-restart.sh
```

That's it! This will:
1. ??  Stop any running processes
2. ?? Pull the latest fixed code
3. ?? Restart everything with working sensor data

## What Was Fixed

The backend now includes `allow_unsafe_werkzeug=True` parameter in the socketio.run() call (line 416 of backend/app.py), which allows it to run properly.

## Verify It's Working

After running the script, you should see:
- ? Backend starts without errors
- ? "??? Sensor simulation thread started" message
- ? Frontend displays live sensor data:
  - Temperature (?C)
  - Decibel (dB)  
  - Lux (lx)
- ? Sensor values update every 5 seconds

## If You're Still Having Issues

1. Check the backend is running:
```bash
curl http://localhost:8000/api/dashboard
```

2. Check for sensor updates in backend logs:
```bash
# You should see "??? Sensors: XX?C, XXdB, XXlx" every 30 seconds
```

3. Open browser console (F12) and check for WebSocket connection:
```
Connected to server
```

## Technical Details

- **Backend**: Flask-SocketIO server on port 8000
- **Frontend**: Vite dev server on port 5173
- **WebSocket Events**:
  - `sensor_update` - Broadcasts every 5 seconds
  - `dashboard_update` - On data changes
  - `alert` - For overheat/tamper alerts

The sensor simulation thread runs continuously in the background and emits real-time data via WebSocket to all connected clients.
