//
//  SongAPITests.swift
//  MusicPlayerAppTests
//
//  Created by charlie siagian on 09/09/26.
//

import Testing
import Foundation
@testable import MusicPlayerApp

struct SongAPITests {
    func makeHTTPResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    @Test
    func fetchSongListReturnsSongs() async throws {
        let mockClient = MockHTTPClient()

        let json = """
        {
            "resultCount": 1,
            "results": [
                {
                    "trackId": 123,
                    "trackName": "Halo",
                    "artistName": "Beyoncé",
                    "artworkUrl100": "https://example.com/art.jpg",
                    "previewUrl": "https://example.com/preview.m4a",
                    "trackTimeMillis": 230000
                }
            ]
        }
        """

        mockClient.dataToReturn = Data(json.utf8)
        mockClient.responseToReturn = makeHTTPResponse(statusCode: 200)
        let api = SongAPI(client: mockClient)

        // When
        let songs = try await api.fetchSongList("Beyoncé")

        // Then
        #expect(songs.count == 1)
        #expect(songs[0].id == 123)
        #expect(songs[0].title == "Halo")
        #expect(songs[0].artist == "Beyoncé")
        #expect(songs[0].previewURL?.absoluteString == "https://example.com/preview.m4a")
    }
    
    @Test
    func fetchSongListBuildsCorrectURL() async throws {
        let mockClient = MockHTTPClient()
        let json = """
        {
            "resultCount": 0,
            "results": []
        }
        """

        mockClient.dataToReturn = Data(json.utf8)
        mockClient.responseToReturn = makeHTTPResponse(statusCode: 200)

        let api = SongAPI(client: mockClient)

        // When
        _ = try await api.fetchSongList("Beyoncé")

        // Then
        let url = try #require(mockClient.requestedURL)

        let components = try #require(
            URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )
        )

        let parameters = Dictionary(
            uniqueKeysWithValues:
                components.queryItems?.map {
                    ($0.name, $0.value ?? "")
                } ?? []
        )

        #expect(parameters["term"] == "Beyoncé")
        #expect(parameters["media"] == "music")
        #expect(parameters["entity"] == "song")
        #expect(parameters["limit"] == "50")
    }
    
    @Test
    func fetchSongListThrowsForBadResponse() async {
        let mockClient = MockHTTPClient()
        let json = """
        {
            "resultCount": 0,
            "results": []
        }
        """

        mockClient.dataToReturn = Data(json.utf8)
        mockClient.responseToReturn = makeHTTPResponse(statusCode: 500)

        let api = SongAPI(client: mockClient)

        // When / Then
        await #expect(throws: URLError.self) {
            try await api.fetchSongList("Beyoncé")
        }
    }
    
    @Test
    func fetchSongListThrowsForInvalidJSON() async {
        let mockClient = MockHTTPClient()
        mockClient.dataToReturn = Data("This is not JSON".utf8)
        mockClient.responseToReturn = makeHTTPResponse(statusCode: 200)

        let api = SongAPI(client: mockClient)

        // When / Then
        await #expect(throws: DecodingError.self) {
            try await api.fetchSongList("Beyoncé")
        }
    }
}
