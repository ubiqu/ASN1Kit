import Foundation

extension ASN1 {
    public class BitString: ASN1.Item {
        /// Allowed bitstring characters.
        static let characters = CharacterSet(charactersIn: "01")
        
        /// Construct an ASN.1 bitstring from a bitstring.
        /// - Parameter bitString: The bitstring.
        public convenience init(bitString: String) {
            precondition(Self.characters.isSuperset(of: .init(charactersIn: bitString)), "Invalid bitstring '\(bitString)'")
            var copy = bitString
            var data = Data()
            
            // While there are eight bits available
            while copy.count / 8 > 0 {
                let range = copy.startIndex ..< copy.index(copy.startIndex, offsetBy: 8)
                let bits = String(copy[range])
                // Transform and append the byte represented by the bits
                data.append(UInt8(bits, radix: 2)!)
                copy.removeSubrange(range)
            }
            // When there is data left
            if copy.count > 0 {
                let paddingBits = 8 - copy.count
                // Apply padding and add to the output
                data.append(UInt8("\(copy)\(String(repeating: "0", count: paddingBits))", radix: 2)!)
                // First byte defines how many unused bits are appended
                data.insert(UInt8(paddingBits), at: 0)
            } else {
                // No extra data left, no unused bits are appended
                data.insert(UInt8(0x00), at: 0)
            }
            
            self.init(tag: .bitString, value: data)
        }
        
        /// The decoded bitstring.
        public lazy var bitString: String = {
            var copy = value
            let unused = Int(copy.removeFirst())
            var bitString = copy.map { $0.bitString }.joined()
            bitString.removeLast(unused)
            return bitString
        }()
    }
}

fileprivate extension UInt8 {
    /// The bits that make up the byte.
    var bitString: String {
        String(repeating: "0", count: leadingZeroBitCount) + (self > 0 ? String(self, radix: 2) : "")
    }
}
