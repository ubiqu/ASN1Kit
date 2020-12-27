import XCTest
@testable import ASN1Kit

final class ASN1KitTests: XCTestCase {
    func testStaticTags() {
        let encoded: [UInt8] = [
            0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x0C, 0x30, 0x31, 0x13, 0x14, 0x16, 0x1e
        ]
        let tags = [
            ASN1.Tag.boolean, ASN1.Tag.integer, ASN1.Tag.bitString, ASN1.Tag.octetString, ASN1.Tag.null,
            ASN1.Tag.objectIdentifier, ASN1.Tag.utf8String, ASN1.Tag.sequence, ASN1.Tag.set, ASN1.Tag.printableString,
            ASN1.Tag.t61String, ASN1.Tag.ia5String, ASN1.Tag.bmpString]
        
        for item in zip(encoded, tags) {
            XCTAssertEqual(item.0, item.1.data.first!)
        }
    }
    
    func testItem() {
        let boolData = Data([0x01])
        let bool = ASN1.Item(tag: .boolean, value: boolData)
        let boolEncoded = Data([0x01, 0x01, 0x01])
        XCTAssertEqual(bool.tag, .boolean)
        XCTAssertEqual(bool.length, boolData.count)
        XCTAssertEqual(bool.data, boolEncoded)
        
        let boolFromData = ASN1.Item(data: bool.data)
        XCTAssertEqual(boolFromData.tag, .boolean)
        XCTAssertEqual(boolFromData.length, boolData.count)
        XCTAssertEqual(boolFromData.data, boolEncoded)
    }
    
    func testExample() {}

    static var allTests = [
        ("testExample", testExample),
    ]
}
