import Foundation

struct DirectoryPerson: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let company: OrganizationInfo
    let address: LocationInfo

    struct OrganizationInfo: Codable, Equatable {
        let name: String
        let catchPhrase: String
    }

    struct LocationInfo: Codable, Equatable {
        let city: String
        let zipcode: String
    }
}

enum DirectoryAPIError: LocalizedError, Equatable {
    case invalidURL
    case httpFailure(statusCode: Int)
    case decodingFailed
    case emptyDirectory
    case networkFailure(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API endpoint URL is malformed."
        case .httpFailure(let code):
            return "Server returned an unexpected status code (\(code))."
        case .decodingFailed:
            return "Failed to parse the JSON response from the server."
        case .emptyDirectory:
            return "No directory entries were returned."
        case .networkFailure(let detail):
            return "Network connection failed: \(detail)"
        }
    }
}

protocol URLSessionFetching {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionFetching {}

final class DirectoryAPIService {
    private let session: URLSessionFetching
    private let baseEndpoint: String

    init(
        session: URLSessionFetching = URLSession.shared,
        baseEndpoint: String = "https://jsonplaceholder.typicode.com/users"
    ) {
        self.session = session
        self.baseEndpoint = baseEndpoint
    }

    func fetchDirectory(limit: Int? = nil) async throws -> [DirectoryPerson] {
        guard var components = URLComponents(string: baseEndpoint),
              components.scheme != nil,
              components.host != nil else {
            throw DirectoryAPIError.invalidURL
        }

        if let limit = limit {
            components.queryItems = [URLQueryItem(name: "_limit", value: String(limit))]
        }

        guard let finalURL = components.url else {
            throw DirectoryAPIError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw DirectoryAPIError.networkFailure(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DirectoryAPIError.networkFailure("Invalid server response.")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw DirectoryAPIError.httpFailure(statusCode: httpResponse.statusCode)
        }

        let decodedPeople: [DirectoryPerson]
        do {
            decodedPeople = try JSONDecoder().decode([DirectoryPerson].self, from: data)
        } catch {
            throw DirectoryAPIError.decodingFailed
        }

        guard !decodedPeople.isEmpty else {
            throw DirectoryAPIError.emptyDirectory
        }

        return decodedPeople
    }
}
