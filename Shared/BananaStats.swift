import Foundation

/// Payload of GET https://3d.ar/api/banana-widget. Every value may be null → shown as "—".
struct BananaStats: Equatable {
    var updatedAt: Date?
    var players: Int?
    var wishlists: Int?
    var wishlistsToday: Int?
    var wishlistsUpdatedAt: Date?

    static let endpoint = URL(string: "https://3d.ar/api/banana-widget")!
    static let statsPage = URL(string: "https://3d.ar/banana-stats/")!
    static let empty = BananaStats()
    static let preview = BananaStats(updatedAt: Date(), players: 42, wishlists: 12_345, wishlistsToday: 87, wishlistsUpdatedAt: Date())

    /// Lenient parse: numbers may arrive as Int, Double or String; anything else is nil.
    init(json: Any) {
        guard let d = json as? [String: Any] else { self = .empty; return }
        func int(_ k: String) -> Int? {
            switch d[k] {
            case let n as Int: return n
            case let n as Double: return n.isFinite ? Int(n) : nil
            case let s as String: return Int(s) ?? Double(s).map { Int($0) }
            default: return nil
            }
        }
        func date(_ k: String) -> Date? {
            guard let s = d[k] as? String else { return nil }
            let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let x = f.date(from: s) { return x }
            f.formatOptions = [.withInternetDateTime]
            return f.date(from: s)
        }
        updatedAt = date("updatedAt"); players = int("players"); wishlists = int("wishlists")
        wishlistsToday = int("wishlistsToday"); wishlistsUpdatedAt = date("wishlistsUpdatedAt")
    }
    init(updatedAt: Date? = nil, players: Int? = nil, wishlists: Int? = nil, wishlistsToday: Int? = nil, wishlistsUpdatedAt: Date? = nil) {
        self.updatedAt = updatedAt; self.players = players; self.wishlists = wishlists
        self.wishlistsToday = wishlistsToday; self.wishlistsUpdatedAt = wishlistsUpdatedAt
    }

    /// Fetches the stats; a network error, non-JSON body (e.g. the site's HTML) or non-2xx → `.empty`.
    static func fetch() async -> BananaStats {
        var req = URLRequest(url: endpoint, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode),
                  let json = try? JSONSerialization.jsonObject(with: data) else { return .empty }
            return BananaStats(json: json)
        } catch { return .empty }
    }
}

enum Fmt {
    static func num(_ n: Int?) -> String {
        guard let n else { return "—" }
        return n.formatted(.number.grouping(.automatic))
    }
    static func signed(_ n: Int?) -> String {
        guard let n else { return "—" }
        return (n > 0 ? "+" : "") + n.formatted(.number.grouping(.automatic))
    }
    static func time(_ d: Date?) -> String {
        guard let d else { return "—" }
        return d.formatted(date: .omitted, time: .shortened)
    }
}
