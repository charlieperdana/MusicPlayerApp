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
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Search artist or song", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                        .onSubmit {
                            search()
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    Color(.systemGray6)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Something went wrong", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if viewModel.songs.isEmpty {
                    Spacer()
                    ContentUnavailableView("No Songs", systemImage: "music.note.list", description: Text("Search for an artist or song."))
                    Spacer()
                } else {
                    List(viewModel.songs) { song in
                        SongRow(song: song, isPlaying: player.currentSong?.id == song.id && player.isPlaying) {
                            player.play(song)
                        }
                    }
                    .listStyle(.plain)
                }
                
                // MARK: - Player
                SongPlayerView(
                    audioManager: player
                )
            }
            .navigationTitle("Songs")
        }
    }
    
    private func search() {
        let artistSearch = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !artistSearch.isEmpty else {
            return
        }
        Task {
            await viewModel.search(artist: artistSearch)
        }
    }
}

