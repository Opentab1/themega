import React from 'react'
import axios from 'axios'

function OccupancyCounter({ occupancy }) {
  const handleCount = async (direction) => {
    try {
      await axios.post('http://localhost:8000/api/occupancy', { direction })
    } catch (error) {
      console.error('Error updating occupancy:', error)
    }
  }

  return (
    <div className="card">
      <div className="card-title">?? PEOPLE COUNTER</div>
      <div className="occupancy-grid">
        <div className="occupancy-item" onClick={() => handleCount('in')} style={{ cursor: 'pointer' }}>
          <div className="big-number">{occupancy.in}</div>
          <div className="stat-label">IN</div>
        </div>
        <div className="occupancy-item">
          <div className="huge-number">{occupancy.total}</div>
          <div className="stat-label">OCCUPANCY</div>
        </div>
        <div className="occupancy-item" onClick={() => handleCount('out')} style={{ cursor: 'pointer' }}>
          <div className="big-number">{occupancy.out}</div>
          <div className="stat-label">OUT</div>
        </div>
      </div>
    </div>
  )
}

export default OccupancyCounter
