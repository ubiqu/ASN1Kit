import Foundation

extension ASN1 {
    public class OctetString: ASN1.Item {
        /// Construct an ASN.1 octetstring from binary data.
        /// - Parameter bytes: The binary data.
        public convenience init(_ bytes: Data) {
            self.init(Array(bytes))
        }
        
        /// Construct an ASN.1 octetstring from a byte array.
        /// - Parameter bytes: The array of bytes.
        public convenience init(_ bytes: [UInt8]) {
            self.init(tag: .octetString, value: Data(bytes))
        }
    }
}
