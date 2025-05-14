@testable import ImageFeed
import XCTest

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private(set) var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    var photosCount: Int { 0 }
    func photo(at indexPath: IndexPath) -> Photo? { nil }
    func formattedDate(for photo: Photo) -> String? { nil }
    func willDisplayCell(at indexPath: IndexPath) {}
    func didTapLike(at indexPath: IndexPath) {}
    func updatePhotoSize(_ newSize: CGSize, at indexPath: IndexPath) {}
}
