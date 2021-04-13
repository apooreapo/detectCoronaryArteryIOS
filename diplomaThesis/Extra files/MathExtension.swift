//
//  MathExtension.swift
//  diplomaThesis
//
//  Created by User on 10/3/21.
//

import Foundation


extension Array where Element: FloatingPoint {

    
    /// Calculates the sum of an array.
    /// - Returns: The sum of the array's elements
    func sum() -> Element {
        return self.reduce(0, +)
    }

    
    /// Calculates the average of an array.
    /// - Returns: The average of the array's elements
    func avg() -> Element {
        return self.sum() / Element(self.count)
    }

    
    /// Calculates the standard deviation of an array.
    /// - Returns: The standard deviation of an array's elements
    func std() -> Element {
        let mean = self.avg()
        let v = self.reduce(0, { $0 + ($1-mean)*($1-mean) })
        return sqrt(v / (Element(self.count) - 1))
    }

}

extension Array where Element == Int {

    /// Calculates the sum of an array.
    /// - Returns: The sum of the array's elements
    func sum() -> Element {
        return self.reduce(0, +)
    }

    /// Calculates the average of an array.
    /// - Returns: The average of the array's elements
    func avg() -> Double {
        return Double(self.sum()) / Double(self.count)
    }

    /// Calculates the standard deviation of an array.
    /// - Returns: The standard deviation of an array's elements
    func std() -> Double {
        let mean = self.avg()
        var sum: Double = 0
        for x in self {
            sum += (Double(x) - mean) * (Double(x) - mean)
        }
        return sqrt(sum / (Double(self.count) - 1))
    }

}

extension Array {

    func repeated(count: Int) -> Array<Element> {
        assert(count > 0, "count must be greater than 0")

        var result = self
        for _ in 0 ..< count - 1 {
            result += self
        }

        return result
    }

}
