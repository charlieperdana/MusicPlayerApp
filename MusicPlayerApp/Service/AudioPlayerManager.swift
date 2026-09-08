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

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?

    private var statusObservation: NSKeyValueObservation?
    private var timeControlObservation: NSKeyValueObservation?
    private var timeObserver: Any?

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

    // MARK: - Play

    func play(_ song: Song) {
        guard let url = song.previewURL else {
            errorMessage = "This song doesn't have a preview URL."
            return
        }

        // Same song → play/pause
        if currentSong?.id == song.id {
            togglePlayPause()
            return
        }

        cleanup()
        currentSong = song
        currentTime = 0
        duration = song.duration
        errorMessage = nil

        let item = AVPlayerItem(url: url)

        playerItem = item
        player = AVPlayer(playerItem: item)

        observePlayer(item)
        observeTime()
        player?.play()
    }

    // MARK: - Observe Player

    private func observePlayer(_ item: AVPlayerItem) {
        statusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            Task { @MainActor in
                switch item.status {
                case .readyToPlay:
                    print("✅ Player ready to play")
                    // Get actual duration from AVPlayer
                    let seconds = item.duration.seconds
                    if seconds.isFinite && seconds > 0 {
                        self?.duration = seconds
                    }

                case .failed:
                    print("❌ Player failed:", item.error?.localizedDescription ?? "Unknown")
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

    // MARK: - Time Observer

    private func observeTime() {
        guard let player else {
            return
        }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            let seconds = time.seconds
            guard seconds.isFinite else {
                return
            }
            Task { @MainActor in
                self?.currentTime = seconds
            }
        }
    }

    // MARK: - Seek

    func seek(to time: TimeInterval) {
        guard let player else {
            return
        }
        let safeTime = max(0, min(time, duration))
        let cmTime = CMTime(seconds: safeTime, preferredTimescale: 600)
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = safeTime
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
        cleanup()
        currentSong = nil
        currentTime = 0
        duration = 0
        isPlaying = false
    }

    // MARK: - Cleanup

    private func cleanup() {
        player?.pause()
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }

        timeObserver = nil
        statusObservation?.invalidate()
        timeControlObservation?.invalidate()

        statusObservation = nil
        timeControlObservation = nil

        playerItem = nil
        player = nil
    }

    deinit {
        statusObservation?.invalidate()
        timeControlObservation?.invalidate()
    }
}
