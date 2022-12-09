import Vapor

func routes(_ app: Application) throws {
    app.get("status") { req async -> Bool in
        return Flow.shared.status
    }
}
