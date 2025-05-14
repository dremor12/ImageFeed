import Foundation
import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {

    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesService: ImagesListService
    private let dateFormatter: DateFormatter
    private var photos: [Photo] = []
    
    private var photosObserver: NSObjectProtocol?
    
    init(imagesService: ImagesListService = .shared) {
        self.imagesService = imagesService
        
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
    }
    
    deinit {
        if let photosObserver { NotificationCenter.default.removeObserver(photosObserver) }
    }
    
    func viewDidLoad() {
        observePhotos()
        imagesService.fetchPhotosNextPage()
    }
    
    var photosCount: Int { photos.count }
    
    func photo(at indexPath: IndexPath) -> Photo? {
        guard photos.indices.contains(indexPath.row) else { return nil }
        return photos[indexPath.row]
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        guard !imagesService.isLoading,
              indexPath.row == photos.count - 1
        else { return }
        imagesService.fetchPhotosNextPage()
    }
    
    func didTapLike(at indexPath: IndexPath) {
        guard photos.indices.contains(indexPath.row) else { return }
        let photo = photos[indexPath.row]
        
        view?.showProgress()
        imagesService.changeLike(photoId: photo.id,
                                 isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            self.view?.hideProgress()
            
            switch result {
            case .success:
                self.photos = self.imagesService.photos
                self.view?.reloadRows(at: [indexPath])
            case .failure:
                self.view?.showErrorAlert(message: "Не удалось поставить лайк")
            }
        }
    }
    
    func updatePhotoSize(_ newSize: CGSize, at indexPath: IndexPath) {
        guard photos.indices.contains(indexPath.row) else { return }
        if photos[indexPath.row].size != newSize {
            photos[indexPath.row].size = newSize
            view?.reloadRows(at: [indexPath])
        }
    }

    
    private func observePhotos() {
        photosObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: imagesService,
            queue: .main
        ) { [weak self] _ in
            self?.handlePhotosChanged()
        }
    }
    
    private func handlePhotosChanged() {
        let oldCount = photos.count
        let newCount = imagesService.photos.count
        photos = imagesService.photos
        
        guard newCount != oldCount else { return }
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        view?.insertRows(at: indexPaths)
    }
    
    func formattedDate(for photo: Photo) -> String? {
        guard let date = photo.createdAt else { return nil }
        return dateFormatter.string(from: date)
    }
}
