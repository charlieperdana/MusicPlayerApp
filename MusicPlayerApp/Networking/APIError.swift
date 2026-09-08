//
//  APIError.swift
//  MusicPlayerApp
//
//  Created by charlie siagian on 08/09/26.
//

import Foundation

enum APIError: Error, CustomStringConvertible {
    case badUrl
    case badResponse(statusCode: Int)
    case url(URLError?)
    case parsing(DecodingError?)
    case unknown
    
    var localizedDescription: String {
        switch self {
            
        case .badUrl, .parsing, .unknown:
            return "Sorry, something went wrong."
            
        case .badResponse(_):
            return "Sorry, the connection to our server failed."
            
        case .url(let error):
            return error?.localizedDescription ?? "Something went wrong."
        }
    }
    
    var description: String {
        switch self {
        case .badUrl:
            return "invalid url"
        case .badResponse(statusCode: let statusCode):
            return "bad response with status code \(statusCode)"
        case .url(let error):
            return error?.localizedDescription ?? "url session error"
        case .parsing(let error):
            return "parsing error \(error?.localizedDescription ?? "")"
        case .unknown:
            return "unknown error"
        }
    }
}

