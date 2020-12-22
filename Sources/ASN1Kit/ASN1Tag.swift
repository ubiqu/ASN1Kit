import Foundation

extension ASN1 {
    public class Tag {
        // MARK: Class
        /// The tag class.
        ///
        /// The classes are the two first bits of the tags raw value.
        public enum Class: UInt8 {
            case universal       = 0b00000000
            case application     = 0b01000000
            case contextSpecific = 0b10000000
            case `private`       = 0b11000000
        }
        
        // MARK: Form
        
        /// The tag form.
        ///
        /// The form is the third bit of the tags raw value.
        public enum Form: UInt8 {
            case primitive   = 0b00000000
            case constructed = 0b00100000
        }
        
        // MARK: Value
        
        /// The tag value.
        ///
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
        private(set) public lazy var data: Data = {
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
    public static let endOfContent     = ASN1.Tag(class: .universal, form: .primitive, tagValue: .endOfContent)
    public static let boolean          = ASN1.Tag(class: .universal, form: .primitive, tagValue: .boolean)
    public static let integer          = ASN1.Tag(class: .universal, form: .primitive, tagValue: .integer)
    public static let bitString        = ASN1.Tag(class: .universal, form: .primitive, tagValue: .bitString)
    public static let octetString      = ASN1.Tag(class: .universal, form: .primitive, tagValue: .octetString)
    public static let null             = ASN1.Tag(class: .universal, form: .primitive, tagValue: .null)
    public static let objectIdentifier = ASN1.Tag(class: .universal, form: .primitive, tagValue: .objectIdentifier)
    public static let objectDescriptor = ASN1.Tag(class: .universal, form: .primitive, tagValue: .objectDescriptor)
    public static let external         = ASN1.Tag(class: .universal, form: .constructed, tagValue: .external)
    public static let real             = ASN1.Tag(class: .universal, form: .primitive, tagValue: .real)
    public static let enumerated       = ASN1.Tag(class: .universal, form: .primitive, tagValue: .enumerated)
    public static let embeddedPDV      = ASN1.Tag(class: .universal, form: .constructed, tagValue: .embeddedPDV)
    public static let utf8String       = ASN1.Tag(class: .universal, form: .primitive, tagValue: .utf8String)
    public static let relativeOID      = ASN1.Tag(class: .universal, form: .primitive, tagValue: .relativeOID)
    public static let time             = ASN1.Tag(class: .universal, form: .primitive, tagValue: .time)
    public static let sequence         = ASN1.Tag(class: .universal, form: .constructed, tagValue: .sequence)
    public static let set              = ASN1.Tag(class: .universal, form: .constructed, tagValue: .set)
    public static let numericString    = ASN1.Tag(class: .universal, form: .primitive, tagValue: .numericString)
    public static let printableString  = ASN1.Tag(class: .universal, form: .primitive, tagValue: .printableString)
    public static let t61String        = ASN1.Tag(class: .universal, form: .primitive, tagValue: .t61String)
    public static let videotexString   = ASN1.Tag(class: .universal, form: .primitive, tagValue: .videotexString)
    public static let ia5String        = ASN1.Tag(class: .universal, form: .primitive, tagValue: .ia5String)
    public static let utcTime          = ASN1.Tag(class: .universal, form: .primitive, tagValue: .utcTime)
    public static let generalizedTime  = ASN1.Tag(class: .universal, form: .primitive, tagValue: .generalizedTime)
    public static let graphicString    = ASN1.Tag(class: .universal, form: .primitive, tagValue: .graphicString)
    public static let visibleString    = ASN1.Tag(class: .universal, form: .primitive, tagValue: .visibleString)
    public static let generalString    = ASN1.Tag(class: .universal, form: .primitive, tagValue: .generalString)
    public static let universalString  = ASN1.Tag(class: .universal, form: .primitive, tagValue: .universalString)
    public static let characterString  = ASN1.Tag(class: .universal, form: .constructed, tagValue: .characterString)
    public static let bmpString        = ASN1.Tag(class: .universal, form: .primitive, tagValue: .bmpString)
    public static let date             = ASN1.Tag(class: .universal, form: .primitive, tagValue: .date)
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
