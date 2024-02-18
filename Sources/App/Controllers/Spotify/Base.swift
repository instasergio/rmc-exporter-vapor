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
                "http://94.140.192.162:23347/site/broad.txt"
            case .token:
                "https://accounts.spotify.com/api/token"
            case .search:
                "https://api.spotify.com/v1/search"
            case let .playlist(playlist):
                "https://api.spotify.com/v1/playlists/\(playlist.rawValue)/tracks"
            }
        }
    }
}

enum ExporterError: Error {
    case noClientId
    case noClientSecret
    case noRefreshToken
    case noRedirectUrl
    case trackNotFound
    case noTrackOnRadio
}

var clientId: String {
    get throws {
        try Environment.process.CLIENT_ID ?! ExporterError.noClientId
    }
}

var clientSecret: String {
    get throws {
        try Environment.process.CLIENT_SECRET ?! ExporterError.noClientSecret
    }
}

var refreshToken: String {
    get throws {
        try Environment.process.REFRESH_TOKEN ?! ExporterError.noRefreshToken
    }
}

var redirectUrl: String {
    get throws {
        try Environment.process.REDIRECT_URL ?! ExporterError.noRedirectUrl
    }
}

var accessToken: String = ""
var tokenRefreshTime: Double = 0

func updateRefreshToken(token: String) {
    setenv("REFRESH_TOKEN", token, 1)
}

extension Client {
    private func headers(_ endpoint: Spotify.Endpoint) throws -> HTTPHeaders {
        switch endpoint {
        case .token:
            return try .init(
                [
                    ("Authorization", "Basic \((clientId + ":" + clientSecret).base64Url)")
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
        try await get(URI(string: endpoint.url), headers: headers(endpoint), beforeSend: beforeSend)
    }

    @discardableResult
    func post(_ endpoint: Spotify.Endpoint, beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
        try await post(URI(string: endpoint.url), headers: headers(endpoint), beforeSend: beforeSend)
    }

    @discardableResult
    func delete(_ endpoint: Spotify.Endpoint, beforeSend: (inout ClientRequest) throws -> () = { _ in }) async throws -> ClientResponse {
        try await delete(URI(string: endpoint.url), headers: headers(endpoint), beforeSend: beforeSend)
    }
}

infix operator ?!: NilCoalescingPrecedence

/// Throws the right hand side error if the left hand side optional is `nil`.
func ?! <T>(value: T?, error: @autoclosure () -> Error) throws -> T {
    guard let value = value else {
        throw error()
    }
    return value
}
