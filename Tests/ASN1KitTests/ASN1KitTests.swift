import XCTest
@testable import ASN1Kit

final class ASN1KitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ASN1Kit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
