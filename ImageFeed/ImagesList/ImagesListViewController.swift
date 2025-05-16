import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    private(set) var presenter: ImagesListPresenterProtocol?
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let photo = sender as? Photo,
              let cell = (tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? ImagesListCell)?.cellImage.image
        else {
            assertionFailure("Invalid segue destination")
            return
        }
        viewController.image = cell
        viewController.fullImageURL = URL(string: photo.fullImageUrl)
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
    
    func showImage(
        for cell: ImagesListCell,
        with url: URL,
        placeholder: UIImage?
    ) {
        cell.showAnimation()
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: url,
            placeholder: placeholder
        ) { _ in
            cell.hideAnimation()
        }
    }
    
    func setLike(_ isLiked: Bool, for cell: ImagesListCell) {
        cell.setIsLiked(isLiked)
    }
    
    func showProgress()   { UIBlockingProgressHUD.show() }
    func hideProgress()   { UIBlockingProgressHUD.dismiss() }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func openFullScreen(for photo: Photo, thumbnail: UIImage?) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: photo)
    }
}

extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate, ImagesListCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier,
                                                     for: indexPath) as? ImagesListCell,
            let photo = presenter?.photo(at: indexPath)
        else { return UITableViewCell() }
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.showAnimation()
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: url,
                                       placeholder: UIImage(named: "placeholder")) { [weak self] result in
                cell.hideAnimation()
                guard
                    let self,
                    case let .success(value) = result
                else { return }
                
                self.presenter?.updatePhotoSize(value.image.size, at: indexPath)
            }
        }
        
        cell.dateLabel.text = presenter?.formattedDate(for: photo)
        cell.setIsLiked(photo.isLiked)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photo(at: indexPath) else { return 0 }
        let insets  = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        let width   = tableView.bounds.width - insets.left - insets.right
        let scale   = width / photo.size.width
        return photo.size.height * scale + insets.top + insets.bottom
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        presenter?.willDisplayCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard let photo = presenter?.photo(at: indexPath),
              let cell   = tableView.cellForRow(at: indexPath) as? ImagesListCell
        else { return }
        
        openFullScreen(for: photo, thumbnail: cell.cellImage.image)
    }

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}
