import Foundation
import Vapor

struct Spotify {
    let client: Client
    let logger: Logger

    enum Playlist: String, CustomDebugStringConvertible {
        case main = "32jmNqf6iLAf3oqhmNNspd"
        case live = "6ohV6Zqtj1yFrgvygwfFf3"

        var debugDescription: String {
            switch self {
            case .main: return "MAIN"
            case .live: return "LIVE"
            }
        }
    }

    enum Endpoint {
        case currentTrackName
        case token
        case search
        case playlist(Playlist)

        var url: String {
            switch self {
            case .currentTrackName:
                return "http://94.140.192.162:23347/site/broad.txt"
            case .token:
                return "https://accounts.spotify.com/api/token"
            case .search:
                return "https://api.spotify.com/v1/search"
            case let .playlist(playlist):
                return "https://api.spotify.com/v1/playlists/\(playlist.rawValue)/tracks"
            }
        }
    }
}

enum ExporterError: Error {
    case noEnvVar
    case trackNotFound
    case noTrackOnRadio
}

var clientId: String {
    get throws {
        try Environment.process.CLIENT_ID ?! ExporterError.noEnvVar
    }
}
var clientSecret: String {
    get throws {
        try Environment.process.CLIENT_SECRET ?! ExporterError.noEnvVar
    }
}
var refreshToken: String {
    get throws {
        try Environment.process.REFRESH_TOKEN ?! ExporterError.noEnvVar
    }
}

var accessToken: String = ""
var tokenRefreshTime: Double = 0

extension Client {
    private func headers(_ endpoint: Spotify.Endpoint) throws -> HTTPHeaders {
        switch endpoint {
        case .token:
            return .init(
                [
                    ("Authorization", "Basic \(((try clientId) + ":" + (try clientSecret)).base64Url)")
                ]
            )
        default:
            let headers: HTTPHeaders = .init(
                [
                    ("Authorization", "Bearer \(accessToken)")
                ]
            )
            return headers
        }
    }

    @discardableResult
    func get(_ endpoint: Spotify.Endpoint, beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
        try await self.get(URI(string: endpoint.url), headers: (try headers(endpoint)), beforeSend: beforeSend)
    }
    @discardableResult
    func post(_ endpoint: Spotify.Endpoint, beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
        try await self.post(URI(string: endpoint.url), headers: (try headers(endpoint)), beforeSend: beforeSend)
    }
    @discardableResult
    func delete(_ endpoint: Spotify.Endpoint, beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
        try await self.delete(URI(string: endpoint.url), headers: (try headers(endpoint)), beforeSend: beforeSend)
    }
}

infix operator ?!: NilCoalescingPrecedence

/// Throws the right hand side error if the left hand side optional is `nil`.
func ?!<T>(value: T?, error: @autoclosure () -> Error) throws -> T {
    guard let value = value else {
        throw error()
    }
    return value
}
