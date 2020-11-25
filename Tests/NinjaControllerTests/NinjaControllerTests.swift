import XCTest
@testable import NinjaController

final class NinjaControllerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NinjaController().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
