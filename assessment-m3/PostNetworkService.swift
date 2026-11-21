import Foundation

struct RemotePost: Codable, Identifiable, Equatable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

enum RemoteFeedError: LocalizedError, Equatable {
    case badEndpoint
    case serverStatus(Int)
    case invalidJSON
    case emptyFeed
    case transportError(String)

    var errorDescription: String? {
        switch self {
        case .badEndpoint:
            return "Invalid API endpoint URL."
        case .serverStatus(let code):
            return "Server responded with HTTP status \(code)."
        case .invalidJSON:
            return "Unable to decode JSON response."
        case .emptyFeed:
            return "No posts matched your filter."
        case .transportError(let message):
            return "Network request failed: \(message)"
        }
    }
}

final class PostNetworkService {
    private let session: URLSession
    private let endpoint: String

    init(session: URLSession = .shared, endpoint: String = "https://jsonplaceholder.typicode.com/posts") {
        self.session = session
        self.endpoint = endpoint
    }

    func fetchPosts(userIDFilter: Int? = nil, forceEmpty: Bool = false, forceBadURL: Bool = false) async throws -> [RemotePost] {
        let targetString = forceBadURL ? "ht!tp://invalid url" : endpoint
        guard var components = URLComponents(string: targetString),
              components.scheme != nil,
              components.host != nil else {
            throw RemoteFeedError.badEndpoint
        }

        var queryItems: [URLQueryItem] = [URLQueryItem(name: "_limit", value: "12")]
        if let userID = userIDFilter {
            queryItems.append(URLQueryItem(name: "userId", value: String(userID)))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw RemoteFeedError.badEndpoint
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw RemoteFeedError.transportError(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw RemoteFeedError.transportError("Non-HTTP response received.")
        }

        guard (200...299).contains(http.statusCode) else {
            throw RemoteFeedError.serverStatus(http.statusCode)
        }

        let decoded: [RemotePost]
        do {
            decoded = try JSONDecoder().decode([RemotePost].self, from: data)
        } catch {
            throw RemoteFeedError.invalidJSON
        }

        let finalItems = forceEmpty ? [] : decoded
        guard !finalItems.isEmpty else {
            throw RemoteFeedError.emptyFeed
        }

        return finalItems
    }
}
