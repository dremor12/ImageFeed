import Foundation

enum Constants {
    static let accessKey = "bcwwuKlhZjUpMMSN24D-xfiDc9gqnXoVW8nBPJwT3s8"
    static let secretKey = "j_OtY0BYOiaXM9BA5PkqatL35LVtEzDC-II6-fYpYBw"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let tokenURL: URL = {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            fatalError("❌ Invalid token URL")
        }
        return url
    }()
    
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("❌ Invalid base API URL")
        }
        return url
    }()
}
