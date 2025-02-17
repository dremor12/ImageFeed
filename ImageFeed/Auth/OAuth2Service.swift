import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseURL = Constants.tokenURL
        
        let parameters: [String: String] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        let httpBody = parameters
            .map { key, value in "\(key)=\(value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Ошибка: невозможно создать запрос токена")
            completion(.failure(NSError(domain: "InvalidRequest", code: 400, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    self?.tokenStorage.token = responseBody.accessToken
                    completion(.success(responseBody.accessToken))
                } catch {
                    print("Ошибка декодирования JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Сетевая ошибка: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
