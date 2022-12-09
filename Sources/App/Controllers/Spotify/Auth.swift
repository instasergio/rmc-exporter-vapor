import Foundation
import Vapor

extension Spotify {
    func updateToken() async throws {
        /// should update check
        if tokenRefreshTime > Date().timeIntervalSince1970 {
            return
        }

        /// update token
        let response = try await client.post(.token) { request in
            try request.content.encode([
                "grant_type": "refresh_token",
                "refresh_token": (try refreshToken)
            ], as: .urlEncodedForm)
        }

        let model = try response.content.decode(TokenResponseModel.self)
        accessToken = model.accessToken
        tokenRefreshTime = Date().timeIntervalSince1970 + model.expiresIn
    }
}

extension String {
    var base64Url: String {
        return Data(utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
