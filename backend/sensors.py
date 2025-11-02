#!/usr/bin/env python3
"""
PULSE BAR AI ? Sensor Integration Module
Real sensor support + simulations for testing
"""

import time
import random
import threading

class SensorHub:
    """Central hub for all sensor data"""
    
    def __init__(self):
        self.sensors = {
            'temperature': None,
            'decibel': None,
            'lux': None,
            'people_counter': None
        }
        self.callbacks = []
        
    def register_callback(self, callback):
        """Register callback for sensor updates"""
        self.callbacks.append(callback)
    
    def update_sensor(self, sensor_type, value):
        """Update sensor value and notify callbacks"""
        self.sensors[sensor_type] = value
        for callback in self.callbacks:
            callback(sensor_type, value)

# BME280 Temperature Sensor
class BME280Sensor:
    """BME280 Temperature/Humidity/Pressure sensor"""
    
    def __init__(self, simulation=True):
        self.simulation = simulation
        self.temperature = 22.5
        
        if not simulation:
            try:
                import board
                import adafruit_bme280
                i2c = board.I2C()
                self.bme280 = adafruit_bme280.Adafruit_BME280_I2C(i2c)
            except Exception as e:
                print(f"??  BME280 not found, using simulation: {e}")
                self.simulation = True
    
    def read(self):
        """Read temperature in Celsius"""
        if self.simulation:
            # Simulate realistic bar temperature
            self.temperature += random.uniform(-0.5, 0.5)
            self.temperature = max(18, min(30, self.temperature))
            return round(self.temperature, 1)
        else:
            return round(self.bme280.temperature, 1)

# Decibel Meter
class DecibelMeter:
    """Sound level meter using microphone"""
    
    def __init__(self, simulation=True):
        self.simulation = simulation
        self.level = 75
        
        if not simulation:
            try:
                import pyaudio
                import numpy as np
                self.audio = pyaudio.PyAudio()
                self.stream = self.audio.open(
                    format=pyaudio.paInt16,
                    channels=1,
                    rate=44100,
                    input=True,
                    frames_per_buffer=1024
                )
            except Exception as e:
                print(f"??  Microphone not found, using simulation: {e}")
                self.simulation = True
    
    def read(self):
        """Read decibel level"""
        if self.simulation:
            # Simulate bar noise levels (60-90 dB typical)
            self.level += random.randint(-5, 5)
            self.level = max(60, min(95, self.level))
            return self.level
        else:
            # Read actual audio and calculate dB
            data = np.frombuffer(self.stream.read(1024), dtype=np.int16)
            rms = np.sqrt(np.mean(data**2))
            db = 20 * np.log10(rms + 1)
            return int(min(120, max(0, db)))

# Lux Meter
class LuxMeter:
    """Light sensor"""
    
    def __init__(self, simulation=True):
        self.simulation = simulation
        self.level = 450
        
        if not simulation:
            try:
                from smbus2 import SMBus
                self.bus = SMBus(1)
                self.address = 0x23
            except Exception as e:
                print(f"??  Lux sensor not found, using simulation: {e}")
                self.simulation = True
    
    def read(self):
        """Read lux level"""
        if self.simulation:
            # Simulate bar lighting (300-600 lux typical)
            self.level += random.randint(-20, 20)
            self.level = max(200, min(700, self.level))
            return self.level
        else:
            # Read from actual sensor
            data = self.bus.read_i2c_block_data(self.address, 0x20, 2)
            lux = (data[1] + (256 * data[0])) / 1.2
            return int(lux)

# People Counter (using camera or IR sensors)
class PeopleCounter:
    """Track people entering/exiting"""
    
    def __init__(self, simulation=True):
        self.simulation = simulation
        self.count_in = 0
        self.count_out = 0
        
    def detect_person(self, direction='in'):
        """Detect person entering or exiting"""
        if direction == 'in':
            self.count_in += 1
        else:
            self.count_out += 1
        return self.count_in, self.count_out

# Tamper Detection
class TamperDetector:
    """Detect physical tampering with device"""
    
    def __init__(self, simulation=True):
        self.simulation = simulation
        self.triggered = False
        
        if not simulation:
            try:
                import RPi.GPIO as GPIO
                GPIO.setmode(GPIO.BCM)
                GPIO.setup(17, GPIO.IN, pull_up_down=GPIO.PUD_UP)
                GPIO.add_event_detect(17, GPIO.FALLING, 
                                     callback=self._on_tamper, 
                                     bouncetime=200)
            except Exception as e:
                print(f"??  GPIO not available, using simulation: {e}")
                self.simulation = True
    
    def _on_tamper(self, channel):
        """Tamper switch callback"""
        self.triggered = True
    
    def check(self):
        """Check if tamper was detected"""
        if self.triggered:
            self.triggered = False
            return True
        return False

if __name__ == '__main__':
    # Test sensors
    print("?? Testing sensors...")
    
    temp = BME280Sensor(simulation=True)
    db = DecibelMeter(simulation=True)
    lux = LuxMeter(simulation=True)
    
    for i in range(10):
        print(f"???  Temp: {temp.read()}?C | ?? dB: {db.read()} | ?? Lux: {lux.read()}")
        time.sleep(1)
