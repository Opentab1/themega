import React from 'react'

function SensorPanel({ environment }) {
  const isOverheat = environment.temperature > 150

  return (
    <div className="card">
      <div className="card-title">?? ENVIRONMENTAL SENSORS</div>
      <div className="sensor-grid">
        <div className="sensor-item">
          <div className="sensor-value" style={{ color: isOverheat ? '#ff0000' : '#00ff88' }}>
            {environment.temperature}?C
          </div>
          <div className="sensor-label">Temperature</div>
          {isOverheat && (
            <div style={{ color: '#ff0000', fontSize: '0.8rem', marginTop: '0.5rem' }}>
              ?? OVERHEAT
            </div>
          )}
        </div>
        <div className="sensor-item">
          <div className="sensor-value">{environment.decibel} dB</div>
          <div className="sensor-label">Decibel Meter</div>
        </div>
        <div className="sensor-item">
          <div className="sensor-value">{environment.lux} lx</div>
          <div className="sensor-label">Lux Meter</div>
        </div>
      </div>
    </div>
  )
}

export default SensorPanel
