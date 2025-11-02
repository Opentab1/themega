import React, { useState, useEffect } from 'react'
import { io } from 'socket.io-client'
import axios from 'axios'
import CameraFeed from './CameraFeed'
import Heatmap from './Heatmap'
import TableGrid from './TableGrid'
import StaffLeaderboard from './StaffLeaderboard'
import SensorPanel from './SensorPanel'
import OccupancyCounter from './OccupancyCounter'
import GlassFlow from './GlassFlow'
import SongDetector from './SongDetector'
import TamperAlerts from './TamperAlerts'
import FlowPath from './FlowPath'

const API_URL = 'http://localhost:8000'

function Dashboard() {
  const [dashboardData, setDashboardData] = useState(null)
  const [socket, setSocket] = useState(null)

  useEffect(() => {
    // Connect to WebSocket
    const newSocket = io(API_URL)
    setSocket(newSocket)

    newSocket.on('connect', () => {
      console.log('Connected to server')
    })

    newSocket.on('dashboard_update', (data) => {
      console.log('Dashboard update:', data)
      fetchDashboardData()
    })

    newSocket.on('sensor_update', (data) => {
      setDashboardData(prev => prev ? {
        ...prev,
        environment: data
      } : null)
    })

    newSocket.on('alert', (alert) => {
      console.log('Alert:', alert)
      if (alert.type === 'overheat') {
        alert('?? OVERHEAT ALERT: ' + alert.message)
      }
    })

    return () => newSocket.close()
  }, [])

  useEffect(() => {
    fetchDashboardData()
    const interval = setInterval(fetchDashboardData, 5000)
    return () => clearInterval(interval)
  }, [])

  const fetchDashboardData = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/dashboard`)
      setDashboardData(response.data)
    } catch (error) {
      console.error('Error fetching dashboard data:', error)
    }
  }

  if (!dashboardData) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '80vh',
        fontSize: '2rem',
        color: '#00ff88'
      }}>
        Loading PULSE BAR AI...
      </div>
    )
  }

  return (
    <div className="dashboard-container">
      {/* 16. LIVE CAMERA FEED ? Full screen on dashboard */}
      <CameraFeed />

      {/* 8 & 9. People Counter + Total Occupancy */}
      <OccupancyCounter occupancy={dashboardData.occupancy} />

      {/* 1. Live Heatmap */}
      <Heatmap data={dashboardData.heatmap} />

      {/* 2. FlowPath Arrows */}
      <FlowPath />

      {/* 3. Glass Flow Lifecycle */}
      <GlassFlow />

      {/* 4. Service Timer per Table */}
      <TableGrid tables={dashboardData.tables} />

      {/* 5 & 14. Pour Counter + Staff Leaderboard */}
      <StaffLeaderboard staff={dashboardData.staff} />

      {/* 6, 7, 10. Decibel, Lux, Temperature */}
      <SensorPanel environment={dashboardData.environment} />

      {/* 11. Song Detection */}
      <SongDetector song={dashboardData.song} />

      {/* 12. Tamper Alerts */}
      <TamperAlerts alerts={dashboardData.tamper_alerts} />
    </div>
  )
}

export default Dashboard
