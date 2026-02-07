import Foundation
import Vapor

/// This provides protection against attacks such as cross-site request forgery
let stateCheck: String = .random(length: 16)

struct SpotifyAuth {
    let client: Client
    let logger: Logger

    func login(req: Request) async throws -> Response {
        logger.debug("🗿 Login")
        guard let code: String = try req.query.get(at: "code") else {
            logger.debug("🗿 Login: No code, to Auth")
            return try await auth(req: req)
        }

        logger.debug("🗿 Login: Code id \(code)")
        guard let state: String = try req.query.get(at: "state"),
              state == stateCheck
        else {
            logger.debug("🗿 Login: invalid state check")
            throw URLError(.secureConnectionFailed)
        }

        logger.debug("🗿 Login: requesting token with code")
        try await requestToken(code: code)

        logger.debug("🗿 Login: response Done")
        let response = Response(
            body: .init(string: "Done")
        )
        return response
    }

    func requestToken(code: String) async throws {     
        logger.debug("✍️ Auth: requesting refresh token")

        let redirectUrl = try redirectUrl

        let response = try await client.post(.token) { request in
            try request.content.encode([
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": redirectUrl
            ], as: .urlEncodedForm)
        }
        try response.requireSuccess(context: "spotify.token.authorization_code")

        let model = try response.content.decode(TokenResponseModel.self)
        if let refreshToken = model.refreshToken {
            updateRefreshToken(token: refreshToken)
        }
        accessToken = model.accessToken
    }

    /// No refresh token - go to spotify to login
    /// get code than get refresh token
    func auth(req: Request) async throws -> Response {
        let redirectUrl = try redirectUrl
        let clientId = try clientId

        var components = URLComponents(string: "https://accounts.spotify.com/authorize")

        let queryItems: [URLQueryItem] = .build {
            URLQueryItem(name: "response_type", value: "code")
            URLQueryItem(name: "client_id", value: clientId)
            URLQueryItem(name: "scope", value: "playlist-modify-public playlist-read-private")
            URLQueryItem(name: "redirect_uri", value: redirectUrl)
            URLQueryItem(name: "state", value: stateCheck)
        }

        components?.queryItems = queryItems

        guard let url = components?.string else {
            fatalError("Invalid URL components")
        }

        logger.debug("✍️ Auth: redirecting to Spotify")
        logger.debug("✍️ Auth: url - \(url)")
        
        return req.redirect(to: url)
    }
}

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
                "refresh_token": refreshToken
            ], as: .urlEncodedForm)
        }
        try response.requireSuccess(context: "spotify.token.refresh")

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

    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }
}

@resultBuilder
public enum ArrayBuilder<Element> {
    public static func buildBlock(_ elements: [Element]...) -> [Element] {
        elements.flatMap { $0 }
    }

    public static func buildOptional(_ elements: [Element]?) -> [Element] {
        elements ?? []
    }

    public static func buildEither(first: [Element]) -> [Element] {
        first
    }

    public static func buildEither(second: [Element]) -> [Element] {
        second
    }

    public static func buildExpression(_ elements: [Element]) -> [Element] {
        elements
    }

    public static func buildExpression(_ element: Element) -> [Element] {
        [element]
    }

    public static func buildExpression(_ element: Element?) -> [Element] {
        element.map { [$0] } ?? []
    }
}

public extension Array {
    static func build(@ArrayBuilder<Element> builder: () -> [Element]) -> [Element] {
        builder()
    }
}
