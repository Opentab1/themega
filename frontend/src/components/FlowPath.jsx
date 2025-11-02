import React, { useRef, useEffect } from 'react'

function FlowPath() {
  const canvasRef = useRef(null)

  useEffect(() => {
    if (!canvasRef.current) return

    const canvas = canvasRef.current
    const ctx = canvas.getContext('2d')
    const width = canvas.width
    const height = canvas.height

    // Clear canvas
    ctx.fillStyle = '#000'
    ctx.fillRect(0, 0, width, height)

    // Draw flow paths with arrows
    const paths = [
      { from: { x: 100, y: 200 }, to: { x: 300, y: 200 }, label: 'Entry' },
      { from: { x: 300, y: 200 }, to: { x: 400, y: 100 }, label: 'Bar' },
      { from: { x: 400, y: 100 }, to: { x: 600, y: 150 }, label: 'Seating' },
      { from: { x: 600, y: 150 }, to: { x: 700, y: 300 }, label: 'Exit' }
    ]

    paths.forEach(path => {
      // Draw line
      ctx.strokeStyle = '#00ff88'
      ctx.lineWidth = 4
      ctx.beginPath()
      ctx.moveTo(path.from.x, path.from.y)
      ctx.lineTo(path.to.x, path.to.y)
      ctx.stroke()

      // Draw arrow
      const angle = Math.atan2(path.to.y - path.from.y, path.to.x - path.from.x)
      const arrowSize = 15
      ctx.fillStyle = '#00ff88'
      ctx.beginPath()
      ctx.moveTo(path.to.x, path.to.y)
      ctx.lineTo(
        path.to.x - arrowSize * Math.cos(angle - Math.PI / 6),
        path.to.y - arrowSize * Math.sin(angle - Math.PI / 6)
      )
      ctx.lineTo(
        path.to.x - arrowSize * Math.cos(angle + Math.PI / 6),
        path.to.y - arrowSize * Math.sin(angle + Math.PI / 6)
      )
      ctx.closePath()
      ctx.fill()

      // Draw label
      ctx.fillStyle = '#fff'
      ctx.font = '14px sans-serif'
      ctx.fillText(path.label, path.from.x, path.from.y - 10)
    })
  }, [])

  return (
    <div className="card">
      <div className="card-title">?? FLOWPATH? ARROWS</div>
      <canvas
        ref={canvasRef}
        width={800}
        height={400}
        className="flowpath-canvas"
      />
    </div>
  )
}

export default FlowPath
