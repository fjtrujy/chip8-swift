import XCTest
@testable import CHIP8

final class CHIP8Tests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CHIP8().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
