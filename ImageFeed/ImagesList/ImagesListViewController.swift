import UIKit
import Kingfisher


final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePhotosNotification),
            name: ImagesListService.didChangeNotification,
            object: imagesListService
        )
        imagesListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
                    
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let photo = photos[indexPath.row]
            
            if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
                viewController.image = cell.cellImage.image
            }
            viewController.fullImageURL = URL(string: photo.fullImageUrl)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configCell(for cell: ImagesListCell, with photo: Photo, at indexPath: IndexPath) {
        guard let url = URL(string: photo.thumbImageURL) else { return }
        
        cell.showAnimation()
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder")) { [weak self] result in
            cell.hideAnimation()
            guard let self,
                  case let .success(value) = result
            else { return }
            
            let realSize = value.image.size
            if self.photos[indexPath.row].size != realSize {
                self.photos[indexPath.row].size = realSize
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                }
            }
        }
        
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        }
        
        cell.setIsLiked(photo.isLiked)
    }
    
    @objc
    private func didReceivePhotosNotification(_ notification: Notification) {
        updateTableViewAnimated()
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        guard newCount != oldCount else { return }
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard photos.indices.contains(indexPath.row) else { return 0 }
        let photoSize = photos[indexPath.row].size
        let insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        let targetWidth = tableView.bounds.width - insets.left - insets.right
        let scale = targetWidth / photoSize.width
        return photoSize.height * scale + insets.top + insets.bottom
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !imagesListService.isLoading,
              indexPath.row == photos.count - 1
        else { return }
        imagesListService.fetchPhotosNextPage()
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        let photo = photos[indexPath.row]
        configCell(for: cell, with: photo, at: indexPath)
        cell.delegate = self
        return cell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
       guard let indexPath = tableView.indexPath(for: cell) else { return }
       let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
                
            case .failure:
                UIBlockingProgressHUD.dismiss()
                let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Попробуйте ещё раз позже",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
