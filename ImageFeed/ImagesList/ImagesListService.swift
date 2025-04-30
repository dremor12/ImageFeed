import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []
    private(set) var isLoading = false
    private(set) var lastLoadedPage: Int?
    private let perPage = 10
    private var taskLike: URLSessionTask?
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        
        guard let token = OAuth2TokenStorage().token else {
            print("[fetchProfileImageURL]: URLError - токен не найден")
            isLoading = false
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            isLoading = false
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(from: $0) }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    
                    let existingIDs = Set(self.photos.map(\.id))
                    let unique = newPhotos.filter { !existingIDs.contains($0.id) }
                    guard !unique.isEmpty else {
                        self.isLoading = false
                        return
                    }
                    
                    self.photos.append(contentsOf: unique)
                    self.lastLoadedPage = nextPage
                    self.isLoading = false
                    NotificationCenter.default.post(
                        name: Self.didChangeNotification,
                        object: self,
                        userInfo: ["newPhotos": unique]
                    )
                }
            case .failure(let error):
                print("[ImagesListService] fetch error: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        taskLike?.cancel()
        
        guard let token = OAuth2TokenStorage().token else {
            let error = URLError(.userAuthenticationRequired)
            completion(.failure(error))
            return
        }
        
        guard let request = makeLikeRequest(id: photoId, isLike: isLike, token: token) else {
            let error = URLError(.badURL)
            completion(.failure(error))
            return
        }
        
        taskLike = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<LikeResponse, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let likeResponse):
                let updatedPhotoResult = likeResponse.photo
                let updatedPhoto = Photo(from: updatedPhotoResult)
                DispatchQueue.main.async{ [weak self] in
                    guard let self else { return }
                    if let index = self.photos.firstIndex(where: { $0.id == updatedPhoto.id }) {
                        self.photos = self.photos.withReplaced(itemAt: index, newValue: updatedPhoto)
                        NotificationCenter.default.post(
                            name: Self.didChangeNotification,
                            object: self,
                            userInfo: ["updatedPhotoIndex": index]
                        )
                    }
                    completion(.success(()))
                }
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
            self.taskLike = nil
        }
        taskLike?.resume()
    }
    
    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        var components = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true)
        components?.path = "/photos"
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeLikeRequest(id: String, isLike: Bool, token: String) -> URLRequest? {
        var components = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true)
        components?.path = "/photos/\(id)/like"
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func reset() {
        photos.removeAll()
        lastLoadedPage = nil
        isLoading = false
    }
}
