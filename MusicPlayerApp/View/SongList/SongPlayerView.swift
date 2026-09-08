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
            HStack {
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.headline)
                    
                    Text(song.artist)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    audioManager.togglePlayPause()
                } label: {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                }
                .font(.title2)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}
