#!/bin/bash

echo "?? PULSE BAR AI ? System Verification"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backend is running
echo -n "Checking backend (port 8000)... "
if curl -s http://localhost:8000/api/dashboard > /dev/null 2>&1; then
    echo -e "${GREEN}? OK${NC}"
    BACKEND_OK=1
else
    echo -e "${RED}? NOT RESPONDING${NC}"
    BACKEND_OK=0
fi

# Check if frontend is running
echo -n "Checking frontend (port 5173)... "
if curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo -e "${GREEN}? OK${NC}"
    FRONTEND_OK=1
else
    echo -e "${RED}? NOT RESPONDING${NC}"
    FRONTEND_OK=0
fi

# Check camera stream
echo -n "Checking camera stream... "
if curl -s --max-time 2 http://localhost:8000/stream > /dev/null 2>&1; then
    echo -e "${GREEN}? OK${NC}"
    CAMERA_OK=1
else
    echo -e "${YELLOW}? NOT AVAILABLE (simulation mode?)${NC}"
    CAMERA_OK=0
fi

# Get API data
echo ""
echo "Backend API Response:"
if [ $BACKEND_OK -eq 1 ]; then
    API_DATA=$(curl -s http://localhost:8000/api/dashboard)
    echo "$API_DATA" | python3 -m json.tool 2>/dev/null || echo "$API_DATA"
fi

# Check processes
echo ""
echo "Running Processes:"
echo -n "  Backend process: "
if pgrep -f "python3 backend/app.py" > /dev/null; then
    echo -e "${GREEN}? Running${NC} (PID: $(pgrep -f 'python3 backend/app.py'))"
else
    echo -e "${RED}? Not running${NC}"
fi

echo -n "  Frontend process: "
if pgrep -f "npm run dev" > /dev/null; then
    echo -e "${GREEN}? Running${NC} (PID: $(pgrep -f 'npm run dev'))"
else
    echo -e "${RED}? Not running${NC}"
fi

# Check ports
echo ""
echo "Port Status:"
netstat -tuln 2>/dev/null | grep -E '8000|5173' || ss -tuln 2>/dev/null | grep -E '8000|5173' || echo "Could not check ports (netstat/ss not available)"

# Check virtual environment
echo ""
echo "Virtual Environment:"
if [ -d "venv" ]; then
    echo -e "  ${GREEN}? exists${NC}"
    if [ -f "venv/bin/python3" ]; then
        echo "  Python: $(venv/bin/python3 --version)"
    fi
else
    echo -e "  ${RED}? not found${NC}"
fi

# Check node_modules
echo ""
echo "Node Modules:"
if [ -d "frontend/node_modules" ]; then
    echo -e "  ${GREEN}? installed${NC}"
else
    echo -e "  ${RED}? not installed${NC}"
fi

# Overall status
echo ""
echo "???????????????????????????????????????"
if [ $BACKEND_OK -eq 1 ] && [ $FRONTEND_OK -eq 1 ]; then
    echo -e "${GREEN}? SYSTEM IS WORKING${NC}"
    echo ""
    echo "Access your dashboard at:"
    echo "  http://localhost:5173"
    echo ""
elif [ $BACKEND_OK -eq 0 ]; then
    echo -e "${RED}? BACKEND NOT RESPONDING${NC}"
    echo ""
    echo "Try these steps:"
    echo "  1. Check if backend is running: ps aux | grep python3"
    echo "  2. Check backend logs for errors"
    echo "  3. Try restarting: ./run.sh or ./start.sh"
    echo "  4. Verify the fix: grep 'allow_unsafe_werkzeug' backend/app.py"
    echo ""
elif [ $FRONTEND_OK -eq 0 ]; then
    echo -e "${RED}? FRONTEND NOT RESPONDING${NC}"
    echo ""
    echo "Try these steps:"
    echo "  1. Check if frontend is running: ps aux | grep npm"
    echo "  2. Try restarting: ./run.sh or ./start.sh"
    echo "  3. Check Node dependencies: cd frontend && npm install"
    echo ""
fi
echo "???????????????????????????????????????"
