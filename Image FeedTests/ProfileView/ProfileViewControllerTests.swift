@testable import ImageFeed
import XCTest
import Foundation

final class ProfileTests: XCTestCase {
    func testViewControllerCallsPresenterViewDidLoad() {
     
        let presenterSpy = ProfilePresenterSpy()
        let sut = ProfileViewController()
        sut.configure(presenterSpy)

        _ = sut.view
   
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "viewDidLoad() у presenter должен быть вызван")
    }
    

    func testConfigureSetsPresenterAndView() {
      
        let presenterSpy = ProfilePresenterSpy()
        let sut = ProfileViewController()

        sut.configure(presenterSpy)

        XCTAssertTrue(presenterSpy.view === sut, "View у presenter должна указывать на ViewController после configure()")
    }
    
    func testPresenterSetsProfileData_onViewDidLoad() {
        let viewSpy = ProfileViewSpy()
        let presenter = ProfilePresenterWithFakeData()
        presenter.view = viewSpy

        presenter.viewDidLoad()
        
        XCTAssertTrue(viewSpy.showProfileCalled)
        XCTAssertEqual(viewSpy.receivedProfile?.name, "Имя ")
        XCTAssertEqual(viewSpy.receivedProfile?.loginName, "@login")
        XCTAssertEqual(viewSpy.receivedProfile?.bio, "Описание профиля")
    }
}
