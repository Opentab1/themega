import React from 'react'
import axios from 'axios'

function TableGrid({ tables }) {
  const handleTableClick = async (tableId, currentStatus) => {
    const statuses = ['empty', 'occupied', 'service']
    const nextStatus = statuses[(statuses.indexOf(currentStatus) + 1) % statuses.length]
    
    try {
      await axios.post(`http://localhost:8000/api/table/${tableId}`, { status: nextStatus })
    } catch (error) {
      console.error('Error updating table:', error)
    }
  }

  return (
    <div className="card">
      <div className="card-title">??? SERVICE TIMER? PER TABLE</div>
      <div className="table-grid">
        {tables.map(table => (
          <div
            key={table.id}
            className={`table-item ${table.status}`}
            onClick={() => handleTableClick(table.id, table.status)}
          >
            <div style={{ fontSize: '1.5rem', fontWeight: 700 }}>
              T{table.id}
            </div>
            {table.timer > 0 && (
              <div className="table-timer">{table.timer}m</div>
            )}
            <div style={{ 
              fontSize: '0.8rem', 
              textTransform: 'uppercase',
              marginTop: '0.5rem',
              color: table.status === 'empty' ? '#666' : '#00ff88'
            }}>
              {table.status}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

export default TableGrid
