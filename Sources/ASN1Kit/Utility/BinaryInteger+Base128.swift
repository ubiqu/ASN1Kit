import Foundation

extension BinaryInteger {
    /// Calculate the quotient and remainder of two numbers.
    ///
    /// Example
    /// ```
    /// Int.divmod(5, 3)  // (quotient: 1, remainder: 2)
    /// ```
    ///
    /// - Parameters:
    ///   - divident: The divident.
    ///   - divisor: The divisor.
    /// - Returns: A tuple containing the quotient and remainder.
    static func divmod(_ divident: Self, _ divisor: Self) -> (quotient: Self, remainder: Self) {
        (divident / divisor, divident % divisor)
    }
    
    /// Convert the `BinaryInteger` to its base128 parts.
    ///
    /// ```
    /// let x = 840
    /// let b128 = x.base128
    /// // [6, 72]
    /// ```
    var base128: [Self] {
        precondition(self >= 0, "Cannot convert to base128 below zero.")
        if self > 0 {
            var n = self
            var arr: [Self] = [Self]()
            while n > 0 {
                let d = Self.divmod(n, 128)
                arr.append(d.remainder)
                n = d.quotient
            }
            return arr.reversed()
        } else {
            return [0x00]
        }
    }
}
