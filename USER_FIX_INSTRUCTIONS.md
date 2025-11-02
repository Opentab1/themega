# Quick Fix Instructions for Your Installation

## What Happened

The backend server crashed with a Werkzeug error, preventing the dashboard from loading data. This is now fixed!

## How to Fix Your Installation

You have two options:

### Option 1: Quick Manual Fix (30 seconds)

On your Raspberry Pi, run these commands:

```bash
# Go to your installation directory
cd ~/pulse-bar-ai

# Edit the backend file
nano backend/app.py

# Scroll to the very bottom (line 396)
# Change this line:
#   socketio.run(app, host='0.0.0.0', port=8000, debug=False)
# To this:
#   socketio.run(app, host='0.0.0.0', port=8000, debug=False, allow_unsafe_werkzeug=True)

# Save with Ctrl+O, Enter, then Ctrl+X to exit

# Now restart
./run.sh
```

### Option 2: Re-install Fresh (2-3 minutes)

```bash
# Remove old installation
rm -rf ~/pulse-bar-ai

# Clone fresh copy with the fix
git clone https://github.com/opentab1/themega.git pulse-bar-ai
cd pulse-bar-ai

# Install
chmod +x local-install.sh
./local-install.sh

# Start
cd ~/pulse-bar-ai
./run.sh
```

## What You Should See After Fix

When you start the system, you should see:

```
?? PULSE BAR AI ? Backend Starting
?? Camera stream: http://localhost:8000/stream
?? API: http://localhost:8000/api/dashboard
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8000
```

And when you open http://localhost:5173, you should see:
- ? Live camera feed (or simulation if no camera)
- ? Real-time temperature, decibel, lux readings
- ? Interactive tables, staff leaderboard
- ? Heatmap and occupancy counters
- ? All data loading properly (no endless "loading" message)

## Test the Camera Feed

Once running, test these URLs:

1. **Main Dashboard**: http://localhost:5173
   - Should show full UI with all features

2. **Camera Stream**: http://localhost:8000/stream
   - Should show live video or simulation

3. **API Data**: http://localhost:8000/api/dashboard
   - Should return JSON data

## Still Having Issues?

If you still see "loading" on the dashboard:

1. **Check the backend is running**:
   ```bash
   curl http://localhost:8000/api/dashboard
   ```
   You should get JSON data back.

2. **Check the ports**:
   ```bash
   netstat -tuln | grep -E '8000|5173'
   ```
   Both ports should show as listening.

3. **Check for errors**:
   Look at the terminal where you ran `./run.sh` for any error messages.

4. **Browser console**:
   Open the dashboard (http://localhost:5173), press F12, and check the Console tab for errors.

## Need More Help?

See these files:
- `BACKEND_FIX.md` - Technical details about the fix
- `INSTALLATION_FIX.md` - Installation troubleshooting
- `QUICKSTART.md` - Complete usage guide
- `README.md` - Full documentation
