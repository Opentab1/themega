#!/bin/bash
# PULSE BAR AI ? Verification Script
# Checks that all components are in place

echo "?? PULSE BAR AI ? VERIFICATION"
echo "???????????????????????????????????????????"
echo ""

PASS="?"
FAIL="?"
total=0
passed=0

check() {
    total=$((total + 1))
    if [ $1 -eq 0 ]; then
        echo "$PASS $2"
        passed=$((passed + 1))
    else
        echo "$FAIL $2"
    fi
}

# Check core files
echo "?? Core Files:"
[ -f "start.sh" ]; check $? "start.sh exists"
[ -f "install.sh" ]; check $? "install.sh exists"
[ -f "demo.sh" ]; check $? "demo.sh exists"
[ -f "README.md" ]; check $? "README.md exists"
echo ""

# Check backend
echo "?? Backend:"
[ -f "backend/app.py" ]; check $? "app.py exists"
[ -f "backend/sensors.py" ]; check $? "sensors.py exists"
[ -f "backend/requirements.txt" ]; check $? "requirements.txt exists"
grep -q "flask" backend/requirements.txt; check $? "Flask dependency listed"
grep -q "opencv" backend/requirements.txt; check $? "OpenCV dependency listed"
echo ""

# Check frontend
echo "??  Frontend:"
[ -f "frontend/package.json" ]; check $? "package.json exists"
[ -f "frontend/vite.config.js" ]; check $? "vite.config.js exists"
[ -f "frontend/index.html" ]; check $? "index.html exists"
[ -f "frontend/src/main.jsx" ]; check $? "main.jsx exists"
[ -f "frontend/src/App.jsx" ]; check $? "App.jsx exists"
[ -f "frontend/src/index.css" ]; check $? "index.css exists"
echo ""

# Check components (all 16 features)
echo "?? Components:"
[ -f "frontend/src/components/Dashboard.jsx" ]; check $? "Dashboard component"
[ -f "frontend/src/components/CameraFeed.jsx" ]; check $? "CameraFeed component (Feature #16)"
[ -f "frontend/src/components/Heatmap.jsx" ]; check $? "Heatmap component (Feature #1)"
[ -f "frontend/src/components/FlowPath.jsx" ]; check $? "FlowPath component (Feature #2)"
[ -f "frontend/src/components/GlassFlow.jsx" ]; check $? "GlassFlow component (Feature #3)"
[ -f "frontend/src/components/TableGrid.jsx" ]; check $? "TableGrid component (Feature #4)"
[ -f "frontend/src/components/StaffLeaderboard.jsx" ]; check $? "StaffLeaderboard component (Feature #5,14)"
[ -f "frontend/src/components/SensorPanel.jsx" ]; check $? "SensorPanel component (Feature #6,7,10,13)"
[ -f "frontend/src/components/OccupancyCounter.jsx" ]; check $? "OccupancyCounter component (Feature #8,9)"
[ -f "frontend/src/components/SongDetector.jsx" ]; check $? "SongDetector component (Feature #11)"
[ -f "frontend/src/components/TamperAlerts.jsx" ]; check $? "TamperAlerts component (Feature #12)"
[ -f "frontend/src/components/History.jsx" ]; check $? "History component (Feature #15)"
echo ""

# Check scripts are executable
echo "?? Scripts:"
[ -x "start.sh" ]; check $? "start.sh is executable"
[ -x "install.sh" ]; check $? "install.sh is executable"
[ -x "demo.sh" ]; check $? "demo.sh is executable"
echo ""

# Check key features in code
echo "?? Feature Implementation:"
grep -q "def stream" backend/app.py; check $? "MJPEG stream endpoint"
grep -q "camera_stream" backend/app.py; check $? "Camera streaming class"
grep -q "socketio" backend/app.py; check $? "WebSocket support"
grep -q "CREATE TABLE" backend/app.py; check $? "Database initialization"
grep -q "camera-full" frontend/src/components/CameraFeed.jsx; check $? "Camera feed component"
grep -q "huge-number" frontend/src/index.css; check $? "Big number styling"
grep -q "Recharts" frontend/src/components/History.jsx; check $? "Charts library"
echo ""

# Check dependencies
echo "?? Dependencies:"
command -v python3 >/dev/null 2>&1; check $? "Python 3 installed"
command -v node >/dev/null 2>&1; check $? "Node.js installed"
command -v npm >/dev/null 2>&1; check $? "npm installed"
echo ""

# Summary
echo "???????????????????????????????????????????"
echo ""
echo "?? VERIFICATION RESULTS:"
echo "   Passed: $passed / $total checks"
echo ""

if [ $passed -eq $total ]; then
    echo "?? ALL CHECKS PASSED!"
    echo "   System is ready to run."
    echo ""
    echo "   Next steps:"
    echo "   1. ./start.sh          # Start the system"
    echo "   2. Open http://localhost:5173"
    echo "   3. ./demo.sh           # Load test data"
    echo ""
    exit 0
else
    failed=$((total - passed))
    echo "??  $failed CHECKS FAILED"
    echo "   Please review the errors above."
    echo ""
    exit 1
fi
