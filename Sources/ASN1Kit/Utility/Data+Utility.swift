import Foundation

// MARK: - Mutating

extension Data {
    /// Removes and returns the range of data at the specified position.
    /// - Parameter range: The range to remove. `range` must be valid
    /// for the collection and should not exceed the collection's end index.
    /// - Returns: The removed data.
    @discardableResult mutating func remove(at range: Range<Data.Index>) -> Self {
        precondition(range.lowerBound >= 0, "Range invalid, lower bound cannot be below 0")
        precondition(range.upperBound <= self.count, "Range invalid, upper bound exceeds data size")
        
        defer { removeSubrange(range) }
        return subdata(in: range.relative(to: self))
    }
}

// MARK: - Hexadecimal decoding

/// A character set containing only hexadecimal characters.
let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")

extension String {
    /// Indication if a `String` contains only hexadecimal characters.
    var isHexString: Bool {
        return self.rangeOfCharacter(from: hexCharacterSet.inverted) == nil
    }
}

extension Character {
    /// If the character is a valid hexadecimal character, return it's raw value.
    ///
    /// Example: `'a' = 0x0a`.
    var hexadecimal: UInt8? {
        if !isASCII { return nil }
        
        if let a = asciiValue {
            if a < 58 {         // 0 - 9
                return a - 48
            } else if a < 71 {  // ABCDEF
                return a - 55
            } else if a < 103 { // abcdef
                return a - 87
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension Data {
    /// Initialize a `Data` object from a hexadecimal `String`.
    ///
    /// - Note: The initializer will fail when invalid hexadecimal data is provided.
    /// - Parameter hexString: The hexadecimal string.
    init?(hexString: String) {
        if !hexString.isHexString { return nil }
        
        var bytes           = [UInt8](repeating: 0, count: hexString.count / 2)
        var index           = 0
        var value: UInt8    = 0
        
        for character in hexString {
            if index % 2 == 0 {
                value = character.hexadecimal! << 4
            } else {
                value += character.hexadecimal!
                bytes[index / 2] = value
            }
            index += 1
        }
        self = Data(bytes)
    }
}

// MARK: - Hexadecimal encoding

/// The hexadecimal characters used when encoding bytes to hexadecimal string.
fileprivate let hexadecimalDictionary: [UInt8: Character] = [
    0x0: Character("0"), 0x1: Character("1"), 0x2: Character("2"), 0x3: Character("3"), 0x4: Character("4"),
    0x5: Character("5"), 0x6: Character("6"), 0x7: Character("7"), 0x8: Character("8"), 0x9: Character("9"),
    0xa: Character("a"), 0xb: Character("b"), 0xc: Character("c"),
    0xd: Character("d"), 0xe: Character("e"), 0xf: Character("f"),
]

extension UInt8 {
    /// Retrieve the two hexadecimal characters that make up the `UInt8`.
    ///
    /// Example: `0xE2 = ("E", "2")`
    var hexCharacters: (left: Character, right: Character) {
        let left    = hexadecimalDictionary[self >> 4]!
        let right   = hexadecimalDictionary[self & 0x0f]!
        return (left, right)
    }
}

extension Data {
    /// Retrieve the hexadecimal string for the data.
    var hexadecimal: String {
        var characters  = [Character](repeating: Character(" "), count: count * 2)
        
        var index = 0
        for byte in Array(self) {
            let hexadecimalCharacters   = byte.hexCharacters
            characters[index]           = hexadecimalCharacters.left
            characters[index + 1]       = hexadecimalCharacters.right
            index += 2
        }
        return String(characters)
    }
}
