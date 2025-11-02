import React from 'react'

function CameraFeed() {
  return (
    <div className="card camera-card">
      <img 
        src="http://localhost:8000/stream" 
        className="camera-full"
        alt="Live Camera Feed"
      />
    </div>
  )
}

export default CameraFeed
