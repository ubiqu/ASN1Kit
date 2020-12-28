import Foundation

extension ASN1 {
    public class BMPString: ASN1.Item {
        public convenience init(_ bmpString: String) {
            precondition(Swift.Set(bmpString).map { CharacterSet($0.unicodeScalars).hasMember(inPlane: 0) }.reduce(true) { (result, value) -> Bool in
                result && value
            }, "Invalid BMP string '\(bmpString)'")
            self.init(tag: .bmpString, value: bmpString.data(using: .utf16BigEndian)!)
        }
        
        /// The decoded BMP string.
        public lazy var bmpString: String = {
            String(data: value, encoding: .utf16BigEndian)!
        }()
    }
}
