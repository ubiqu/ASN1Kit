import Foundation

extension ASN1 {
    public class Null: ASN1.Item {
        /// Construct an ASN.1 null.
        public convenience init() {
            self.init(tag: .null, value: Data())
        }
    }
}
