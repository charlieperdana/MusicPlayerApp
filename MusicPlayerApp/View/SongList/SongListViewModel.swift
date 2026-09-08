//
//  SongListViewModel.swift
//  MusicPlayerApp
//
//  Created by charlie siagian on 08/09/26.
//

import Combine
import SwiftUI

@MainActor
final class SongListViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = SongAPI()

    func search(artist: String) async {
        isLoading = true
        errorMessage = nil

        do {
            songs = try await apiService.fetchSongList(artist)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
