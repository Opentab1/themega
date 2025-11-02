#!/usr/bin/env python3
"""
PULSE BAR AI ? Backend Server
Flask API + MJPEG Camera Stream + Sensor Hub
"""

from flask import Flask, Response, jsonify, request, send_from_directory
from flask_cors import CORS
from flask_socketio import SocketIO, emit
import cv2
import json
import sqlite3
import threading
import time
from datetime import datetime, timedelta
import numpy as np
from collections import defaultdict
import os

app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

# Database setup
DB_PATH = 'pulse_bar.db'

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    # Tables
    c.execute('''CREATE TABLE IF NOT EXISTS events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        event_type TEXT,
        data TEXT
    )''')
    
    c.execute('''CREATE TABLE IF NOT EXISTS heatmap (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        x INTEGER,
        y INTEGER,
        intensity INTEGER
    )''')
    
    c.execute('''CREATE TABLE IF NOT EXISTS staff (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        pours INTEGER DEFAULT 0,
        tables_served INTEGER DEFAULT 0,
        rating REAL DEFAULT 5.0
    )''')
    
    c.execute('''CREATE TABLE IF NOT EXISTS tables (
        id INTEGER PRIMARY KEY,
        status TEXT DEFAULT 'empty',
        timer_start DATETIME,
        staff_id INTEGER
    )''')
    
    c.execute('''CREATE TABLE IF NOT EXISTS occupancy (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        count_in INTEGER,
        count_out INTEGER,
        total INTEGER
    )''')
    
    # Initialize tables
    for i in range(1, 21):
        c.execute("INSERT OR IGNORE INTO tables (id, status) VALUES (?, 'empty')", (i,))
    
    # Initialize staff
    staff_names = ['Alex', 'Jordan', 'Casey', 'Morgan', 'Taylor']
    for name in staff_names:
        c.execute("INSERT OR IGNORE INTO staff (name) VALUES (?)", (name,))
    
    conn.commit()
    conn.close()

init_db()

# Global state
state = {
    'camera_active': True,
    'occupancy_in': 47,
    'occupancy_out': 12,
    'occupancy_total': 35,
    'temperature': 22.5,
    'decibel': 75,
    'lux': 450,
    'song_title': 'Blinding Lights',
    'song_artist': 'The Weeknd',
    'tamper_alerts': [],
    'heatmap_data': defaultdict(int),
    'flowpath_data': []
}

