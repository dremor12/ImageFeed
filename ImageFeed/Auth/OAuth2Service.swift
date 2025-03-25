import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private let queue = DispatchQueue(label: "OAuth2ServiceQueue", attributes: .concurrent)
    private var currentTask: URLSessionTask?
    
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            self.currentTask?.cancel()
            
            
            
            guard let request = makeOAuthTokenRequest(code: code) else {
                let error = NSError(domain: "InvalidRequest", code: 400, userInfo: nil)
                print("[fetchOAuthToken]: InvalidRequest - не удалось создать запрос с кодом: \(code)")
                completion(.failure(error))
                return
            }
            
            let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
                guard let self = self else { return }
                self.queue.async(flags: .barrier) {
                    switch result {
                    case .success(let responseBody):
                        self.tokenStorage.token = responseBody.accessToken
                        completion(.success(responseBody.accessToken))
                    case .failure(let error):
                        print("[fetchOAuthToken]: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
            
            self.currentTask = task
            task.resume()
        }
    }
}
