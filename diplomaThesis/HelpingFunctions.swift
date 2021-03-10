//
//  HelpingFunctions.swift
//  diplomaThesis
//
//  Created by User on 9/3/21.
//

import Foundation

internal func interpolate(inputArray: [Double], step: Double) -> [CDouble]{
    // Make a 1-d linear interpolation on an array, with selected step
    
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

internal func findLocalMaxima(input: UnsafeMutablePointer<Double>, n: Int, minDist: Int) -> [(Int,CDouble)]{
    // A function that returns the local maxima of an input.
    // input: The input signal
    // n: The length of the signal
    // minDist: The minimum allowed distance between successive peaks in samples
    
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

internal func diff(input: [Double], length: Int) -> [Double] {
    var res : [Double] = []
    for i in 0..<length - 1 {
        res.append(input[i+1] - input[i])
    }
    // returns an array of length - 1 elements
    return res
}

internal func diff(input: UnsafeMutablePointer<Double>, length: Int) -> [Double] {
    var res : [Double] = []
    for i in 0..<length - 1 {
        res.append(input[i+1] - input[i])
    }
    // returns an array of length - 1 elements
    return res
}
