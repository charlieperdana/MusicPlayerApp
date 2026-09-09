# MusicPlayerApp

A SwiftUI-based iOS music player application that allows users to search for songs and artists using the iTunes Search API and play available audio previews using `AVPlayer`.

## Features

- Search for songs and artists
- Fetch music data from the iTunes Search API
- Display song title, artist, and artwork
- Play and pause audio previews
- Previous and next song navigation
- Playback progress tracking
- Automatically play the next song
- Handle networking and playback errors
- Unit testing with Swift Testing
- Dependency injection for testable networking
- GitHub Actions CI/CD
- Automated application build and test

## Screenshots

| Song List Empty | Music Player |
| --- | --- |
| <img width="1206" height="2622" alt="Simulator Screenshot - Clone 1 of iPhone 17 Pro - 2026-09-09 at 20 42 05" src="https://github.com/user-attachments/assets/189d1925-7b0c-4adf-ac9f-1c2f7b4853ca" /> | <img width="1206" height="2622" alt="Simulator Screenshot - Clone 1 of iPhone 17 Pro - 2026-09-09 at 20 42 40" src="https://github.com/user-attachments/assets/afd950f6-a7d3-4bc8-9c73-6eec0118cc50" /> |

## Architecture Explanation

The application uses a simple layered MVVM architecture to separate the view, networking, data, and playback responsibilities.

```text
MusicPlayerApp
│
├── App
│   └── MusicPlayerAppApp.swift
│
├── Models
│   └── Song.swift
│
├── Networking
│   ├── APIError.swift
│   ├── HTTPClient.swift
│   └── SongAPI.swift
│
├── Service
│   └── AudioPlayerManager.swift
│
├── View
│   └── SongList
│       ├── SongListView.swift
│       ├── SongListViewModel.swift
│       ├── SongPlayerView.swift
│       └── SongRow.swift
│
├── Assets
│   └── Assets.xcassets
│
├── MusicPlayerAppTests
│   ├── mock
│   │   └── MockHTTPClient.swift
│   ├── AudioPlayerManagerTests.swift
│   ├── MusicPlayerAppTests.swift
│   └── SongAPITests.swift
│
├── MusicPlayerAppUITests
│   ├── MusicPlayerAppUITests.swift
│   └── MusicPlayerAppUITestsLaunchTests.swift
│
├── .github
│   └── workflows
│       └── ios.yml
│
├── MusicPlayerApp.xcodeproj
└── README.md
```

## Technologies
- Swift
- SwiftUI
- AVFoundation
- AVPlayer
- URLSession
- Swift Concurrency (async/await)
- Swift Testing
- Xcode
- GitHub Actions

## Run the Application
- Open the project in Xcode.
- Select the MusicPlayerApp scheme.
- Select an iPhone simulator or a connected iOS device.
- Press ⌘ + R or select Product → Run.

## Usage
- Launch the application.
- Enter an artist or song name in the search field.
- Start the search.
- Select a song from the search results.
- Use the player controls to:
- Play or pause the song
- Play the next song
- Return to the previous song
- Seek through the preview
- When a preview finishes, the player automatically moves to the next available song.
