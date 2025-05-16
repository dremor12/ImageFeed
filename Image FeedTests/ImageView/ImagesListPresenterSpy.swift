@testable import ImageFeed
import XCTest

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photosCount: Int { 0 }

    private(set) var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func photo(at indexPath: IndexPath) -> Photo? { nil }
    func formattedDate(for photo: Photo) -> String? { nil }
    func willDisplayCell(at indexPath: IndexPath) {}
    func didTapLike(at indexPath: IndexPath) {}
    func updatePhotoSize(_ newSize: CGSize, at indexPath: IndexPath) {}
}
