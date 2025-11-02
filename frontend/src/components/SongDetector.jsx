import React from 'react'

function SongDetector({ song }) {
  return (
    <div className="card">
      <div className="card-title">?? SONG DETECTION</div>
      <div className="song-display">
        <div className="song-title">{song.title}</div>
        <div className="song-artist">{song.artist}</div>
      </div>
    </div>
  )
}

export default SongDetector
