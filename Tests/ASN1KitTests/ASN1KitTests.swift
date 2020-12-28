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
    
    func testBoolean() {
        let booleanTrue = ASN1.Boolean(bool: true)
        XCTAssertEqual(booleanTrue.tag, .boolean)
        XCTAssertEqual(booleanTrue.value, Data([0x01]))
        
        let booleanFalse = ASN1.Boolean(bool: false)
        XCTAssertEqual(booleanFalse.tag, .boolean)
        XCTAssertEqual(booleanFalse.value, Data([0x00]))
        
        let booleanDecoded = ASN1.Item.decode(data: booleanTrue.data)
        XCTAssertTrue(booleanDecoded is ASN1.Boolean)
        XCTAssertEqual(booleanDecoded.tag, .boolean)
        XCTAssertEqual(booleanDecoded.value, Data([0x01]))
    }
    
    func testUnsignedInteger() {
        let a: UInt8 = 0x12
        let itemA = ASN1.Integer(a)
        XCTAssertEqual(itemA.tag, .integer)
        XCTAssertEqual(itemA.length, 1)
        XCTAssertEqual(itemA.data, Data([0x02, 0x01, 0x12]))
        
        let b: UInt16 = 0x1234
        let itemB = ASN1.Integer(b)
        XCTAssertEqual(itemB.tag, .integer)
        XCTAssertEqual(itemB.length, 2)
        XCTAssertEqual(itemB.data, Data([0x02, 0x02, 0x12, 0x34]))
        
        let c: UInt32 = 0x12345678
        let itemC = ASN1.Integer(c)
        XCTAssertEqual(itemC.tag, .integer)
        XCTAssertEqual(itemC.length, 4)
        XCTAssertEqual(itemC.data, Data([0x02, 0x04, 0x12, 0x34, 0x56, 0x78]))
        
        let d: UInt64 = 0x1234567887654321
        let itemD = ASN1.Integer(d)
        XCTAssertEqual(itemD.tag, .integer)
        XCTAssertEqual(itemD.length, 8)
        XCTAssertEqual(itemD.data, Data([0x02, 0x08, 0x12, 0x34, 0x56, 0x78, 0x87, 0x65, 0x43, 0x21]))
        
        let e = UInt(a)
        let itemE = ASN1.Integer(e)
        XCTAssertEqual(itemE.tag, .integer)
        XCTAssertEqual(itemE.length, 1)
        XCTAssertEqual(itemE.data, Data([0x02, 0x01, 0x12]))
        
        let integerDecoded = ASN1.Item.decode(data: itemE.data)
        XCTAssertTrue(integerDecoded is ASN1.Integer)
        XCTAssertEqual(integerDecoded.tag, .integer)
        XCTAssertEqual(integerDecoded.value, Data([0x12]))
    }
    
    func testSignedInteger() {
        let a: Int8 = 0x12
        let itemA = ASN1.Integer(a)
        XCTAssertEqual(itemA.tag, .integer)
        XCTAssertEqual(itemA.length, 1)
        XCTAssertEqual(itemA.data, Data([0x02, 0x01, 0x12]))
        
        let b: Int16 = 0x1234
        let itemB = ASN1.Integer(b)
        XCTAssertEqual(itemB.tag, .integer)
        XCTAssertEqual(itemB.length, 2)
        XCTAssertEqual(itemB.data, Data([0x02, 0x02, 0x12, 0x34]))
        
        let c: Int32 = 0x12345678
        let itemC = ASN1.Integer(c)
        XCTAssertEqual(itemC.tag, .integer)
        XCTAssertEqual(itemC.length, 4)
        XCTAssertEqual(itemC.data, Data([0x02, 0x04, 0x12, 0x34, 0x56, 0x78]))
        
        let d: Int64 = 0x1234567887654321
        let itemD = ASN1.Integer(d)
        XCTAssertEqual(itemD.tag, .integer)
        XCTAssertEqual(itemD.length, 8)
        XCTAssertEqual(itemD.data, Data([0x02, 0x08, 0x12, 0x34, 0x56, 0x78, 0x87, 0x65, 0x43, 0x21]))
        
        let e = Int(a)
        let itemE = ASN1.Integer(e)
        XCTAssertEqual(itemE.tag, .integer)
        XCTAssertEqual(itemE.length, 1)
        XCTAssertEqual(itemE.data, Data([0x02, 0x01, 0x12]))
        
        let integerDecoded = ASN1.Item.decode(data: itemE.data)
        XCTAssertTrue(integerDecoded is ASN1.Integer)
        XCTAssertEqual(integerDecoded.tag, .integer)
        XCTAssertEqual(integerDecoded.value, Data([0x12]))
    }
    
    /// Make sure negative numbers are encoded correctly.
    func testSignedIntegerNegative() {
        let a = -26731
        let itemA = ASN1.Integer(a)
        XCTAssertEqual(itemA.tag, .integer)
        XCTAssertEqual(itemA.length, 2)
        XCTAssertEqual(itemA.data, Data([0x02, 0x02, 0x97, 0x95]))
        
        let b = -127
        let itemB = ASN1.Integer(b)
        XCTAssertEqual(itemB.tag, .integer)
        XCTAssertEqual(itemB.length, 1)
        XCTAssertEqual(itemB.data, Data([0x02, 0x01, 0x81]))
        
        let c = -128
        let itemC = ASN1.Integer(c)
        XCTAssertEqual(itemC.tag, .integer)
        XCTAssertEqual(itemC.length, 1)
        XCTAssertEqual(itemC.data, Data([0x02, 0x01, 0x80]))
    }
    
    /// Make sure positive numbers get the prepended zeros.
    func testSignedIntegerPositive() {
        let a = 128
        let itemA = ASN1.Integer(a)
        XCTAssertEqual(itemA.tag, .integer)
        XCTAssertEqual(itemA.length, 2)
        XCTAssertEqual(itemA.data, Data([0x02, 0x02, 0x00, 0x80]))
    }
    
    func testBitString() {
        let encoded: [Data] = [
            Data([0x07, 0x80]), Data([0x06, 0xc0]),
            Data([0x05, 0xe0]), Data([0x04, 0xf0]),
            Data([0x03, 0xf8]), Data([0x02, 0xfc]),
            Data([0x01, 0xfe]), Data([0x00, 0xff])
        ]
        
        for bits in 1 ... 8 {
            let bitString = String(repeating: "1", count: bits)
            let unused = UInt8(8 - bits)
            
            let item = ASN1.BitString(bitString: bitString)
            XCTAssertEqual(item.value.first, unused)
            XCTAssertEqual(item.value, encoded[bits - 1])
        }
        
        let bitStringEncoded = Data([0x03, 0x02, 0x02, 0xfc])
        let bitString = ASN1.Item.decode(data: bitStringEncoded)
        XCTAssertTrue(bitString is ASN1.BitString)
        XCTAssertEqual(bitString.tag, .bitString)
        XCTAssertEqual(bitString.data, bitStringEncoded)
    }
    
    func testOctetString() {
        let data = Data(repeating: .random(in: 0 ... UInt8.max), count: .random(in: 0 ..< 5000))
        let octetItem = ASN1.OctetString(data)
        XCTAssertEqual(octetItem.tag, .octetString)
        XCTAssertEqual(octetItem.length, data.count)
        XCTAssertEqual(octetItem.value, data)
        
        let octetDecoded = ASN1.Item.decode(data: octetItem.data)
        XCTAssertTrue(octetDecoded is ASN1.OctetString)
        XCTAssertEqual(octetDecoded.tag, .octetString)
        XCTAssertEqual(octetDecoded.data, octetItem.data)
        XCTAssertEqual(octetDecoded.value, data)
    }

    static var allTests = [
        ("testStaticTags", testStaticTags),
        ("testItem", testItem),
        ("testUnsignedInteger", testUnsignedInteger),
        ("testSignedInteger", testSignedInteger),
        ("testSignedIntegerNegative", testSignedIntegerNegative),
        ("testSignedIntegerPositive", testSignedIntegerPositive),
        ("testBitString", testBitString),
        ("testOctetString", testOctetString)
    ]
}
