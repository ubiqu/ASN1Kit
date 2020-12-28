import Foundation

extension ASN1 {
    public class IA5String: ASN1.Item {
        /// Construct an ASN.1 IA5 string from a String.
        /// - Parameter ia5String: The IA5 encoded string.
        public convenience init(_ ia5String: String) {
            self.init(tag: .ia5String, value: ia5String.data(using: .ascii)!)
        }
        
        /// The decoded IA5 string.
        public lazy var ia5String: String = {
            String(data: value, encoding: .utf8)!
        }()
    }
}
