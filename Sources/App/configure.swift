import Vapor

public func configure(_ app: Application) throws {
    Flow.shared.start(client: app.client, logger: app.logger)
    try routes(app)
}
