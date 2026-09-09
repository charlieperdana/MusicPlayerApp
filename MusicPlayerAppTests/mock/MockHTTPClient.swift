//
//  MockHTTPClient.swift
//  MusicPlayerAppTests
//
//  Created by charlie siagian on 09/09/26.
//

import Foundation
@testable import MusicPlayerApp

final class MockHTTPClient: HTTPClient {
    var dataToReturn: Data?
    var responseToReturn: URLResponse?
    var errorToThrow: Error?
    
    private(set) var requestedURL: URL?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        requestedURL = url
        if let errorToThrow {
            throw errorToThrow
        }
        guard let dataToReturn, let responseToReturn else {
            fatalError("MockHTTPClient was not configured")
        }
        return (dataToReturn, responseToReturn)
    }
    
}
