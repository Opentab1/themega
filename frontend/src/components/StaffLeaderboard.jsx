import React from 'react'
import axios from 'axios'

function StaffLeaderboard({ staff }) {
  const handleAddPour = async (staffName) => {
    try {
      await axios.post('http://localhost:8000/api/pour', { staff: staffName })
    } catch (error) {
      console.error('Error adding pour:', error)
    }
  }

  return (
    <div className="card">
      <div className="card-title">?? POUR COUNTER LEADERBOARD</div>
      <div className="leaderboard-list">
        {staff.map((member, index) => (
          <div 
            key={member.name} 
            className="leaderboard-item"
            onClick={() => handleAddPour(member.name)}
            style={{ cursor: 'pointer' }}
          >
            <div className="leaderboard-rank">#{index + 1}</div>
            <div>
              <div className="leaderboard-name">{member.name}</div>
              <div style={{ fontSize: '0.8rem', color: '#888' }}>
                {member.tables} tables ? ? {member.rating}
              </div>
            </div>
            <div className="leaderboard-pours">{member.pours} ??</div>
          </div>
        ))}
      </div>
    </div>
  )
}

export default StaffLeaderboard
