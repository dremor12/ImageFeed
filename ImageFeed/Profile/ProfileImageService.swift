import UIKit

final class ProfileImageService{
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() { }
    
    private(set) var avatarURL: String?
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private func makeImageRequest(with username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "/users/" + username, relativeTo: Constants.defaultBaseURL) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        guard let token = tokenStorage.token else {
            let error = URLError(.userAuthenticationRequired)
            print("[fetchProfileImageURL]: URLError - токен не найден")
            completion(.failure(error))
            return
        }
        
        guard let request = makeImageRequest(with: username, token: token) else {
            let error = URLError(.badURL)
            print("[fetchProfileImageURL]: URLError - неверный URL для пользователя: \(username)")
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                let imageURL = userResult.profileImage.small
                self.avatarURL = imageURL
                completion(.success(imageURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": imageURL]
                )
            case .failure(let error):
                print("[fetchProfileImageURL]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func reset() {
        avatarURL = nil
    }
}
