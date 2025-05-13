import Foundation

struct Photo {
    let id: String
    var size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageUrl: String
    let isLiked: Bool
}

struct LikeResponse: Decodable {
    let photo: PhotoResult
}

extension Photo {
    init(from result: PhotoResult) {
        id = result.id
        size = CGSize(width: result.width, height: result.height)
        createdAt = ISO8601DateFormatter().date(from: result.createdAt ?? "")
        welcomeDescription = result.description
        thumbImageURL = result.urls.thumb
        largeImageURL = result.urls.regular
        fullImageUrl = result.urls.full
        isLiked = result.isLiked
    }
}

