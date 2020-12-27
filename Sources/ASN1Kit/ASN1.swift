import Foundation

public enum ASN1 {}

// MARK: - Tag
extension ASN1 {
    public class Tag {
        // MARK: Class
        
        /// The tag class.
        /// The classes are the two first bits of the tags raw value.
        public enum Class: UInt8 {
            case universal       = 0b00000000
            case application     = 0b01000000
            case contextSpecific = 0b10000000
            case `private`       = 0b11000000
        }
        
        // MARK: Form
        
        /// The tag form.
        /// The form is the third bit of the tags raw value.
        public enum Form: UInt8 {
            case primitive   = 0b00000000
            case constructed = 0b00100000
        }
        
        // MARK: Value
        
        /// The tag value.
        /// The value is the last five bits of the tags raw value.
        public enum Value: UInt8 {
            case endOfContent     = 0b00000000
            case boolean          = 0b00000001
            case integer          = 0b00000010
            case bitString        = 0b00000011
            case octetString      = 0b00000100
            case null             = 0b00000101
            case objectIdentifier = 0b00000110
            case objectDescriptor = 0b00000111
            case external         = 0b00001000
            case real             = 0b00001001
            case enumerated       = 0b00001010
            case embeddedPDV      = 0b00001011
            case utf8String       = 0b00001100
            case relativeOID      = 0b00001101
            case time             = 0b00001110
            //   reserved         = 0b00001111
            case sequence         = 0b00010000
            case set              = 0b00010001
            case numericString    = 0b00010010
            case printableString  = 0b00010011
            case t61String        = 0b00010100
            case videotexString   = 0b00010101
            case ia5String        = 0b00010110
            case utcTime          = 0b00010111
            case generalizedTime  = 0b00011000
            case graphicString    = 0b00011001
            case visibleString    = 0b00011010
            case generalString    = 0b00011011
            case universalString  = 0b00011100
            case characterString  = 0b00011101
            case bmpString        = 0b00011110
            case date             = 0b00011111
            //   timeOfDay        = 0b00100000
            //   dateTime         = 0b00100001
            //   duration         = 0b00100010
            //   oidIRI           = 0b00100011
            //   relativeOIDIRI   = 0b00100100
        }
        
        // MARK: - Properties
        
        /// The class of the tag.
        public let `class`: Class
        /// The form of the tag.
        public let form: Form
        /// The encoded value of the tag.
        public let value: Value
        
        /// The encoded tag.
        public lazy var data: Data = {
            Data([self.class.rawValue | form.rawValue | value.rawValue])
        }()
        
        /// Boolean value indicating whether or not the tag is a primitive.
        public lazy var isPrimitive: Bool = {
            form == .primitive
        }()
        /// Boolean value indicating whether or not the tag is constructed.
        public lazy var isConstructed: Bool = {
            form == .constructed
        }()
        
        // MARK: - Initializers
        
        /// Construct the tag from its raw byte.
        /// - Parameter encoded: The byte that makes up the tag.
        public init(_ rawValue: UInt8) {
            `class` = Class(rawValue: rawValue & 0b11000000)!
            form    = Form(rawValue: rawValue & 0b00100000)!
            value   = Value(rawValue: rawValue & 0b00011111)!
        }
        
        /// Construct the tag from its required components.
        /// - Parameters:
        ///   - c: The class of the tag.
        ///   - form: The form of the tag.
        ///   - tagValue: The value of the tag.
        public convenience init(class c: Class, form: Form, tagValue: Value) {
            self.init(class: c, form: form, tagValue: tagValue.rawValue)
        }
        
        /// Construct the tag from its required components.
        /// - Parameters:
        ///   - c: The class of the tag.
        ///   - form: The form of the tag.
        ///   - tagValue: The value of the tag.
        public convenience init(class c: Class, form: Form, tagValue: UInt8) {
            self.init(c.rawValue | form.rawValue | tagValue)
        }
    }
}

// MARK: - Universal ASN.1 tags
extension ASN1.Tag {
    public static let boolean          = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .boolean)
    public static let integer          = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .integer)
    public static let bitString        = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .bitString)
    public static let octetString      = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .octetString)
    public static let null             = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .null)
    public static let objectIdentifier = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .objectIdentifier)
    public static let utf8String       = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .utf8String)
    public static let sequence         = ASN1.Tag(class: .universal, form: .constructed, tagValue: .sequence)
    public static let set              = ASN1.Tag(class: .universal, form: .constructed, tagValue: .set)
    public static let printableString  = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .printableString)
    public static let t61String        = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .t61String)
    public static let ia5String        = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .ia5String)
    public static let bmpString        = ASN1.Tag(class: .universal, form: .primitive,   tagValue: .bmpString)
}

