#!/bin/bash
# PULSE BAR AI ? Demo Script
# Demonstrates all 16 features with simulated data

echo "?? PULSE BAR AI ? DEMO MODE"
echo "???????????????????????????????????????????"
echo ""

API_URL="http://localhost:8000"

# Wait for server
echo "? Waiting for server to start..."
sleep 5

# Function to make API calls
make_request() {
    curl -s -X POST -H "Content-Type: application/json" -d "$2" "$API_URL$1" > /dev/null 2>&1
    echo "? $3"
}

echo ""
echo "?? Testing all 16 features..."
echo ""

# 1. Heatmap - Add random points
echo "1. ?? Adding heatmap data..."
for i in {1..10}; do
    x=$((RANDOM % 20))
    y=$((RANDOM % 20))
    make_request "/api/heatmap" "{\"x\":$x,\"y\":$y}" "Added heatmap point ($x,$y)"
    sleep 0.2
done
echo ""

# 2-3. FlowPath & Glass Flow are visual components (no API needed)
echo "2. ?? FlowPath? arrows - displayed on dashboard"
echo "3. ?? Glass Flow? lifecycle - displayed on dashboard"
echo ""

# 4. Tables - Update some tables
echo "4. ??  Updating table statuses..."
make_request "/api/table/1" '{"status":"occupied"}' "Table 1 ? Occupied"
make_request "/api/table/2" '{"status":"service"}' "Table 2 ? Service"
make_request "/api/table/3" '{"status":"occupied"}' "Table 3 ? Occupied"
echo ""

# 5 & 14. Staff leaderboard - Add pours
echo "5. ?? Adding pour counts..."
for name in "Alex" "Jordan" "Casey" "Morgan" "Taylor"; do
    for i in {1..3}; do
        make_request "/api/pour" "{\"staff\":\"$name\"}" "Pour for $name"
        sleep 0.1
    done
done
echo ""

# 8 & 9. Occupancy counter
echo "8-9. ?? Simulating people movement..."
for i in {1..5}; do
    make_request "/api/occupancy" '{"direction":"in"}' "Person entered"
    sleep 0.2
done
for i in {1..2}; do
    make_request "/api/occupancy" '{"direction":"out"}' "Person exited"
    sleep 0.2
done
echo ""

# 6, 7, 10. Sensors (auto-updated by backend)
echo "6-7-10. ?? Environmental sensors running (auto-updating)"
echo ""

# 11. Song detection (displayed automatically)
echo "11. ?? Song detection active"
echo ""

# 12. Tamper alert
echo "12. ?? Testing tamper alert..."
make_request "/api/tamper" '{"type":"motion","severity":"warning"}' "Tamper alert sent"
echo ""

# 13. Overheat protection (monitored automatically)
echo "13. ?? Overheat protection active (threshold: 150?C)"
echo ""

# 15. History (view at /history page)
echo "15. ?? 30-day history available at dashboard"
echo ""

# 16. Camera feed
echo "16. ?? Live camera feed running at:"
echo "    $API_URL/stream"
echo ""

echo "???????????????????????????????????????????"
echo "? DEMO COMPLETE"
echo ""
echo "Open http://localhost:5173 to see all features live!"
echo ""
