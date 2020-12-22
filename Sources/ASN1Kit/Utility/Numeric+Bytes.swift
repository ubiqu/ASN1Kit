import Foundation

internal extension Numeric {
    /// The raw bytes of the numeric value.
    var bytes: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<Self>.size)
    }
    
    /// The raw bytes of the numeric value without the leading zeros.
    var trimmedBytes: Data {
        var bytes = self.bytes
        while let first = bytes.first, first == 0x00 {
            bytes.remove(at: 0)
        }
        // If the number is `0`, all bytes would've been removed.
        if bytes.count == 0 {
            bytes.insert(0, at: 0)
        }
        return bytes
    }
}
