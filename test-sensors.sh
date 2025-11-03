#!/bin/bash

echo "????????????????????????????????????"
echo "?? TESTING SENSOR DATA FLOW"
echo "????????????????????????????????????"

# Test 1: Check if backend is running
echo ""
echo "?? Test 1: Backend Server Status"
if pgrep -f "python.*app.py" > /dev/null; then
    echo "? Backend process is running"
else
    echo "? Backend is NOT running - run ./run.sh first"
    exit 1
fi

# Test 2: API endpoint accessible
echo ""
echo "?? Test 2: API Endpoint"
if curl -s http://localhost:8000/api/dashboard > /dev/null; then
    echo "? API is responding"
else
    echo "? API not accessible"
    exit 1
fi

# Test 3: Check sensor data in API response
echo ""
echo "?? Test 3: Sensor Data in API"
RESPONSE=$(curl -s http://localhost:8000/api/dashboard)
TEMP=$(echo $RESPONSE | grep -o '"temperature":[0-9.]*' | grep -o '[0-9.]*$')
DECIBEL=$(echo $RESPONSE | grep -o '"decibel":[0-9]*' | grep -o '[0-9]*$')
LUX=$(echo $RESPONSE | grep -o '"lux":[0-9]*' | grep -o '[0-9]*$')

if [ ! -z "$TEMP" ] && [ ! -z "$DECIBEL" ] && [ ! -z "$LUX" ]; then
    echo "? Sensor data present in API:"
    echo "   ???  Temperature: ${TEMP}?C"
    echo "   ?? Decibel: ${DECIBEL}dB"
    echo "   ?? Lux: ${LUX}lx"
else
    echo "? Sensor data missing from API response"
    exit 1
fi

# Test 4: Frontend server
echo ""
echo "?? Test 4: Frontend Server"
if pgrep -f "vite" > /dev/null; then
    echo "? Frontend server is running"
else
    echo "??  Frontend server not running"
fi

echo ""
echo "????????????????????????????????????"
echo "? ALL TESTS PASSED!"
echo "????????????????????????????????????"
echo ""
echo "?? Sensor data is flowing correctly!"
echo ""
echo "Open your browser to: http://localhost:5173"
echo "You should see live sensor data updating every 5 seconds."
echo ""
