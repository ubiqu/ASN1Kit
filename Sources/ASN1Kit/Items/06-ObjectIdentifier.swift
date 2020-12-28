import Foundation

extension ASN1 {
    public typealias OID = ASN1.ObjectIdentifier
    
    public class ObjectIdentifier: ASN1.Item {
        /// Allowed object identifier characters.
        static let characters = CharacterSet(charactersIn: "0123456789.")
        
        /// Construct an ASN.1 OID from the OID string.
        /// - Parameter string: The OID string.
        public convenience init(oidString string: String) {
            precondition(Self.characters.isSuperset(of: .init(charactersIn: string)), "Invalid OID string '\(string)'")
            var parts: [Int] = string.split(separator: ".").map {
                precondition(Int(String($0)) != nil, "Invalid OID provided, cannot convert to integer")
                return Int(String($0))!
            }

            // First two nodes
            let a = parts.removeFirst()
            let b = parts.removeFirst()

            parts.insert(a * 40 + b, at: 0)

            let intBytes: [Data] = parts.map {
                let bytes = $0.bigEndian.trimmedBytes

                if bytes.count == 1 { return bytes }

                var base128 = $0.base128
                for i in 0 ..< base128.count - 1 {
                    base128[i] = base128[i] | 0b10000000
                }

                return Data(base128.map { $0.bigEndian.trimmedBytes }.joined())
            }
            self.init(tag: .objectIdentifier, value: Data(intBytes.joined()))
        }
        
        /// The decoded object identifier string.
        public var oidString: String {
            var oidBytes = value
            var oid = [Int]()
            let first = Int(oidBytes.remove(at: 0))
            oid.append(first / 40)
            oid.append(first % 40)

            var t = 0
            while oidBytes.count > 0 {
                let n = Int(oidBytes.remove(at: 0))
                t = (t << 7) | (n & 0x7F)
                if (n & 0x80) == 0 {
                    oid.append(t)
                    t = 0
                }
            }
            return oid.map { String("\($0)") }.joined(separator: ".")
        }
    }
}
