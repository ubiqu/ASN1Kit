import Foundation

extension ASN1 {
    public class UTF8String: ASN1.Item {
        /// Construct an ASN.1 UTF-8 string from a String.
        /// - Parameter utf8String: The UTF-8 encoded string.
        public convenience init(_ utf8String: String) {
            self.init(tag: .utf8String, value: utf8String.data(using: .utf8)!)
        }
        
        /// The decoded UTF-8 string.
        public var utf8String: String {
            return String(data: value, encoding: .utf8)!
        }
    }
}
