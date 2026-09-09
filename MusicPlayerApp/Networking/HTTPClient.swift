//
//  HTTPClient.swift
//  MusicPlayerApp
//
//  Created by charlie siagian on 09/09/26.
//

import Foundation

protocol HTTPClient {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPClient {}