# Camera setup
class CameraStream:
    def __init__(self):
        self.camera = None
        self.frame = None
        self.lock = threading.Lock()
        self.running = False
        
    def start(self):
        self.running = True
        # Try to open camera (0 = default, -1 for simulation)
        try:
            self.camera = cv2.VideoCapture(0)
            if not self.camera.isOpened():
                raise Exception("Camera not found")
        except:
            print("??  No camera found, using simulation mode")
            self.camera = None
        
        threading.Thread(target=self._update_frame, daemon=True).start()
    
    def _update_frame(self):
        while self.running:
            if self.camera and self.camera.isOpened():
                ret, frame = self.camera.read()
                if ret:
                    with self.lock:
                        self.frame = frame
            else:
                # Generate simulation frame
                frame = np.zeros((480, 640, 3), dtype=np.uint8)
                cv2.putText(frame, 'PULSE BAR AI', (150, 240), 
                           cv2.FONT_HERSHEY_BOLD, 2, (0, 255, 0), 3)
                cv2.putText(frame, f'Time: {datetime.now().strftime("%H:%M:%S")}', 
                           (180, 300), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
                with self.lock:
                    self.frame = frame
            time.sleep(0.03)  # ~30 FPS
    
    def get_frame(self):
        with self.lock:
            if self.frame is None:
                return None
            _, jpeg = cv2.imencode('.jpg', self.frame)
            return jpeg.tobytes()
    
    def stop(self):
        self.running = False
        if self.camera:
            self.camera.release()

camera_stream = CameraStream()
camera_stream.start()

def generate_mjpeg():
    """Generate MJPEG stream"""
    while True:
        frame = camera_stream.get_frame()
        if frame:
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
        time.sleep(0.03)

@app.route('/stream')
def stream():
    """MJPEG camera stream endpoint"""
    return Response(generate_mjpeg(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/api/dashboard')
def get_dashboard():
    """Get all dashboard data"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    # Get staff leaderboard
    c.execute("SELECT name, pours, tables_served, rating FROM staff ORDER BY pours DESC LIMIT 5")
    staff = [{'name': r[0], 'pours': r[1], 'tables': r[2], 'rating': r[3]} for r in c.fetchall()]
    
    # Get tables
    c.execute("SELECT id, status, timer_start, staff_id FROM tables")
    tables = []
    for r in c.fetchall():
        timer = 0
        if r[2]:
            start = datetime.fromisoformat(r[2])
            timer = int((datetime.now() - start).total_seconds() / 60)
        tables.append({'id': r[0], 'status': r[1], 'timer': timer, 'staff_id': r[3]})
    
    conn.close()
    
    return jsonify({
        'occupancy': {
            'in': state['occupancy_in'],
            'out': state['occupancy_out'],
            'total': state['occupancy_total']
        },
        'environment': {
            'temperature': state['temperature'],
            'decibel': state['decibel'],
            'lux': state['lux']
        },
        'song': {
            'title': state['song_title'],
            'artist': state['song_artist']
        },
        'staff': staff,
        'tables': tables,
        'tamper_alerts': state['tamper_alerts'][-5:],
        'heatmap': dict(state['heatmap_data'])
    })

@app.route('/api/history')
def get_history():
    """Get 30-day history"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    thirty_days_ago = datetime.now() - timedelta(days=30)
    
    c.execute("""
        SELECT DATE(timestamp) as date, AVG(total) as avg_occupancy
        FROM occupancy
        WHERE timestamp > ?
        GROUP BY DATE(timestamp)
        ORDER BY date
    """, (thirty_days_ago,))
    
    history = [{'date': r[0], 'occupancy': round(r[1], 1)} for r in c.fetchall()]
    conn.close()
    
    return jsonify(history)

@app.route('/api/history/csv')
def get_history_csv():
    """Export CSV of 30-day history"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    thirty_days_ago = datetime.now() - timedelta(days=30)
    c.execute("SELECT * FROM events WHERE timestamp > ?", (thirty_days_ago,))
    
    csv_data = "timestamp,event_type,data\n"
    for row in c.fetchall():
        csv_data += f"{row[1]},{row[2]},{row[3]}\n"
    
    conn.close()
    
    return Response(csv_data, mimetype='text/csv',
                    headers={'Content-Disposition': 'attachment; filename=pulse_bar_history.csv'})

@app.route('/api/pour', methods=['POST'])
def add_pour():
    """Add pour to staff member"""
    data = request.json
    staff_name = data.get('staff')
    
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("UPDATE staff SET pours = pours + 1 WHERE name = ?", (staff_name,))
    conn.commit()
    conn.close()
    
    socketio.emit('dashboard_update', {'type': 'pour', 'staff': staff_name})
    return jsonify({'success': True})

@app.route('/api/table/<int:table_id>', methods=['POST'])
def update_table(table_id):
    """Update table status"""
    data = request.json
    status = data.get('status', 'empty')
    
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    if status == 'occupied':
        c.execute("UPDATE tables SET status = ?, timer_start = ? WHERE id = ?",
                 (status, datetime.now(), table_id))
    else:
        c.execute("UPDATE tables SET status = ?, timer_start = NULL WHERE id = ?",
                 (status, table_id))
    
    conn.commit()
    conn.close()
    
    socketio.emit('dashboard_update', {'type': 'table', 'id': table_id, 'status': status})
    return jsonify({'success': True})

@app.route('/api/occupancy', methods=['POST'])
def update_occupancy():
    """Update occupancy count"""
    data = request.json
    direction = data.get('direction')  # 'in' or 'out'
    
    if direction == 'in':
        state['occupancy_in'] += 1
        state['occupancy_total'] += 1
    else:
        state['occupancy_out'] += 1
        state['occupancy_total'] -= 1
    
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("INSERT INTO occupancy (count_in, count_out, total) VALUES (?, ?, ?)",
             (state['occupancy_in'], state['occupancy_out'], state['occupancy_total']))
    conn.commit()
    conn.close()
    
    socketio.emit('dashboard_update', {'type': 'occupancy', 'data': {
        'in': state['occupancy_in'],
        'out': state['occupancy_out'],
        'total': state['occupancy_total']
    }})
    
    return jsonify({'success': True})

@app.route('/api/heatmap', methods=['POST'])
def add_heatmap_point():
    """Add heatmap data point"""
    data = request.json
    x, y = data.get('x'), data.get('y')
    
    key = f"{x},{y}"
    state['heatmap_data'][key] += 1
    
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("INSERT INTO heatmap (x, y, intensity) VALUES (?, ?, ?)",
             (x, y, state['heatmap_data'][key]))
    conn.commit()
    conn.close()
    
    return jsonify({'success': True})

@app.route('/api/tamper', methods=['POST'])
def tamper_alert():
    """Record tamper alert"""
    data = request.json
    alert = {
        'timestamp': datetime.now().isoformat(),
        'type': data.get('type', 'motion'),
        'severity': data.get('severity', 'warning')
    }
    state['tamper_alerts'].append(alert)
    
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("INSERT INTO events (event_type, data) VALUES (?, ?)",
             ('tamper', json.dumps(alert)))
    conn.commit()
    conn.close()
    
    socketio.emit('alert', alert)
    return jsonify({'success': True})

# Simulate sensor updates
def simulate_sensors():
    """Background thread to simulate sensor readings"""
    while True:
        time.sleep(5)
        
        # Random variations
        state['temperature'] = round(22 + np.random.uniform(-2, 2), 1)
        state['decibel'] = int(75 + np.random.uniform(-10, 15))
        state['lux'] = int(450 + np.random.uniform(-50, 100))
        
        # Overheat check
        if state['temperature'] > 150:
            socketio.emit('alert', {
                'type': 'overheat',
                'temperature': state['temperature'],
                'message': 'AUTO-SHUTDOWN TRIGGERED'
            })
        
        # Broadcast updates
        socketio.emit('sensor_update', {
            'temperature': state['temperature'],
            'decibel': state['decibel'],
            'lux': state['lux']
        })

threading.Thread(target=simulate_sensors, daemon=True).start()

@socketio.on('connect')
def handle_connect():
    print('Client connected')
    emit('connected', {'status': 'ok'})

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

if __name__ == '__main__':
    print("?? PULSE BAR AI ? Backend Starting")
    print("?? Camera stream: http://localhost:8000/stream")
    print("?? API: http://localhost:8000/api/dashboard")
    socketio.run(app, host='0.0.0.0', port=8000, debug=False)
