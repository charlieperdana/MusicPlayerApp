//
//  AudioPlayerManagerTests.swift
//  MusicPlayerAppTests
//
//  Created by charlie siagian on 09/09/26.
//

import Testing
import Foundation
@testable import MusicPlayerApp

@MainActor
struct AudioPlayerManagerTests {
    
    private func makeSong(id: Int,title: String) -> Song {
        Song(id: id,
             title: title,
             artist: "Beyoncé",
             artworkURL: nil,
             previewURL: URL(
                string: "https://example.com/\(id).m4a"
             ),
             durationMillis: 292792
        )
    }

    @Test
    func setSongsCreatesPlaylist() {
        let player = AudioPlayerManager()

        let songs = [
            makeSong(id: 1, title: "Song One"),
            makeSong(id: 2, title: "Song Two"),
            makeSong(id: 3, title: "Song Three")
        ]

        // When
        player.setSongs(songs)

        // Then
        #expect(player.canPlayNext == false)
        #expect(player.canPlayPrevious == false)
    }
    
    @Test
    func playSongSetsCurrentSong() {
        let player = AudioPlayerManager()

        let song = makeSong(id: 1, title: "Halo")
        player.setSongs([song])

        // When
        player.play(song)

        // Then
        #expect(player.currentSong?.id == song.id)
        #expect(player.currentSong?.title == "Halo")
    }
    
    @Test
    func playNextMovesToNextSong() {
        let player = AudioPlayerManager()

        let song1 = makeSong(id: 1, title: "Song One")
        let song2 = makeSong(id: 2, title: "Song Two")
        let song3 = makeSong(id: 3, title: "Song Three")

        player.setSongs([song1, song2, song3])
        player.play(song1)

        // When
        player.playNext()
        
        // Then
        #expect(player.currentSong?.id == song2.id)
    }
    
    @Test
    func playNextMovesThroughPlaylist() {
        let player = AudioPlayerManager()
        let song1 = makeSong(id: 1, title: "Song One")
        let song2 = makeSong(id: 2, title: "Song Two")
        let song3 = makeSong(id: 3, title: "Song Three")

        player.setSongs([song1, song2, song3])
        player.play(song1)

        // When
        player.playNext()
        player.playNext()

        // Then
        #expect(player.currentSong?.id == song3.id)
        #expect(player.canPlayNext == false)
    }
    
    @Test
    func playNextDoesNothingAtLastSong() {
        // Given
        let player = AudioPlayerManager()
        let song1 = makeSong(id: 1, title: "One")
        let song2 = makeSong(id: 2, title: "Two")

        player.setSongs([song1, song2])
        player.play(song2)

        // When
        player.playNext()

        // Then
        #expect(player.currentSong?.id == song2.id)
        #expect(player.canPlayNext == false)
    }
    
    @Test
    func playPreviousMovesToPreviousSong() {
        // Given
        let player = AudioPlayerManager()
        let song1 = makeSong(id: 1, title: "One")
        let song2 = makeSong(id: 2, title: "Two")
        let song3 = makeSong(id: 3, title: "Three")

        player.setSongs([song1, song2, song3])
        player.play(song2)
        
        // When
        player.playPrevious()

        // Then
        #expect(player.currentSong?.id == song1.id)
    }
    
    @Test
    func playPreviousDoesNothingAtFirstSong() {
        // Given
        let player = AudioPlayerManager()

        let song1 = makeSong(id: 1, title: "One")
        let song2 = makeSong(id: 2, title: "Two")
        
        player.setSongs([song1,song2])
        player.play(song1)

        // When
        player.playPrevious()

        // Then
        #expect(player.currentSong?.id == song1.id)

        #expect(player.canPlayPrevious == false)
    }
    
    @Test
    func playSongWithoutPreviewShowsError() {
        // Given
        let player = AudioPlayerManager()
        let song = Song(
            id: 1,
            title: "No Preview",
            artist: "Beyoncé",
            artworkURL: nil,
            previewURL: nil,
            durationMillis: 30000
        )

        player.setSongs([song])
        // When
        player.play(song)
        // Then
        #expect(player.currentSong == nil)
        #expect(player.isPlaying == false)
        #expect(player.errorMessage == "This song doesn't have a preview URL.")
    }

}
