struct TokenResponseModel: Codable {
    let refreshToken: String?
    let accessToken, tokenType: String
    let expiresIn: Double
    let scope: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope
    }
}

struct SearchResponseModel: Codable {
    let tracks: Tracks
}

// MARK: - Tracks

struct Tracks: Codable {
    let href: String?
    let items: [Item]?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: JSONNull?
    let total: Int?
}

// MARK: - Track

struct Track: Codable {
    let album: Album?
    let artists: [AddedBy]?
    let discNumber, durationMs: Int?
    let episode, explicit: Bool?
    let externalIds: ExternalIds?
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let isLocal, isPlayable: Bool?
    let linkedFrom: AddedBy?
    let name: String?
    let popularity: Int?
    let previewUrl: String?
    let track: Bool?
    let trackNumber: Int?
    let type, uri: String?

    enum CodingKeys: String, CodingKey {
        case album, artists
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case episode, explicit
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isLocal = "is_local"
        case isPlayable = "is_playable"
        case linkedFrom = "linked_from"
        case name, popularity
        case previewUrl = "preview_url"
        case track
        case trackNumber = "track_number"
        case type, uri
    }
}

// MARK: - AddedBy

struct AddedBy: Codable {
    let externalUrls: ExternalUrls?
    let href: String?
    let id, type, uri, name: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, type, uri, name
    }
}

// MARK: - Item

struct Item: Codable, Sendable {
    let album: Album?
    let artists: [Artist]?
    let availableMarkets: [String]?
    let discNumber, durationMs: Int?
    let explicit: Bool?
    let externalIds: ExternalIds?
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let isLocal: Bool?
    let name: String?
    let popularity: Int?
    let previewUrl: String?
    let track: Track?
    let trackNumber: Int?
    let type, uri: String?

    enum CodingKeys: String, CodingKey {
        case album, artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case explicit
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isLocal = "is_local"
        case name, popularity
        case previewUrl = "preview_url"
        case track
        case trackNumber = "track_number"
        case type, uri
    }
}

// MARK: - Album

struct Album: Codable {
    let albumType: String?
    let artists: [Artist]?
    let availableMarkets: [String]?
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let images: [Image]?
    let name, releaseDate, releaseDatePrecision: String?
    let totalTracks: Int?
    let type, uri: String?

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case totalTracks = "total_tracks"
        case type, uri
    }
}

// MARK: - Artist

struct Artist: Codable {
    let externalUrls: ExternalUrls?
    let href: String?
    let id, name, type, uri: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }
}

// MARK: - ExternalUrls

struct ExternalUrls: Codable {
    let spotify: String?
}

// MARK: - Image

struct Image: Codable {
    let height: Int?
    let url: String?
    let width: Int?
}

// MARK: - ExternalIds

struct ExternalIds: Codable {
    let isrc: String?
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
