//
//  Song.swift
//  MusicPlayerApp
//
//  Created by charlie siagian on 08/09/26.
//

import Foundation

struct SongListResponse: Codable {
    let resultCount: Int
    let results: [Song]
}

struct Song: Identifiable, Codable {
    let id: Int
    let title: String
    let artist: String
    let artworkURL: URL?
    let previewURL: URL?
    let durationMillis: Int

    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case title = "trackName"
        case artist = "artistName"
        case artworkURL = "artworkUrl100"
        case previewURL = "previewUrl"
        case durationMillis = "trackTimeMillis"
    }

    var duration: TimeInterval {
        TimeInterval(durationMillis) / 1000
    }
}
