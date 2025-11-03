#!/bin/bash
# Test REAL sensor hardware on Raspberry Pi

echo "???????????????????????????????????"
echo "?? TESTING REAL SENSOR HARDWARE"
echo "???????????????????????????????????"
echo ""

cd /workspace

python3 << 'EOF'
import sys
import time

print("?? Initializing REAL sensors...")
print("")

# Test BME280 Temperature Sensor
print("???  Testing BME280 (Address: 0x77)...")
try:
    import board
    import adafruit_bme280
    i2c = board.I2C()
    bme280 = adafruit_bme280.Adafruit_BME280_I2C(i2c, address=0x77)
    print(f"   ? BME280 Connected!")
    print(f"   ???  Temperature: {bme280.temperature:.1f}?C")
    print(f"   ?? Humidity: {bme280.humidity:.1f}%")
    print(f"   ?? Pressure: {bme280.pressure:.1f} hPa")
    bme280_working = True
except Exception as e:
    print(f"   ? BME280 Failed: {e}")
    bme280_working = False

print("")

# Test Microphone
print("?? Testing USB Microphone...")
try:
    import pyaudio
    import numpy as np
    
    audio = pyaudio.PyAudio()
    
    # Find the USB device
    device_index = None
    for i in range(audio.get_device_count()):
        info = audio.get_device_info_by_index(i)
        if 'USB' in info['name'] and info['maxInputChannels'] > 0:
            device_index = i
            print(f"   ? Found: {info['name']}")
            break
    
    if device_index is not None:
        stream = audio.open(
            format=pyaudio.paInt16,
            channels=1,
            rate=44100,
            input=True,
            input_device_index=device_index,
            frames_per_buffer=1024
        )
        
        # Read audio and calculate dB
        data = np.frombuffer(stream.read(1024), dtype=np.int16)
        rms = np.sqrt(np.mean(data**2))
        db = 20 * np.log10(rms + 1) if rms > 0 else 0
        db = min(120, max(0, db))
        
        print(f"   ?? Current Sound Level: {int(db)} dB")
        
        stream.stop_stream()
        stream.close()
        audio.terminate()
        mic_working = True
    else:
        print("   ??  USB audio device not found")
        audio.terminate()
        mic_working = False
        
except Exception as e:
    print(f"   ? Microphone Failed: {e}")
    mic_working = False

print("")
print("???????????????????????????????????")

if bme280_working and mic_working:
    print("? ALL REAL SENSORS WORKING!")
elif bme280_working or mic_working:
    print("??  SOME SENSORS WORKING")
else:
    print("? NO SENSORS DETECTED")
    
print("???????????????????????????????????")
print("")

# Now run continuous monitoring
if bme280_working or mic_working:
    print("?? Starting 10-second continuous monitoring...")
    print("   (Press Ctrl+C to stop)")
    print("")
    
    try:
        # Reinitialize for continuous use
        if bme280_working:
            import board
            import adafruit_bme280
            i2c = board.I2C()
            bme = adafruit_bme280.Adafruit_BME280_I2C(i2c, address=0x77)
        
        if mic_working:
            import pyaudio
            import numpy as np
            audio = pyaudio.PyAudio()
            for i in range(audio.get_device_count()):
                info = audio.get_device_info_by_index(i)
                if 'USB' in info['name'] and info['maxInputChannels'] > 0:
                    mic_index = i
                    break
            stream = audio.open(
                format=pyaudio.paInt16,
                channels=1,
                rate=44100,
                input=True,
                input_device_index=mic_index,
                frames_per_buffer=1024
            )
        
        for i in range(10):
            output = f"   "
            
            if bme280_working:
                temp = bme.temperature
                output += f"??? {temp:.1f}?C  "
            
            if mic_working:
                data = np.frombuffer(stream.read(1024), dtype=np.int16)
                rms = np.sqrt(np.mean(data**2))
                db = 20 * np.log10(rms + 1) if rms > 0 else 0
                db = int(min(120, max(0, db)))
                output += f"?? {db} dB"
            
            print(output)
            time.sleep(1)
        
        if mic_working:
            stream.stop_stream()
            stream.close()
            audio.terminate()
            
    except KeyboardInterrupt:
        print("\n??  Stopped by user")
    except Exception as e:
        print(f"\n? Error during monitoring: {e}")

EOF

echo ""
echo "? Test complete!"
echo ""
echo "To use these sensors in the app, the backend needs to"
echo "be configured to use simulation=False instead of True."
