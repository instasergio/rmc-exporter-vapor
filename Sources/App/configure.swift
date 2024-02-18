import Vapor
import NIOSSL

public func configure(_ app: Application) throws {
    #if DEBUG
    app.logger.logLevel = .debug
    #endif

//    app.http.server.configuration.tlsConfiguration = .makeServerConfiguration(
//        certificateChain: try NIOSSLCertificate.fromPEMFile("../../fullchain.pem").map { .certificate($0) },
//        privateKey: .file("../../privkey.pem")
//    )

    Flow.shared.start(client: app.client, logger: app.logger)
    try routes(app)
}
