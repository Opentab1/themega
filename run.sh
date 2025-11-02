#!/bin/bash
set -e

echo "?? PULSE BAR AI ? STARTING..."
echo ""

cd "$(dirname "$0")"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

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
echo "?? Starting backend server..."
python3 backend/app.py &
BACKEND_PID=$!

# Wait for backend
sleep 3

# Start frontend
echo "?? Starting frontend dev server..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

sleep 2
echo ""
echo "???????????????????????????????"
echo "?? PULSE BAR AI IS NOW RUNNING!"
echo "???????????????????????????????"
echo ""
echo "?? Dashboard:    http://localhost:5173"
echo "?? Camera Feed:  http://localhost:8000/stream"
echo "?? API Docs:     http://localhost:8000/api/dashboard"
echo ""
echo "???????????????????????????????"
echo "Press Ctrl+C to stop all services"
echo ""

# Handle shutdown
trap "echo ''; echo '?? Stopping services...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT TERM

wait
