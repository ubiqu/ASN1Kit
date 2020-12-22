import Foundation

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
        private(set) public var value: Data
        
        /// The parent of the item.
        internal(set) public weak var parent: ASN1.Item?
        /// The children of the item.
        public var children: [ASN1.Item]? {
            guard tag.isConstructed && !value.isEmpty else { return nil }
            
            var children = [ASN1.Item]()
            var data = value
            
            while !data.isEmpty {
                let child = ASN1.Item(data: data)
                child.parent = self
                data.removeSubrange(0 ..< child.data.count)
                children.append(child)
            }
            
            return children
        }
        
        // MARK: - Initializers
        
        /// Construct the ASN.1 item from its components.
        /// The length will be extracted from the value.
        /// - Parameters:
        ///   - tag: The tag of the item.
        ///   - value: The value of the item.
        public init(tag: Tag, value: Data) {
            self.tag    = tag
            self.value  = value
        }
        
        /// Initialize the item from encoded data.
        /// - Parameter data: The ASN.1 encoded data.
        public convenience init(data: Data) {
            precondition(!data.isEmpty, "Cannot construct an ASN.1 item from empty data")
            var data = data
            let tag = Tag(data.remove(at: 0))
            
            let extraLengthBytes = Self.extraLengthBytes(for: data)
            let length = Self.decodeLength(data: &data, extraLengthBytes: extraLengthBytes)
            
            precondition(data.count >= length, "Invalid data, length field exceeds end of data")
            let value = data.subdata(in: 0 ..< length)
            self.init(tag: tag, value: value)
        }
        
        // MARK: Encoding
        
        /// The encoded length value.
        var encodedLength: Data {
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
        
        // MARK: Decoding
        
        /// Calculate how many extra length bytes there are in the encoded data.
        ///
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
        
        /// Add a child to the item.
        /// - Parameter child: The child to append.
        public func add(child: ASN1.Item) {
            child.parent = self
            value.append(child.data)
        }
        
        public func filter(_ isIncluded: (ASN1.Item) throws -> Bool) rethrows -> [ASN1.Item] {
            var items = [ASN1.Item]()
            if try isIncluded(self) { items.append(self) }
            for child in children ?? [] {
                items.append(contentsOf: try child.filter(isIncluded))
            }
            return items
        }
        
        public func first(where predicate: (ASN1.Item) throws -> Bool) rethrows -> ASN1.Item? {
            if try predicate(self) { return self }
            for child in children ?? [] {
                return try child.first(where: predicate)
            }
            return nil
        }
        
        public func filter(on value: ASN1.Tag.Value) -> [ASN1.Item] {
            var items = [ASN1.Item]()
            if self.tag.value == value {
                items.append(self)
            }
            for child in children ?? [] {
                items.append(contentsOf: child.filter(on: value))
            }
            return items
        }
        
        /// Dump the ASN.1 item to the console.
        /// - Parameter inset: The number of insets to apply to the print.
        public func dump(inset: Int = 0) {
            if self.tag.isConstructed {
                print("\(String(repeating: "  ", count: inset))\(tag.data.hexadecimal) \(encodedLength.hexadecimal)")
                for child in children ?? [] {
                    child.dump(inset: inset + 1)
                }
            } else {
                let range = value.count > 30 ? 0 ..< 29 : 0 ..< value.count
                
                switch tag {
                case .objectIdentifier:
                    let oid = ASN1.OID(data: data)
                    print("\(String(repeating: "  ", count: inset))\(tag.data.hexadecimal) \(encodedLength.hexadecimal) \(value.subdata(in: range).hexadecimal) \(oid.oidString)")
                case .utf8String, .printableString, .videotexString, .ia5String, .bmpString:
                    guard let printableString = String(data: value, encoding: .utf8) else {
                        fallthrough
                    }
                    print("\(String(repeating: "  ", count: inset))\(tag.data.hexadecimal) \(encodedLength.hexadecimal) \(value.subdata(in: range).hexadecimal) \(printableString)")
                default:
                    print("\(String(repeating: "  ", count: inset))\(tag.data.hexadecimal) \(encodedLength.hexadecimal) \(value.subdata(in: range).hexadecimal)")
                }
            }
        }
    }
}
