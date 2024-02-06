import Foundation
import Vapor

final class Flow {
    static let shared = Flow()

    func start(client: Client, logger: Logger) {
        task = Task {
            do {
                try await work(client: client, logger: logger)
            } catch {
                logger.report(error: error)
            }

            try? await Task.sleep(nanoseconds: 60_000_000_000)

            guard !Task.isCancelled else { return }
            start(client: client, logger: logger)
        }
    }
    func end() {
        task.cancel()
    }
    var status: String {
        // TODO: Status service
        if let refreshToken = try? refreshToken,
           refreshToken.isEmpty {
            return "Need Auth"
        }

        return task.isCancelled ? "Not running" : "Runnig"
    }

    private var task: Task<Void, Never> = Task {}

    private func work(client: Client, logger: Logger) async throws {
        let spotify = Spotify(client: client, logger: logger)
        let searchResult = try await Fetcher.trackName(client: client)
        logger.debug("👋 on RMC: \(searchResult)")

        if searchResult.contains("Monte Carlo") {
            throw ExporterError.trackNotFound
        }

        try await spotify.updateToken()
        let trackUri = try await spotify.searchTrack(searchResult)
        logger.debug("👍 on Spotify: \(trackUri)")

        let mainPlaylistInfo = try await spotify.playlistInfo(.main)

        if let total = mainPlaylistInfo.total, total >= Spotify.Playlist.main.limit {
            /// Delete all tracks below limit
            let mainPlaylistInfoToDelete = try await spotify.playlistInfo(.main, tracksFromEnd: true)
            if let urisToDelete = mainPlaylistInfoToDelete.items?.compactMap({ item in
                item.track?.linkedFrom?.uri ?? item.track?.uri
            }), !urisToDelete.isEmpty {
                try await spotify.removeTrackFromPlaylist(.main, trackUris: urisToDelete)
            }
        }

        if let firstTrackUri = mainPlaylistInfo.items?.first?.track?.uri, firstTrackUri != trackUri {
            try await spotify.addTrackToPlaylist(.main, trackUri: trackUri)

            let livePlaylistInfo = try await spotify.playlistInfo(.live)
            if let total = livePlaylistInfo.total,
               total >= Spotify.Playlist.live.limit,
               let firstTrack = livePlaylistInfo.items?.first?.track,
               let firstTrackUri = firstTrack.linkedFrom?.uri ?? firstTrack.uri
            {
                try await spotify.removeTrackFromPlaylist(.live, trackUris: [firstTrackUri])
            }
            try await spotify.addTrackToPlaylist(.live, trackUri: trackUri)
        }
    }
}
