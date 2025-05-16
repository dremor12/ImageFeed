import Foundation
import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let logoutService: ProfileLogoutService
    private var avatarObserver: NSObjectProtocol?
    
    init(profileService: ProfileService = .shared,
         profileImageService: ProfileImageService = .shared,
         logoutService: ProfileLogoutService = .shared) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService  = logoutService
    }
    
    func viewDidLoad() {
        guard let view = view else { return }
        
        if let profile = profileService.profile {
            view.show(profile: profile)
            view.hideSkeleton()
        } else {
            view.showSkeleton()
        }
        view.showAvatar(url: avatarURL())
        observeAvatarChanges()
    }
    
    func didTapLogout() {
        logoutService.logout()
    }

    private func observeAvatarChanges() {
        avatarObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.view?.showAvatar(url: self.avatarURL())
        }
    }
    
    private func avatarURL() -> URL? {
        guard let urlString = profileImageService.avatarURL else { return nil }
        return URL(string: urlString)
    }
    
    deinit {
        if let avatarObserver { NotificationCenter.default.removeObserver(avatarObserver) }
    }
}
