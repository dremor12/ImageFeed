import Foundation
import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }

    var photosCount: Int { get }
    
    func viewDidLoad()
    func photo(at indexPath: IndexPath) -> Photo?
    func formattedDate(for photo: Photo) -> String?
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
    func updatePhotoSize(_ newSize: CGSize, at indexPath: IndexPath)
}

protocol ImagesListViewControllerProtocol: AnyObject {
    func insertRows(at indexPaths: [IndexPath])
    func reloadRows(at indexPaths: [IndexPath])
    
    func showImage(for cell: ImagesListCell, with url: URL, placeholder: UIImage?)
    func setLike(_ isLiked: Bool, for cell: ImagesListCell)
    
    func showProgress()
    func hideProgress()
    func showErrorAlert(message: String)
    func openFullScreen(for photo: Photo, thumbnail: UIImage?)
}
