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
        let searchArtist = artist.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !searchArtist.isEmpty else {
            songs = []
            errorMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            songs = try await apiService.fetchSongList(searchArtist)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
