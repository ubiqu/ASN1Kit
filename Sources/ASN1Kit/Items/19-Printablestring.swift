import Foundation

extension ASN1 {
    public class PrintableString: ASN1.Item {
        /// Allowed printable string characters.
        static let characters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 '()+,-./:=?")
        
        /// Construct an ASN.1 printable string from a String.
        /// - Parameter printableString: The string to construct the item from.
        public convenience init(_ printableString: String) {
            precondition(Self.characters.isSuperset(of: .init(charactersIn: printableString)), "Invalid printable string '\(printableString)'")
            self.init(tag: .printableString, value: printableString.data(using: .ascii)!)
        }
        
        /// The decoded printable string.
        public lazy var printableString: String = {
            String(data: value, encoding: .ascii)!
        }()
    }
}
