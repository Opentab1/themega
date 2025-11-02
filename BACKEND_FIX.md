# Backend Server Fix - Werkzeug Production Error

## Problem

When running `./run.sh` or `./start.sh`, the backend server fails with this error:

```
RuntimeError: The Werkzeug web server is not designed to run in production. 
Pass allow_unsafe_werkzeug=True to the run() method to disable this error.
```

This causes the backend to crash, so the frontend cannot connect and shows "loading" indefinitely.

## Solution

The fix has been applied to `backend/app.py`. The socketio.run() call now includes the `allow_unsafe_werkzeug=True` parameter.

### For Fresh Installs

If you're installing fresh, just clone and install normally:

```bash
git clone https://github.com/opentab1/themega.git pulse-bar-ai
cd pulse-bar-ai
chmod +x local-install.sh
./local-install.sh
cd ~/pulse-bar-ai
./run.sh
```

The fix is already included!

### For Existing Installations

If you already installed and have the error, update your installation:

```bash
cd ~/pulse-bar-ai

# Stop any running processes
pkill -f "python3 backend/app.py"
pkill -f "npm run dev"

# Pull the latest changes
cd /path/to/original/clone  # Or re-clone
git pull

# Or manually edit backend/app.py
nano backend/app.py

# Find this line (line 396):
# socketio.run(app, host='0.0.0.0', port=8000, debug=False)

# Change it to:
# socketio.run(app, host='0.0.0.0', port=8000, debug=False, allow_unsafe_werkzeug=True)

# Save and restart
./run.sh
```

## Verification

After applying the fix, you should see:

```
?? PULSE BAR AI ? Backend Starting
?? Camera stream: http://localhost:8000/stream
?? API: http://localhost:8000/api/dashboard
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8000
 * Running on http://192.168.x.x:8000
```

And the frontend should load with:
- Live camera feed
- Real-time sensor data
- Interactive dashboard elements
- No "loading" messages

## Why This Happens

Flask-SocketIO 5.3.5 added a safety check to prevent using Werkzeug (the development server) in production environments. While this is a good safety feature for true production systems, our application is designed for local/Raspberry Pi use where Werkzeug is perfectly acceptable.

For a true production deployment with high traffic, you would want to use a production WSGI server like gunicorn instead.

## Status

? **FIXED** - The fix is now included in the repository as of this commit.

All new installations will work correctly without any manual intervention.
