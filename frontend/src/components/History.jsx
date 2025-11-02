import React, { useState, useEffect } from 'react'
import axios from 'axios'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'

function History() {
  const [historyData, setHistoryData] = useState([])

  useEffect(() => {
    fetchHistory()
  }, [])

  const fetchHistory = async () => {
    try {
      const response = await axios.get('http://localhost:8000/api/history')
      setHistoryData(response.data)
    } catch (error) {
      console.error('Error fetching history:', error)
    }
  }

  const exportCSV = () => {
    window.open('http://localhost:8000/api/history/csv', '_blank')
  }

  return (
    <div className="history-container">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
        <h2 style={{ fontSize: '2rem', color: '#00ff88' }}>?? 30-DAY HISTORY</h2>
        <button className="export-btn" onClick={exportCSV}>
          Download CSV
        </button>
      </div>

      <div className="chart-container">
        <h3 style={{ color: '#00ff88', marginBottom: '1rem' }}>Occupancy Trend</h3>
        <ResponsiveContainer width="100%" height={400}>
          <LineChart data={historyData}>
            <CartesianGrid strokeDasharray="3 3" stroke="#333" />
            <XAxis dataKey="date" stroke="#888" />
            <YAxis stroke="#888" />
            <Tooltip 
              contentStyle={{ 
                background: 'rgba(20, 20, 40, 0.9)', 
                border: '1px solid #00ff88',
                borderRadius: '8px'
              }}
            />
            <Legend />
            <Line 
              type="monotone" 
              dataKey="occupancy" 
              stroke="#00ff88" 
              strokeWidth={3}
              dot={{ fill: '#00ff88', r: 5 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>

      <div className="chart-container">
        <h3 style={{ color: '#00ff88', marginBottom: '1rem' }}>Statistics Summary</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '2rem' }}>
          <div style={{ textAlign: 'center' }}>
            <div className="big-number">
              {historyData.length > 0 
                ? Math.round(historyData.reduce((sum, d) => sum + d.occupancy, 0) / historyData.length)
                : 0}
            </div>
            <div className="stat-label">AVG OCCUPANCY</div>
          </div>
          <div style={{ textAlign: 'center' }}>
            <div className="big-number">
              {historyData.length > 0 
                ? Math.max(...historyData.map(d => d.occupancy))
                : 0}
            </div>
            <div className="stat-label">PEAK OCCUPANCY</div>
          </div>
          <div style={{ textAlign: 'center' }}>
            <div className="big-number">{historyData.length}</div>
            <div className="stat-label">DAYS TRACKED</div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default History
