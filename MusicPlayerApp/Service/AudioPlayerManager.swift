//
//  AudioPlayerManager.swift
//  MusicPlayerApp
//
//  Created by charlie siagian on 08/09/26.
//

import AVFoundation
import Combine

@MainActor
final class AudioPlayerManager: ObservableObject {
    @Published private(set) var currentSong: Song?
    @Published private(set) var isPlaying = false
    @Published private(set) var errorMessage: String?
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    private var statusObservation: NSKeyValueObservation?
    private var timeControlObservation: NSKeyValueObservation?
    
    init() {
        configureAudioSession()
    }
    
    // MARK: - Audio Session
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("❌ Audio session error:", error)
        }
    }
    
    // MARK: - Play
    
    func play(_ song: Song) {
        guard let url = song.previewURL else {
            errorMessage = "This song doesn't have a preview URL."
            print("❌ No preview URL for:", song.title)
            return
        }
        
        print("🎵 Playing:", song.title)
        print("🔗 URL:", url.absoluteString)
        
        // Tap current song = play/pause
        if currentSong?.id == song.id {
            togglePlayPause()
            return
        }
        
        // Clean up previous player
        cleanupPlayer()
        errorMessage = nil
        currentSong = song
        let item = AVPlayerItem(url: url)
        
        playerItem = item
        player = AVPlayer(playerItem: item)
        
        observePlayer(item: item)
        player?.automaticallyWaitsToMinimizeStalling = true
        player?.play()
        print("▶️ play() called")
    }
    
    // MARK: - Observe Player
    
    private func observePlayer(item: AVPlayerItem) {
        statusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            Task { @MainActor in
                switch item.status {
                case .readyToPlay:
                    print("✅ Player ready to play")
                case .failed:
                    let error = item.error
                    print("❌ Player failed")
                    print("❌ Error:", error?.localizedDescription ?? "Unknown")
                    self?.isPlaying = false
                    self?.errorMessage = error?.localizedDescription ?? "Unable to play this song."
                case .unknown:
                    print("⏳ Player status unknown")
                    
                @unknown default:
                    break
                }
            }
        }
        
        timeControlObservation = player?.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] player, _ in
            Task { @MainActor in
                switch player.timeControlStatus {
                case .playing:
                    print("▶️ Actually playing")
                    self?.isPlaying = true
                case .paused:
                    print("⏸ Paused")
                    self?.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    print("⏳ Waiting to play...")
                    self?.isPlaying = false
                    
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - Play / Pause
    
    func togglePlayPause() {
        guard let player else {
            return
        }
        
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    // MARK: - Stop
    
    func stop() {
        cleanupPlayer()
        currentSong = nil
        isPlaying = false
    }
    
    // MARK: - Cleanup
    
    private func cleanupPlayer() {
        player?.pause()
        statusObservation?.invalidate()
        timeControlObservation?.invalidate()
        statusObservation = nil
        timeControlObservation = nil
        playerItem = nil
        player = nil
    }
}
