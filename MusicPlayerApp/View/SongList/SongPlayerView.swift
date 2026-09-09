//
//  SongPlayerView.swift
//  MusicPlayerApp
//
//  Created by charlie siagian on 08/09/26.
//

import SwiftUI

struct SongPlayerView: View {
    @ObservedObject var audioManager: AudioPlayerManager
    
    var body: some View {
        if let song = audioManager.currentSong {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(song.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Text(song.artist)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                
                VStack(spacing: 4) {
                    Slider(
                        value: Binding(
                            get: {
                                audioManager.currentTime
                            },
                            set: { value in
                                audioManager.seek(
                                    to: value
                                )
                            }
                        ),
                        in: 0...max(audioManager.duration, 0.1)
                    )
                    
                    HStack {
                        Text(formatTime(audioManager.currentTime))
                        Spacer()
                        Text("-\(formatTime(max(audioManager.duration - audioManager.currentTime,0)))")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                HStack {
                    Button {
                        audioManager.playPrevious()
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                    }
                    .disabled(
                        !audioManager.canPlayPrevious
                    )
                    Spacer()
                    Button {
                        audioManager.togglePlayPause()
                    } label: {
                        Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 42))
                    }
                    Spacer()
                    Button {
                        audioManager.playNext()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                    }
                    .disabled(
                        !audioManager.canPlayNext
                    )
                }
                .padding(.horizontal, 40)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite else {
            return "0:00"
        }
        
        let totalSeconds = max(Int(time), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%d:%02d", minutes,seconds)
    }
}
