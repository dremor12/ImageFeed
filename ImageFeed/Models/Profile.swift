import Foundation

struct Profile {
    let profileResult: ProfileResult
    
    var userName: String? {
        return profileResult.username
    }
    
    var name: String {
        return (profileResult.firstName ?? "") + " " + (profileResult.lastName ?? "")
    }
    
    var loginName: String {
        return "@" + (profileResult.username ?? "")
    }
    
    var bio: String? {
        return profileResult.bio
    }
    
    init(profileResult: ProfileResult) {
        self.profileResult = profileResult
    }
}
