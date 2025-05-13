import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private lazy var nameLabel: UILabel = createLabel(
        text: "Екатерина Новикова",
        font: UIFont.systemFont(ofSize: 24, weight: .semibold),
        textColor: UIColor.ypWhite
    )
    
    private lazy var loginNameLabel: UILabel = createLabel(
        text: "@ekaterina_nov",
        font: UIFont.systemFont(ofSize: 13, weight: .regular),
        textColor: UIColor.ypWhiteAlpha50
    )
    
    private lazy var descriptionLabel: UILabel = createLabel(
        text: "Hello, world!",
        font: UIFont.systemFont(ofSize: 13, weight: .regular),
        textColor: UIColor.ypWhite
    )
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        return imageView
    } ()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "exit"), for: .normal)
        button.addTarget(nil, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var animationLayers = Set<CALayer>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.ypBlack
        
        setupAvatarImageView()
        setupProfileInfo()
        setupLogoutButton()
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        } else {
            addAnimation()
        }
        
        profileImageServiceObserver = NotificationCenter
            .default.addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }

    private func createLabel(text: String, font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = font
        label.textColor = textColor
        return label
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            return
        }
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "avatar"),
            options: [
                .transition(.fade(0.3))
            ]
        )
        
        removeAnimation()
    }
    
    private func setupAvatarImageView() {
        view.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }
    
    private func setupProfileInfo() {
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.bottomAnchor.constraint(equalTo: loginNameLabel.topAnchor, constant: -8),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupLogoutButton() {
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? ""
        
        removeAnimation()
    }
    
    @objc
    private func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока-пока!",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
        })
        present(alert, animated: true)
    }
    
    private func addAnimation() {
        func makeGradient(for view: UIView,
                          cornerRadius: CGFloat = 0) -> CAGradientLayer {
            
            let gradient = CAGradientLayer()
            gradient.frame = view.bounds
            gradient.colors = [
                UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
                UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
                UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
            ]
            gradient.locations    = [0, 0.1, 0.3]
            gradient.startPoint   = CGPoint(x: 0, y: 0.5)
            gradient.endPoint     = CGPoint(x: 1, y: 0.5)
            gradient.cornerRadius = cornerRadius
            gradient.masksToBounds = true
            
            let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
            gradientChangeAnimation.fromValue     = [0, 0.1, 0.3]
            gradientChangeAnimation.toValue       = [0, 0.8, 1]
            gradientChangeAnimation.duration      = 1.0
            gradientChangeAnimation.repeatCount   = .infinity
            gradient.add(gradientChangeAnimation, forKey: "shimmer")
            
            return gradient
        }
        
        let avatarGradient = makeGradient(for: avatarImageView,
                                          cornerRadius: avatarImageView.bounds.width / 2)
        avatarImageView.layer.addSublayer(avatarGradient)
        animationLayers.insert(avatarGradient)
        
        let nameGradient = makeGradient(for: nameLabel)
        nameLabel.layer.addSublayer(nameGradient)
        animationLayers.insert(nameGradient)
        
        let loginGradient = makeGradient(for: loginNameLabel)
        loginNameLabel.layer.addSublayer(loginGradient)
        animationLayers.insert(loginGradient)
        
        let descGradient = makeGradient(for: descriptionLabel)
        descriptionLabel.layer.addSublayer(descGradient)
        animationLayers.insert(descGradient)
    }
    
    private func removeAnimation() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
}
