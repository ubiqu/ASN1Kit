import Foundation

extension ASN1 {
    public class Integer: ASN1.Item {
        public convenience init(_ uint64: UInt64) {
            var data = uint64.byteSwapped.bytes
            
            while data.first == 0x00 {
                data.remove(at: 0)
            }
            // Empty data means 0
            if data.isEmpty {
                data.insert(0x00, at: 0)
            }
            // Unsigned integers cannot be negative. Apply zero byte when needed
            if data.first! & 0b1000_0000 == 0b1000_0000 {
                data.insert(0x00, at: 0)
            }
            
            self.init(tag: .integer, value: data)
        }
        
        public convenience init(_ uint8: UInt8) {
            self.init(UInt64(uint8))
        }
        
        public convenience init(_ uint16: UInt16) {
            self.init(UInt64(uint16))
        }
        
        public convenience init(_ uint32: UInt32) {
            self.init(UInt64(uint32))
        }
        
        public convenience init(_ uint: UInt) {
            self.init(UInt64(uint))
        }
        
        public convenience init(_ int64: Int64) {
            var data = int64.byteSwapped.bytes
            
            // Remove leading bytes (0xff for negative, 0x00 for positive)
            while data.first == (int64 < 0 ? 0xff : 0x00) {
                data.remove(at: 0)
            }
            // Empty data means 0
            if data.isEmpty {
                data.insert(0x00, at: 0)
            }
            // Apply zero byte when the number is positive
            if int64 >= 0 && (data.first! & 0b1000_0000 == 0b1000_0000) {
                data.insert(0x00, at: 0)
            }
            self.init(tag: .integer, value: data)
        }
        
        public convenience init(_ int8: Int8) {
            self.init(Int64(int8))
        }
        
        public convenience init(_ int16: Int16) {
            self.init(Int64(int16))
        }
        
        public convenience init(_ int32: Int32) {
            self.init(Int64(int32))
        }
        
        public convenience init(_ int: Int) {
            self.init(Int64(int))
        }
        
        /// The decoded `UInt` value.
        public lazy var uint: UInt = {
            var copy = value
            while copy.count < MemoryLayout<UInt>.size {
                copy.insert(0, at: 0)
            }
            return copy.withUnsafeBytes { $0.load(as: UInt.self) }.bigEndian
        }()
        
        /// The decoded `Int` value.
        public lazy var int: Int = {
            var copy = value
            while copy.count < MemoryLayout<UInt>.size {
                copy.insert(copy.first! & 0b1000_0000 == 0b1000_0000 ? 0xff : 0x00, at: 0)
            }
            return copy.withUnsafeBytes { $0.load(as: Int.self) }.bigEndian
        }()
    }
}
