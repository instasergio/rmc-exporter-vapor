import Foundation
import Vapor

extension Spotify {
    func addTrackToPlaylist(_ playlist: Spotify.Playlist, trackUri: String) async throws {
        try await client.post(.playlist(playlist)) { request in
            try request.query.encode([
                "uris": trackUri,
                "position": playlist.addTrackToEnd ? nil : "0"
            ])
        }
        logger.debug("Added track to \(playlist.debugDescription)")
    }

    func playlistInfo(
        _ playlist: Spotify.Playlist,
        tracksFromEnd: Bool = false
    ) async throws -> Tracks {
        let request = try await client.get(.playlist(playlist)) { request in
            try request.query.encode([
                "fields": "total,items.track(uri,linked_from)",
                /// If adding tracks to bottom - request first one to remove it
                /// if adding tracks to top - request closest to limit to remove it
                "offset": tracksFromEnd ? String(playlist.limit) : nil,
                "limit": tracksFromEnd ? "50" : "1",
                "market": "from_token"
            ])
        }
        return try request.content.decode(Tracks.self)
    }

    func removeTrackFromPlaylist(_ playlist: Spotify.Playlist, trackUris: [String]) async throws {
        try await client.delete(.playlist(playlist)) { request in
            let tracks = trackUris.enumerated().map { index, uri -> RemoveTrackRequestModel.TrackToRemove in
                let pos: [Int]?
                switch playlist {
                case .main: pos = [index + playlist.limit]
                case .live: pos = [index]
                }
                return RemoveTrackRequestModel.TrackToRemove(uri: uri, positions: pos)
            }
            let model = RemoveTrackRequestModel(tracks: tracks)
            try request.content.encode(model, as: .json)
            logger.debug("Removed track from \(playlist.debugDescription)")
        }
    }
}

struct RemoveTrackRequestModel: Content {
    struct TrackToRemove: Codable {
        let uri: String
        let positions: [Int]?
    }

    let tracks: [TrackToRemove]
}

extension Spotify.Playlist {
    var addTrackToEnd: Bool {
        switch self {
        case .main:
            return false
        case .live:
            return true
        }
    }

    var limit: Int {
        switch self {
        case .main:
            return 1_703
        case .live:
            return 10
        }
    }
}
