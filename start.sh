#!/bin/bash
set -e

echo "?? PULSE BAR AI ? STARTING..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install Python dependencies if needed
if [ ! -f "venv/.installed" ]; then
    echo "Installing Python dependencies..."
    pip install -r backend/requirements.txt
    touch venv/.installed
fi

# Install Node dependencies if needed
if [ ! -d "frontend/node_modules" ]; then
    echo "Installing Node dependencies..."
    cd frontend
    npm install
    cd ..
fi

# Start backend
echo "Starting backend..."
python3 backend/app.py &
BACKEND_PID=$!

# Wait for backend to start
sleep 3

# Start frontend
echo "Starting frontend..."
cd frontend
npm run dev &
FRONTEND_PID=$!

cd ..

echo ""
echo "? PULSE BAR AI RUNNING"
echo "???????????????????????????????????????????"
echo "?? Dashboard:    http://localhost:5173"
echo "?? Camera Feed:  http://localhost:8000/stream"
echo "?? API:          http://localhost:8000/api/dashboard"
echo "???????????????????????????????????????????"
echo ""
echo "Press Ctrl+C to stop all services"

# Handle shutdown
trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT TERM

# Wait for processes
wait
