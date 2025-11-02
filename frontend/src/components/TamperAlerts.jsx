import React from 'react'

function TamperAlerts({ alerts }) {
  if (!alerts || alerts.length === 0) {
    return (
      <div className="card">
        <div className="card-title">?? TAMPER ALERTS</div>
        <div style={{ textAlign: 'center', color: '#00ff88', padding: '2rem' }}>
          ? All systems secure
        </div>
      </div>
    )
  }

  return (
    <div className="card">
      <div className="card-title">?? TAMPER ALERTS</div>
      <div className="alert-list">
        {alerts.map((alert, index) => (
          <div key={index} className={`alert-item ${alert.severity}`}>
            <div style={{ fontWeight: 700 }}>
              {alert.type.toUpperCase()} DETECTED
            </div>
            <div style={{ fontSize: '0.8rem', marginTop: '0.25rem' }}>
              {new Date(alert.timestamp).toLocaleString()}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

export default TamperAlerts
