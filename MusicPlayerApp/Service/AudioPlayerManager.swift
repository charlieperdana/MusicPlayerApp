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
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var errorMessage: String?
    
    private(set) var songs: [Song] = []
    private(set) var currentIndex: Int?
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    private var statusObservation: NSKeyValueObservation?
    private var timeControlObservation: NSKeyValueObservation?
    
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?
    
    init() {
        configureAudioSession()
    }
    
    // MARK: - Audio Session
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("❌ Audio session error:", error)
        }
    }
    
    // MARK: - Playlist
    func setSongs(_ songs: [Song]) {
        self.songs = songs
        if let currentSong, let index = songs.firstIndex(where: {
               $0.id == currentSong.id
           }) {
            currentIndex = index
        } else if currentSong != nil {
            currentSong = nil
            currentIndex = nil
        }
    }
    
    func play(_ song: Song) {
        guard let index = songs.firstIndex(where: {
            $0.id == song.id
        }) else {
            print("❌ Song not found in playlist")
            return
        }
        
        currentIndex = index
        if currentSong?.id == song.id {
            togglePlayPause()
            return
        }
        startPlaying(song)
    }
    
    private func startPlaying(_ song: Song) {
        guard let url = song.previewURL else {
            errorMessage = "This song doesn't have a preview URL."
            isPlaying = false
            return
        }
        
        cleanupPlayer()
        
        currentSong = song
        currentTime = 0
        duration = song.duration
        errorMessage = nil

        let item = AVPlayerItem(url: url)
        playerItem = item
        player = AVPlayer(playerItem: item)
        observePlayer(item)
        observeTime()
        observeEnd(item)
        player?.play()
    }
    
    // MARK: - Next
    
    func playNext() {
        guard !songs.isEmpty, let currentIndex else {
            return
        }
        
        let nextIndex = currentIndex + 1
        guard nextIndex < songs.count else {
            print("⏭ Already at last song")
            return
        }
        
        self.currentIndex = nextIndex
        let nextSong = songs[nextIndex]
        startPlaying(nextSong)
    }
    
    func playPrevious() {
        guard !songs.isEmpty,
              let currentIndex else {
            return
        }
        
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        
        let previousIndex = currentIndex - 1
        guard previousIndex >= 0 else {
            print("⏮ Already at first song")
            return
        }
        
        self.currentIndex = previousIndex
        let previousSong = songs[previousIndex]
        startPlaying(previousSong)
    }
    
    var canPlayNext: Bool {
        guard let currentIndex else {
            return false
        }
        return currentIndex < songs.count - 1
    }
    
    var canPlayPrevious: Bool {
        guard let currentIndex else {
            return false
        }
        return currentIndex > 0 || currentTime > 3
    }
    
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
    
    private func observePlayer(_ item: AVPlayerItem) {
        statusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            Task { @MainActor in
                
                switch item.status {
                case .readyToPlay:
                    let seconds = item.duration.seconds
                    if seconds.isFinite && seconds > 0 {
                        self?.duration = seconds
                    }
                    
                case .failed:
                    self?.isPlaying = false
                    self?.errorMessage = item.error?.localizedDescription ?? "Unable to play."
                    
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
                    self?.isPlaying = true
                case .paused:
                    self?.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    self?.isPlaying = false
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - Progress
    private func observeTime() {
        guard let player else {
            return
        }
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(
                seconds: 0.5,
                preferredTimescale: 600
            ),
            queue: .main
        ) { [weak self] time in
            let seconds = time.seconds
            guard seconds.isFinite else {
                return
            }
            Task { @MainActor in
                self?.currentTime = seconds
            }
        }
    }
    
    // MARK: - Auto Next
    private func observeEnd(_ item: AVPlayerItem) {
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isPlaying = false
                self?.currentTime = 0
                self?.playNext()
            }
        }
    }
    
    // MARK: - Seek
    func seek(to time: TimeInterval) {
        guard let player else {
            return
        }
        let safeTime = max(0, min(time, duration))
        let time = CMTime(seconds: safeTime, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = safeTime
    }
    
    // MARK: - Stop
    func stop() {
        cleanupPlayer()
        currentSong = nil
        currentIndex = nil
        currentTime = 0
        duration = 0
        isPlaying = false
    }
    
    // MARK: - Cleanup
    private func cleanupPlayer() {
        player?.pause()
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
        statusObservation?.invalidate()
        timeControlObservation?.invalidate()
        statusObservation = nil
        timeControlObservation = nil
        if let endObserver {
            NotificationCenter.default.removeObserver(
                endObserver
            )
        }
        endObserver = nil
        playerItem = nil
        player = nil
    }
}
