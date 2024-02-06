import Vapor

public func configure(_ app: Application) throws {
    #if DEBUG
    app.logger.logLevel = .debug
    #endif

    if try refreshToken.isEmpty {
        app.logger.warning("🛑 No refresh token, login pls")
    }

    Flow.shared.start(client: app.client, logger: app.logger)
    try routes(app)
}
