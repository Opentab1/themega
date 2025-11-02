import React, { useRef, useEffect } from 'react'
import axios from 'axios'

function Heatmap({ data }) {
  const canvasRef = useRef(null)

  useEffect(() => {
    if (!canvasRef.current || !data) return

    const canvas = canvasRef.current
    const ctx = canvas.getContext('2d')
    const width = canvas.width
    const height = canvas.height

    // Clear canvas
    ctx.fillStyle = '#000'
    ctx.fillRect(0, 0, width, height)

    // Draw heatmap
    const cellWidth = width / 20
    const cellHeight = height / 20

    Object.entries(data).forEach(([key, intensity]) => {
      const [x, y] = key.split(',').map(Number)
      const normalizedIntensity = Math.min(intensity / 10, 1)
      
      ctx.fillStyle = `rgba(0, 255, 136, ${normalizedIntensity})`
      ctx.fillRect(x * cellWidth, y * cellHeight, cellWidth, cellHeight)
    })

    // Draw grid
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)'
    ctx.lineWidth = 1
    for (let i = 0; i <= 20; i++) {
      ctx.beginPath()
      ctx.moveTo(i * cellWidth, 0)
      ctx.lineTo(i * cellWidth, height)
      ctx.stroke()
      ctx.beginPath()
      ctx.moveTo(0, i * cellHeight)
      ctx.lineTo(width, i * cellHeight)
      ctx.stroke()
    }
  }, [data])

  const handleClick = async (e) => {
    const canvas = canvasRef.current
    const rect = canvas.getBoundingClientRect()
    const x = Math.floor((e.clientX - rect.left) / (rect.width / 20))
    const y = Math.floor((e.clientY - rect.top) / (rect.height / 20))

    try {
      await axios.post('http://localhost:8000/api/heatmap', { x, y })
    } catch (error) {
      console.error('Error adding heatmap point:', error)
    }
  }

  return (
    <div className="card">
      <div className="card-title">?? LIVE HEATMAP</div>
      <canvas
        ref={canvasRef}
        className="heatmap-container"
        width={800}
        height={400}
        onClick={handleClick}
        style={{ cursor: 'pointer' }}
      />
    </div>
  )
}

export default Heatmap
