//
//  HelpingFunctions.swift
//  diplomaThesis
//
//  Created by Apostolou Orestis on 9/3/21.
//
// Some mathematic functions that help us make our life easier.

import Foundation


/// Make a 1-d linear interpolation on an array, with selected step.
/// - Parameters:
///   - inputArray: Array of Doubles to be interpolated
///   - step: Step of interpolation
/// - Returns: Array of CDoubles with the new interpolated points
internal func interpolate(inputArray: [Double], step: Double) -> [CDouble]{
    
    var inputIndex: [Double] = []
    let inputArraySize = inputArray.count
    for i in stride(from: 0.0, through: Double(inputArraySize - 1), by: step){
        inputIndex.append(i)
    }
    var output : [CDouble] = []
    for ind in inputIndex {
        let fl = Int(floor(ind))
        let ce = Int(ceil(ind))
        let down = ind - floor(ind)
        if ind == Double(inputArraySize - 1){
            output.append(CDouble(inputArray.last ?? 0.0))
        } else {
            output.append(CDouble(Double(down)*(inputArray[ce] - inputArray[fl]) + inputArray[fl]))
        }
        
    }
    return output
}


/// A function that calculates the local maxima of an array of Doubles.
/// - Parameters:
///   - input: Array of Doubles to be checked, in the form of UnsafeMutablePointer<Double>
///   - n: The length of the array of Doubles
///   - minDist: The minimum allowed distance between successive peaks in samples
/// - Returns: Array of tuples. Each tuple represents a maximum, first part is the location, second is the value
internal func findLocalMaxima(input: UnsafeMutablePointer<Double>, n: Int, minDist: Int) -> [(Int,CDouble)]{
    
    var peaks : [(Int, CDouble)] = []
    if n > 2 {
        for i in 1..<(n-1) {
            if input[i] > input[i-1] && input[i] > input[i+1] {
                // We have a local maximum, now check distance
                if peaks.isEmpty {
                    peaks.append((i, input[i]))
                } else if i > minDist + peaks.last!.0 {
                    peaks.append((i, input[i]))
                } else {
                    if input[i] > peaks.last!.1 {
                        peaks.removeLast()
                        peaks.append((i, input[i]))
                    }
                }
                
            }
        }
    }
    return peaks
}


/// Calculates the maximum value of an array of Doubles.
/// - Parameters:
///   - input: Array of Doubles to be checked, in the form of UnsafeMutablePointer<Double>
///   - start: Starting value at which the maximum is applied
///   - end: Ending value at which the maximum is applied
///   - ignoreStart: If true, the location of the maximum is returned as its absolut location minus start point
/// - Returns: Tuple of two elements, first: Value of the maximum point, second: Location of the maximum point
internal func maximum(input: UnsafeMutablePointer<Double>, start: Int, end: Int, ignoreStart: Bool = true) -> (Double, Int){
    var tempMax : Double = 0.0
    var tempMaxInd : Int = 0
    for j in stride(from: start, through: end, by: 1) {
        if tempMax < input[j] {
            tempMax = input[j]
            tempMaxInd = j
        }
    }
    if ignoreStart {
        tempMaxInd -= start
    }
    if end < start {
        print("Error in maximum, end must be higher than the start")
        print(String(format: "Start: %d", start))
        print(String(format: "End: %d", end))
    }
    return (tempMax, tempMaxInd)
}

/// Calculates the maximum value of an array of Doubles.
/// - Parameters:
///   - input: Array of Doubles to be checked, in the form of array<Double>
///   - start: Starting value at which the maximum is applied
///   - end: Ending value at which the maximum is applied
///   - ignoreStart: If true, the location of the maximum is returned as its absolut location minus start point
/// - Returns: Tuple of two elements, first: Value of the maximum point, second: Location of the maximum point
internal func maximum(input: [Double], start: Int, end: Int) -> (Double, Int){
    var tempMax : Double = 0.0
    var tempMaxInd : Int = 0
    for j in stride(from: start, through: end, by: 1) {
        if tempMax < input[j] {
            tempMax = input[j]
            tempMaxInd = j
        }
    }
    if end < start {
        print("Error in maximum, end must be higher than the start")
        print(String(format: "Start: %d", start))
        print(String(format: "End: %d", end))
    }
    return (tempMax, tempMaxInd)
}


/// Calculates the mean value of an array, from start through end.
/// - Parameters:
///   - input: Array of Doubles to be checked, in the form of array<Double>
///   - start: Starting value at which the mean metric is applied
///   - end: Ending value at which the mean metric is applied
/// - Returns: Mean value as Double
internal func mean(input: [Double], start: Int, end: Int) -> Double{
    // Returns the mean of input, only including values from start through end
    var tempSum : Double = 0.0
    if end >= start {
        for j in stride(from: start, through: end, by: 1) {
            tempSum += input[j]
        }
        return tempSum / Double(end - start + 1)
    } else {
        print("Error in average, end must be higher than start.")
        print(String(format: "Start: %d", start))
        print(String(format: "End: %d", end))
        return 0.0
    }
}

