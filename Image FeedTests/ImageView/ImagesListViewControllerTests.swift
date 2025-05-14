@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_callsPresenterViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenterSpy = ImagesListPresenterSpy()
        sut.configure(presenterSpy)
        
        _ = sut.view
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled,
                      "ImagesListViewController должен вызывать presenter.viewDidLoad() в viewDidLoad()")
    }
    
    func test_configure_setsPresenterViewBacklink() {
        let sut = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        
        sut.configure(presenterSpy)

        XCTAssertTrue(presenterSpy.view === sut,
                      "После configure(_:) presenter.view должен указывать на контроллер")
    }
}
