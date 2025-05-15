import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    private enum Constants {
        static let email = "email@exemple.com"
        static let password = "password"
        static let firstNameAndLastName = "Test Test"
        static let username = "login"
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        
        loginTextField.tap()
        loginTextField.typeText(Constants.email)
        
        app.buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        
        passwordTextField.tap()
        sleep(2)
        
        passwordTextField.typeText(Constants.password)
        
        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
        }
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let table = app.tables.element(boundBy: 0)
        
        table.cells.element(boundBy: 0).swipeUp()
        
        let cellToLike = table.cells.element(boundBy: 1)
        while !cellToLike.isHittable {
            table.swipeUp()
        }
        
        let likeButton = cellToLike.buttons["favorites no active"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()
        
        let likedButton = cellToLike.buttons["favorites active"]
        XCTAssertTrue(likedButton.waitForExistence(timeout: 5))
        likedButton.tap()
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let back = app.buttons["nav back button white"]
        XCTAssertTrue(back.waitForExistence(timeout: 5))
        back.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts[Constants.firstNameAndLastName].exists)
        XCTAssertTrue(app.staticTexts["@\(Constants.username)"].exists)
        
        app.buttons["exit"].tap()
        
        app.alerts["Пока-пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
