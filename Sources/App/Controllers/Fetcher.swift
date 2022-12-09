import Vapor

struct Fetcher {
    static func trackName(client: Client) async throws -> String {
        guard let buffer = try await client.get(.currentTrackName).body else {
            throw ExporterError.noTrackOnRadio
        }

        return String(buffer: buffer)
    }
}
