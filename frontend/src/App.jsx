import React, { useState, useEffect } from 'react'
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom'
import Dashboard from './components/Dashboard'
import History from './components/History'
import './index.css'

function App() {
  const [currentView, setCurrentView] = useState('dashboard')

  return (
    <div className="app">
      <header className="header">
        <h1>?? PULSE BAR AI</h1>
        <div className="header-nav">
          <button 
            className={`nav-btn ${currentView === 'dashboard' ? 'active' : ''}`}
            onClick={() => setCurrentView('dashboard')}
          >
            Live Dashboard
          </button>
          <button 
            className={`nav-btn ${currentView === 'history' ? 'active' : ''}`}
            onClick={() => setCurrentView('history')}
          >
            30-Day History
          </button>
        </div>
      </header>
      
      {currentView === 'dashboard' ? <Dashboard /> : <History />}
    </div>
  )
}

export default App
