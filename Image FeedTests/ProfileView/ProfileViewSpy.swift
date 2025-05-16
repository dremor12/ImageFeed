@testable import ImageFeed
import Foundation

final class ProfileViewSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    private(set) var showProfileCalled = false
    private(set) var receivedProfile: Profile?
    
    private(set) var showAvatarCalled = false
    private(set) var receivedAvatarURL: URL?
    
    private(set) var showSkeletonCalled = false
    private(set) var hideSkeletonCalled = false
    
    
    func show(profile: Profile) {
        showProfileCalled = true
        receivedProfile = profile
    }
    
    func showAvatar(url: URL?) {
        showAvatarCalled = true
        receivedAvatarURL = url
    }
    
    func showSkeleton() {
        showSkeletonCalled = true
    }
    
    func hideSkeleton() {
        hideSkeletonCalled = true
    }
}

final class ProfilePresenterWithFakeData: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        let profileResult = ProfileResult(
            username: "login",
            firstName: "Имя",
            lastName: "",
            bio: "Описание профиля"
        )
        
        let profile = Profile(profileResult: profileResult)
        view?.show(profile: profile)
    }
    
    func didTapLogout() {
        // TODO:
    }
}
