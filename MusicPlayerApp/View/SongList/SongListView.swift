//
//  SongListView.swift
//  MusicPlayerApp
//
//  Created by charlie siagian on 08/09/26.
//

import SwiftUI

struct SongListView: View {
    @StateObject private var viewModel = SongListViewModel()
    @StateObject private var player = AudioPlayerManager()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading songs...")
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else {
                    List(viewModel.songs) { song in
                        SongRow(song: song, isPlaying: player.currentSong?.id == song.id && player.isPlaying) {
                            player.play(song)
                        }
                    }
                    
                    SongPlayerView(audioManager: player)
                }
            }
            .navigationTitle("Songs")
            .task {
                await viewModel.search(
                    artist: "Beyoncé"
                )
            }
        }
    }
}

