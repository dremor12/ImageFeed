import UIKit
import Kingfisher

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol{
    
    var presenter: ProfilePresenterProtocol?
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
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
        return imageView
    } ()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "exit"), for: .normal)
        return button
    }()
    
    private var shimmerLayers = Set<CALayer>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppearance()
        presenter?.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }
    
    func show(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? ""
    }
    
    
    func showAvatar(url: URL?) {
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "avatar"),
            options: [
                .transition(.fade(0.3))
            ]
        )
        hideSkeleton()
    }
    
    func showSkeleton() {
        shimmerLayers.formUnion(
            ShimmerLayer.add(to: [avatarImageView],
                             cornerRadius: avatarImageView.bounds.width / 2)
        )
        shimmerLayers.formUnion(
            ShimmerLayer.add(to: [nameLabel, loginNameLabel, descriptionLabel])
        )
    }
    
    func hideSkeleton() {
        ShimmerLayer.remove(layers: shimmerLayers)
        shimmerLayers.removeAll()
    }
    
    private func configureAppearance() {
        view.backgroundColor = UIColor.ypBlack
        
        setupAvatarImageView()
        setupProfileInfo()
        setupLogoutButton()
        
        logoutButton.addTarget(self,
                                   action: #selector(logoutTapped),
                                   for: .touchUpInside)
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
    
    
    @objc
    private func logoutTapped() {
        let alert = UIAlertController(
            title: "Пока-пока!",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.presenter?.didTapLogout()
        })
        present(alert, animated: true)
    }

    private func createLabel(text: String, font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = font
        label.textColor = textColor
        return label
    }
}
