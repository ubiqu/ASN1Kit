import Foundation

extension ASN1 {
    public typealias SetOf = ASN1.Set
    
    public class Set: ASN1.ConstructedItem {
        /// Construct an ASN.1 sequence from the children.
        /// - Note: This will automatically set the parent property for all the children.
        /// - Parameter items: The children of the sequence.
        public convenience init(_ items: [ASN1.Item]) {
            self.init(tag: .set, value: Data(items.map { $0.data }.joined()))
            children = items
            children.forEach({ $0.parent = self })
        }
    }
}
