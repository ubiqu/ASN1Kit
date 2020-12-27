import Foundation

extension ASN1 {
    public class Boolean: ASN1.Item {
        /// Construct an ASN.1 boolean from the boolean value.
        /// - Parameter bool: The boolean value.
        public convenience init(bool: Bool) {
            self.init(tag: .boolean, value: bool ? Data([0x01]) : Data([0x00]))
        }
    }
}
