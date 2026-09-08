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
    let duration: TimeInterval

    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case title = "trackName"
        case artist = "artistName"
        case artworkURL = "artworkUrl100"
        case previewURL = "previewUrl"
        case duration = "trackTimeMillis"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        artworkURL = try container.decodeIfPresent(URL.self, forKey: .artworkURL)
        previewURL = try container.decodeIfPresent(URL.self, forKey: .previewURL)
        let milliseconds = try container.decodeIfPresent(Int.self, forKey: .duration) ?? 0
        duration = TimeInterval(milliseconds) / 1000
    }
}
