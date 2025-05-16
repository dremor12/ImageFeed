import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard
            let imagesListViewController = storyboard.instantiateViewController(
                withIdentifier: "ImagesListViewController"
            ) as? ImagesListViewController
        else {
            fatalError("ImagesListViewController not found or wrong class in storyboard")
        }
        let imageListPresenter = ImagesListPresenter()
        imagesListViewController.configure(imageListPresenter)
        imageListPresenter.view = imagesListViewController
        
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.configure(profilePresenter)
        profilePresenter.view = profileViewController
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
