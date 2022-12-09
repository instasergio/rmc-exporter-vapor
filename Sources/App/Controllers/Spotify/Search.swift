import Foundation
import Vapor

extension Spotify {
    func searchTrack(_ track: String) async throws -> String {
        let request = try await client.get(.search) { request in
            try request.query.encode([
                "q": track,
                "type": "track",
                "limit": "1"
            ])
        }
        
        let model = try request.content.decode(SearchResponseModel.self)
        if let foundTrackUri = model.tracks.items?.first?.uri {
            /// TODO: track wrong search api requests
            if (foundTrackUri == "spotify:track:39eY7VbkqwAuIBxkOyF8Ur") {
                return "spotify:track:4jtdJTahwSiNg3iyrUnGvp"
            }
            return foundTrackUri
        } else {
            throw ExporterError.trackNotFound
        }
    }
}
