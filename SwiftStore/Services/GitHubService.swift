import Foundation
import Combine
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif
#if canImport(CryptoKit)
import CryptoKit
#endif
#if canImport(Security)
import Security
#endif

final class GitHubService: ObservableObject {
    @Published private(set) var token: String? {
        didSet {
            if let t = token { KeychainHelper.standard.save(t, service: "github", account: "token") }
            else { KeychainHelper.standard.delete(service: "github", account: "token") }
        }
    }

    init() {
        token = KeychainHelper.standard.read(service: "github", account: "token")
    }

    // Temporary PKCE code verifier storage for the ongoing OAuth flow
    private var currentCodeVerifier: String?

    // MARK: - OAuth (PKCE)
    func startOAuth(from presentingWindowScene: Any? = nil) {
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT_ID") as? String,
              let redirect = Bundle.main.object(forInfoDictionaryKey: "GITHUB_REDIRECT_URI") as? String else {
            print("GitHub client ID or redirect URI missing in Info.plist")
            return
        }

        let state = UUID().uuidString
        let codeVerifier = PKCE.generateCodeVerifier()
        let codeChallenge = PKCE.codeChallenge(for: codeVerifier)
        currentCodeVerifier = codeVerifier

        var comps = URLComponents(string: "https://github.com/login/oauth/authorize")!
        comps.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "scope", value: "repo"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "redirect_uri", value: redirect),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]

        guard let authURL = comps.url else { return }

#if canImport(AuthenticationServices)
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: redirect) { callback, error in
            guard error == nil, let callback = callback, let url = URL(string: callback.absoluteString) else { return }
            self.handleCallback(url: url, codeVerifier: codeVerifier)
        }
        session.presentationContextProvider = nil
        session.start()
#else
        // Fallback: open in browser and ask user to paste code
        if let url = authURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let u = URL(string: url) {
            #if canImport(UIKit)
            UIApplication.shared.open(u)
            #endif
        }
#endif
    }

    private func handleCallback(url: URL, codeVerifier: String) {
        // Extract code
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = comps.queryItems?.first(where: { $0.name == "code" })?.value else { return }

        exchangeCodeForToken(code: code, codeVerifier: codeVerifier)
    }

    // Exposed for app-level onOpenURL handling when ASWebAuthenticationSession isn't used
    func handleOpenURL(_ url: URL) {
        guard let verifier = currentCodeVerifier else { return }
        handleCallback(url: url, codeVerifier: verifier)
        currentCodeVerifier = nil
    }

    private func exchangeCodeForToken(code: String, codeVerifier: String) {
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT_ID") as? String,
              let clientSecret = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT_SECRET") as? String,
              let redirect = Bundle.main.object(forInfoDictionaryKey: "GITHUB_REDIRECT_URI") as? String else {
            print("GitHub OAuth config missing")
            return
        }

        var req = URLRequest(url: URL(string: "https://github.com/login/oauth/access_token")!)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        let body: [String: String] = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirect,
            "code_verifier": codeVerifier
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, resp, err in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let access = json["access_token"] as? String else { return }
            DispatchQueue.main.async { self.token = access }
        }.resume()
    }

    // MARK: - GitHub API helpers
    func createRepository(name: String, privateRepo: Bool = true, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let token = token else { completion(.failure(APIError.unauthenticated)); return }
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
                  let full = json["full_name"] as? String,
                  let html = json["html_url"] as? String,
                  let url = URL(string: html) else { completion(.failure(APIError.invalidResponse)); return }
            // Return repo HTML URL but also log the full repo name for API usage
            completion(.success(URL(string: "https://github.com/\(full)")!))
        }.resume()
    }

    func createFile(repoFullName: String, path: String, content: String, message: String = "Add file", completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = token else { completion(.failure(APIError.unauthenticated)); return }
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

    enum APIError: Error {
        case unauthenticated
        case invalidResponse
    }
}

// MARK: - Helpers
private struct PKCE {
    static func generateCodeVerifier() -> String {
        let data = (0..<32).map { _ in UInt8.random(in: 0...255) }
        return Data(data).base64EncodedString().replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "+", with: "-")
    }

    static func codeChallenge(for verifier: String) -> String {
        guard let data = verifier.data(using: .utf8) else { return verifier }
        #if canImport(CryptoKit)
        let digest = SHA256.hash(data: data)
        return Data(digest).base64EncodedString().trimmingCharacters(in: CharacterSet(charactersIn: "=")).replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
        #else
        return verifier
        #endif
    }
}

// MARK: - Keychain helper
final class KeychainHelper {
    static let standard = KeychainHelper()
    func save(_ value: String, service: String, account: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
        let add: [String: Any] = query.merging([kSecValueData as String: data]) { (_, new) in new }
        SecItemAdd(add as CFDictionary, nil)
    }

    func read(service: String, account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account,
                                    kSecReturnData as String: true]
        var res: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &res)
        guard status == errSecSuccess, let data = res as? Data, let str = String(data: data, encoding: .utf8) else { return nil }
        return str
    }

    func delete(service: String, account: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
    }
}

