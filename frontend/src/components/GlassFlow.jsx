import React from 'react'

function GlassFlow() {
  const stages = [
    { icon: '??', label: 'Order', time: '0s' },
    { icon: '??', label: 'Pour', time: '15s' },
    { icon: '??', label: 'Serve', time: '45s' },
    { icon: '?', label: 'Delivered', time: '60s' }
  ]

  return (
    <div className="card">
      <div className="card-title">?? GLASS FLOW? LIFECYCLE</div>
      <div className="glass-flow">
        {stages.map((stage, index) => (
          <div key={index} className="glass-stage">
            <div className="stage-icon">{stage.icon}</div>
            <div style={{ fontSize: '1.25rem', fontWeight: 700, color: '#00ff88' }}>
              {stage.label}
            </div>
            <div style={{ fontSize: '0.9rem', color: '#888', marginTop: '0.5rem' }}>
              ~{stage.time}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

export default GlassFlow
