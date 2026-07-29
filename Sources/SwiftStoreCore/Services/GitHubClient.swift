import Foundation

public final class GitHubClient {
    private let token: String

    public init(token: String) {
        self.token = token
    }

    public enum APIError: Error {
        case invalidResponse
    }

    public func createRepository(name: String, privateRepo: Bool = true, completion: @escaping (Result<String, Error>) -> Void) {
        var req = URLRequest(url: URL(string: "https://api.github.com/user/repos")!)
        req.httpMethod = "POST"
        req.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["name": name, "private": privateRepo]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err { completion(.failure(err)); return }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let full = json["full_name"] as? String else { completion(.failure(APIError.invalidResponse)); return }
            completion(.success(full))
        }.resume()
    }

    public func createFile(repoFullName: String, path: String, content: String, message: String = "Add file", completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "https://api.github.com/repos/\(repoFullName)/contents/\(path)")!
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoded = Data(content.utf8).base64EncodedString()
        let body: [String: Any] = ["message": message, "content": encoded]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err { completion(.failure(err)); return }
            completion(.success(()))
        }.resume()
    }
}