// MARK: Equatable
extension ASN1.Tag: Equatable {
    public static func == (lhs: ASN1.Tag, rhs: ASN1.Tag) -> Bool {
        lhs.data.first! == rhs.data.first!
    }
}

// MARK: Comparable
extension ASN1.Tag: Comparable {
    public static func < (lhs: ASN1.Tag, rhs: ASN1.Tag) -> Bool {
        lhs.data.first! < rhs.data.first!
    }
}

// MARK: - Item
extension ASN1 {
    public class Item {
        // MARK: - Properties
        
        /// The tag of the item.
        public let tag: Tag
        /// The length of the item.
        public var length: Int {
            value.count
        }
        /// The value of the item.
        public let value: Data
        
        // MARK: - Initializers
        
        /// Construct the ASN.1 item from its components.
        /// The length will be extracted from the value.
        /// - Parameters:
        ///   - tag: The tag of the item.
        ///   - value: The value of the item.
        internal init(tag: Tag, value: Data) {
            self.tag    = tag
            self.value  = value
        }
        
        /// Initialize the item from encoded data.
        /// - Parameter data: The ASN.1 encoded data.
        internal convenience init(data: Data) {
            precondition(!data.isEmpty, "Cannot construct an ASN.1 item from empty data")
            var data = data
            let tag = Tag(data.remove(at: 0))

            let extraLengthBytes = Self.extraLengthBytes(for: data)
            let length = Self.decodeLength(data: &data, extraLengthBytes: extraLengthBytes)

            precondition(data.count >= length, "Invalid data, length field exceeds end of data")
            let value = data.subdata(in: 0 ..< length)
            self.init(tag: tag, value: value)
        }
        
        /// Decode ASN.1 data.
        /// - Parameter data: The data to decode.
        /// - Returns: The created ASN.1 item.
        public static func decode(data: Data) -> ASN1.Item {
            precondition(!data.isEmpty, "Cannot construct an ASN.1 item from empty data")
            let tag = ASN1.Tag(data.first!)
            
            switch tag {
            default:
                print("Unimplemented dedicated class for tag \(tag)")
                return ASN1.Item(data: data)
            }
        }
    }
}

// MARK: Encoding
extension ASN1.Item {
    /// The encoded length value.
    private var encodedLength: Data {
        // Array conversion is required, otherwise the insert method is going to complain.
        var lengthBytes = Array(UInt(length).bigEndian.trimmedBytes)

        if length > 0b01111111 {                                                // Long form
            lengthBytes.insert(0b10000000 | UInt8(lengthBytes.count), at: 0)    // Insert length providing byte
        }
        return Data(lengthBytes)
    }

    /// The encoded item.
    public var data: Data {
        tag.data + encodedLength + value
    }
}

// MARK: Decoding
extension ASN1.Item {
    /// Calculate how many extra length bytes there are in the encoded data.
    /// - Parameter data: The encoded data starting at the length providing byte.
    /// - Returns: The amount of extra length bytes.
    private static func extraLengthBytes(for data: Data) -> Int {
        precondition(!data.isEmpty, "Invalid data, data is empty")
        let lengthProvidingByte = data.first!
        if (lengthProvidingByte & 0b10000000) == 0b10000000 {
            return Int(lengthProvidingByte & 0b01111111)
        }
        return 0
    }

    /// Decode the length of the encoded data.
    /// - Parameters:
    ///   - data: The encoded data to decode the length from. This data should
    ///   still contain the length providing byte.
    ///   - extraLengthBytes: The number of length bytes to decode.
    /// - Returns: The decoded length.
    private static func decodeLength(data: inout Data, extraLengthBytes: Int) -> Int {
        precondition(!data.isEmpty, "Invalid data, data is empty")
        precondition(data.first != 0x80, "Invalid data, unsupported BER length. Only definite DER lengths are supported")

        if extraLengthBytes == 0 {              // Short form
            return Int(data.remove(at: 0))
        } else {                                // Long form
            data.remove(at: 0)                  // Remove the length providing byte.
            var lengthBytes = data.remove(at: 0 ..< extraLengthBytes)
            while lengthBytes.count < MemoryLayout<Int>.size {
                lengthBytes.insert(0, at: 0)    // Required to load into memory; prepend leading zeros.
            }
            return lengthBytes.withUnsafeBytes { $0.load(as: Int.self) }.bigEndian
        }
    }
}