/// Calculates the mean value of an array, from start through end.
/// - Parameters:
///   - input: Array of Doubles to be checked, in the form of UnsafeMutablePointer<Double>
///   - start: Starting value at which the mean metric is applied
///   - end: Ending value at which the mean metric is applied
/// - Returns: Mean value as Double
internal func mean(input: UnsafeMutablePointer<Double>, start: Int, end: Int) -> Double{
    // Returns the mean of input, only including values from start through end
    var tempSum : Double = 0.0
    if end >= start {
        for j in stride(from: start, through: end, by: 1) {
            tempSum += input[j]
        }
        return tempSum / Double(end - start + 1)
    } else {
        print("Error in average, end must be higher than start.")
        print(String(format: "Start: %d", start))
        print(String(format: "End: %d", end))
        return 0.0
    }
}

/// Calculates the mean value of an array, from start through end.
/// - Parameters:
///   - input: Array of Ints to be checked, in the form of array<Double>
///   - start: Starting value at which the mean metric is applied
///   - end: Ending value at which the mean metric is applied
/// - Returns: Mean value as Double
internal func mean(input: [Int], start: Int, end: Int) -> Double{
    // Returns the mean of input, only including values from start through end
    var tempSum : Double = 0.0
    if end >= start {
        for j in stride(from: start, through: end, by: 1) {
            tempSum += Double(input[j])
        }
        return tempSum / Double(end - start + 1)
    } else {
        print("Error in average, end must be higher than start.")
        print(String(format: "Start: %d", start))
        print(String(format: "End: %d", end))
        return 0.0
    }
}


/// Calculates the successive differences of an array of Doubles.
/// - Parameters:
///   - input: Array of Doubles in the form of array<Double>
///   - length: Length of input
/// - Returns: Array of Doubles with the differences. Length: length - 1
internal func diff(input: [Double], length: Int) -> [Double] {
    var res : [Double] = []
    for i in 0..<length - 1 {
        res.append(input[i+1] - input[i])
    }
    // returns an array of length - 1 elements
    return res
}

/// Calculates the successive differences of an array of Doubles.
/// - Parameters:
///   - input: Array of Doubles in the form of UnsafeMutablePointer<Double>
///   - length: Length of input
/// - Returns: Array of Doubles with the differences. Length: length - 1
internal func diff(input: UnsafeMutablePointer<Double>, length: Int) -> [Double] {
    var res : [Double] = []
    for i in 0..<length - 1 {
        res.append(input[i+1] - input[i])
    }
    // returns an array of length - 1 elements
    return res
}

/// Calculates the successive differences of an array of Ints.
/// - Parameters:
///   - input: Array of Ints in the form of array<Int>
///   - length: Length of input
/// - Returns: Array of Ints with the differences. Length: length - 1
internal func diff(input: [Int], length: Int) -> [Int] {
    var res : [Int] = []
    for i in 0..<length - 1 {
        res.append(input[i+1] - input[i])
    }
    // returns an array of length - 1 elements
    return res
}


/// Simple addition of arrays of Doubles.
/// - Parameters:
///   - input1: First array of Doubles to be added.
///   - input2: Second array of Doubles to be added.
/// - Returns: Array of sum of Doubles representing the sum.
internal func add(input1: [Double], input2: [Double]) -> [Double] {
    if input1.count != input2.count {
        print("Can't add vectors of different length.")
        return []
    } else {
        var output : [Double] = []
        for i in 0..<input1.count {
            output.append(input1[i] + input2[i])
        }
        return output
    }
}

/// Simple subtraction of arrays of Doubles.
/// - Parameters:
///   - input1: First array of Doubles to be subtracted.
///   - input2: Second array of Doubles to be subtracted.
/// - Returns: Array of sum of Doubles representing the subtraction.
internal func subtract(input1: [Double], input2: [Double]) -> [Double] {
    if input1.count != input2.count {
        print("Can't add vectors of different length.")
        return []
    } else {
        var output : [Double] = []
        for i in 0..<input1.count {
            output.append(input1[i] - input2[i])
        }
        return output
    }
}


/// Calculates an array with less resolution.
/// - Parameters:
///   - input: The input array of Doubles to be interpolated.
///   - ratio: The ratio of the interpolation.
/// - Returns: Interpolated output with lower resolution by a ratio of "ratio".
internal func interpolate(input: [Double], ratio: Int) -> [Double] {
    var output : [Double] = []
    if input.count > 0 && ratio > 0 {
        for i in stride(from: 0, to: input.count, by: ratio) {
            output.append(input[i])
        }
        return output
    } else {
        return output
    }
}
