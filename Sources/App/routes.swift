import Vapor

func routes(_ app: Application) throws {
    app.get("status") { _ -> String in
        Flow.shared.status
    }

    app.get("login") { req async throws in
        let auth = SpotifyAuth(client: app.client, logger: app.logger)
        return try await auth.login(req: req)
    }
}
