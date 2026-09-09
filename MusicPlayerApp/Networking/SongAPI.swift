//
//  SongServices.swift
//  MusicPlayerApp
//
//  Created by charlie siagian on 08/09/26.
//

import Foundation

final class SongAPI {
    private let client: HTTPClient
    private let userDefaults = UserDefaults.standard
    
    init(client: HTTPClient = URLSession.shared) {
        self.client = client
    }
    
    func fetchSongList(_ artistName: String) async throws -> [Song] {
        var components = URLComponents(string: "https://itunes.apple.com/search")!
        
        components.queryItems = [
            URLQueryItem(name: "term", value: artistName),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "50")
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await client.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(SongListResponse.self, from: data)
        
        return result.results
    }
}
