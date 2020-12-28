import Foundation

extension ASN1 {
    public typealias SequenceOf = ASN1.Sequence
    
    public class Sequence: ASN1.Item, ConstructedItem {
        /// Construct an ASN.1 sequence from the children.
        /// - Note: This will automatically set the parent property for all the children.
        /// - Parameter items: The children of the sequence.
        public convenience init(_ items: [ASN1.Item]) {
            self.init(tag: .sequence, value: Data(items.map { $0.data }.joined()))
            items.forEach { $0.parent = self }
        }
    }
}
