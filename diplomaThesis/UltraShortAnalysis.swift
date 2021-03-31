//
//  UltraShortAnalysis.swift
//  diplomaThesis
//
//  Created by User on 10/3/21.
//

import Foundation


/// Struct for Ultra Short ECG analysis.
struct UltraShortAnalysis {
    var input: [CDouble]
    var fs: Double
    var rLocs: [Int]
    
    init(input: [CDouble], fs: Double, rLocs: [Int]) {
        self.input = input
        self.fs = fs
        self.rLocs = rLocs
    }
    
    lazy var differences: [Int] = diff(input: rLocs, length: rLocs.count)
    lazy var normalizedDifferences: [Int] = calculateNormalizedDifferences(diffs: differences)
    lazy var normDiffSize : Int = normalizedDifferences.count
    
    lazy var normInput : [Double] = {
        if let max = input.max(){
            var output : [Double] = []
            for element in input {
                output.append(element / max)
            }
            return output
        } else {
            print("Serious error here, cannot find maximum of input signal for Ultra Short Analysis.")
            return input
        }
    }()
    
    
    /// Calculates sdrr metric over an array of differences.
    /// - Returns: Standard deviation of all sinus beats in milliseconds.
    private mutating func sdrr() -> Double {
        return self.differences.std() / fs * 1000
    }
    
    
    /// Calculates sdnn metric over an array of normalized differences.
    /// - Returns: Standard deviation of all normal beats in milliseconds.
    private mutating func sdnn() -> Double {
        return normalizedDifferences.std() / fs * 1000
    }
    
    
    /// Calculates the average heart rate of an ECG in beats per minute.
    /// - Returns: Average heart rate.
    private mutating func averageHeartRate() -> Double {
        if self.differences.avg() != 0 {
            return Double(60) / (self.differences.avg() / self.fs)
        } else {
            return 0.0
        }
    }
    
    /// Calculates the percentage of adjacent NN intervals that differ from each other by more than 50 ms.
    /// - Returns: The pnn50 percentage, as a Double <= 1.
    private mutating func pnn50() -> Double {
        var counter = 0
        let margin: Double = Double(50) * self.fs / 1000
        if self.normDiffSize > 1 {
            for i in 0..<(normalizedDifferences.count - 1) {
                if Double(abs(normalizedDifferences[i] - normalizedDifferences[i+1])) > margin {
                    counter += 1
                }
            }
            return Double(counter) / Double(self.normDiffSize - 1)
        } else {
            return 0.0
        }
    }
    
    
    /// Calculates the standard deviation of normalized differences of beats in milliseconds.
    /// - Returns: The sdsd metric in msec.
    private mutating func sdsd() -> Double {
        var diff: [Int] = []
        if self.normDiffSize > 1 {
            for i in 0..<normalizedDifferences.count - 1 {
                diff.append(abs(normalizedDifferences[i] - normalizedDifferences[i+1]))
            }
            return diff.std() / self.fs * 1000
        } else {
            return 0.0
        }
    }
    
    
    /// Calculates rmssd metric, using normalized differences intervals.
    /// - Returns: The rmssd metric in msec.
    private mutating func rmssd() -> Double {
        var tempSum : Double = 0
        var normDiffSec : [Double] = []
        for diff in normalizedDifferences {
            normDiffSec.append(Double(diff) / self.fs)
        }
        let sz = normDiffSec.count
        if sz > 1 {
            for i in 0..<(sz - 1) {
                tempSum += (normDiffSec[i + 1] - normDiffSec[i])*(normDiffSec[i + 1] - normDiffSec[i])
            }
            return sqrt(tempSum / Double(sz - 1)) * Double(1000)
        } else {
            return 0.0
        }
    }
    
    
    /// Calculates the difference between minimum and maximum heartbeat.
    /// - Returns: Returns the difference in beats per minute.
    private mutating func hrMaxMin() -> Double {
        var minDiff : Int = 1000000 // Just a really high value
        var maxDiff : Int = 0
        if normDiffSize > 1 {
            for i in 0..<normDiffSize {
                if self.normalizedDifferences[i] > maxDiff {
                    maxDiff = self.normalizedDifferences[i]
                }
                if self.normalizedDifferences[i] < minDiff {
                    minDiff = self.normalizedDifferences[i]
                }
            }
            let maxTemp = Double(60) / (Double(maxDiff) / self.fs)
            let minTemp = Double(60) / (Double(minDiff) / self.fs)
            return minTemp - maxTemp
        } else {
            return 0.0
        }
    }
    
    
    
    /// Calculates and returns heart rate variability triangular index.
    /// - Returns: HTI index.
    private mutating func hti() -> Double {
        
        /**
         We separate the ECG in 8 msec parts, and create the following histogram of nn
         duration (in 8 msec pieces). HTI is equal to the height of the max histogram bar,
         divided by the count of intervals (i.e. beats).
         */
        
        
        /// Creates a histogram of values appearing in seq array.
        /// - Parameters:
        ///   - seq: The input array, from which the histogram will be constructed.
        ///   - st: The step. All elements of the input array are divided by this step.
        /// - Returns: An array of tuples representing the histogram. First element is the value, and second is the appearances.
        func countElements(seq: [Int], st: Int) -> [(Int, Int)] {
            var histo : [(Int, Int)] = []
            for diff in seq {
                let ind = Int(diff / st)
                if histo.count > 0 {
                    var found = false
                    for j in 0..<histo.count {
                        if ind == histo[j].0 {
                            histo[j].1 += 1
                            found = true
                            break
                        }
                    }
                    if !found {
                        histo.append((ind, 1))
                    }
                } else {
                    histo.append((ind, 1))
                }
            }
            return histo
        }
        
        
        var step: Int
        if self.fs <= 125 {
            step = 1
        } else {
            step = Int(Double(8) / (Double(1000) / self.fs) )
        }
        let hist = countElements(seq: self.normalizedDifferences, st: step)
        var tempMax: Int = 0
        for val in hist {
            if val.1 > tempMax {
                tempMax = val.1
            }
        }
        return Double(tempMax) / Double(self.normDiffSize)
    }
    
    
    /// Calculates the Poincare metrics..
    /// - Returns: A tuple with all four Poincare metrics.
    private mutating func poincare() -> (sd1: Double, sd2: Double, ratio: Double, area: Double){
        var nn : [Double] = []
        for i in 0..<normDiffSize {
            nn.append(Double(normalizedDifferences[i]) / self.fs)
        }
        var x1 = nn
        var x2 = nn
        x1.removeLast()
        x2.removeFirst()
        let subtracted = subtract(input1: x1, input2: x2)
        let added = add(input1: x1, input2: x2)
        let sd1 = subtracted.std() / sqrt(2)
        let sd2 = added.std() / sqrt(2)
        var ratio: Double
        if sd1 > 0 {
            ratio = sd2 / sd1
        } else {
            ratio = 0
        }
        let area = Double.pi * sd1 * sd2
        return (sd1: sd1, sd2: sd2, ratio: ratio, area: area)
        
    }
    
    
    /// Calculates Approximate Entropy on an array of Doubles
    /// - Parameters:
    ///   - data: Input array. Ideally, its size must not be larger than 64 * 5 because it is O(n^2)
    ///   - m: M parameter in algorithm, must be integer.
    ///   - r: R parameter, must be positive.
    /// - Returns: AppEn metric.
    private mutating func approximateEntropy(data: [Double], m: Int, r: Double) -> Double {
        
        /// Implemets the distance used for this algorithm. It is the max between the distances of all dimensions.
        /// - Parameters:
        ///   - vector1: First vector of Doubles.
        ///   - vector2: Second vector of Doubles.
        /// - Returns: The distance between the two inputs.
        func dist(_ vector1: [Double], _ vector2: [Double]) -> Double {
            let length = vector1.count
            if vector2.count == length {
                var max : Double = 0
                for i in 0..<length {
                    let k1 = abs(vector1[i] - vector2[i])
                    if k1 > max {
                        max = k1
                    }
                }
                return max
            } else {
                print("Error! 2 vectors must have the same length.")
                return 0.0
            }
        }
        
        
        /// Returns the Phi value of the algorithm.
        /// - Parameters:
        ///   - data: Data to be checked. Array of Doubles.
        ///   - m: M value of the algorithm.
        ///   - r: R value of the algorithm.
        /// - Returns: The Phi value for the used M.
        func phi(data: [Double], m: Int, r: Double) -> Double {
            var xArray : [[Double]] = []
            var output : [[Int]] = []
            let N = data.count
            let sz = N - m + 1
            for _ in 0..<sz {
                output.append(Array<Int>(repeating: 0, count: N - m + 1))
            }
            for i in 0..<sz {
                xArray.append(Array<Double>(data[i..<(i + m)]))
            }
            for i in 0..<sz {
                for j in 0..<sz {
                    if i < j {
                        if dist(xArray[i], xArray[j]) <= r {
                            output[i][j] = 1
                        }
                    } else if i > j {
                        output[i][j] = output[j][i]
    //                    output[i][j] = 0
                    } else {
                        output[i][j] = 1
                    }
                }
            }
            var C = Array<Int>(repeating: 0, count: sz)
            for i in 0..<sz {
                for j in 0..<sz {
                    C[i] += output[i][j]
                }
            }
            var sum : Double = 0.0
            for i in 0..<sz {
                sum += log(Double(C[i]) / Double(sz))
            }
            sum /= Double(sz)
            return sum
        }
        let n1 = phi(data: data, m: m + 1, r: r)
        let n2 = phi(data: data, m: m, r: r)
        
//        return abs(phi(data: data, m: m + 1, r: r) - phi(data: data, m: m + 1, r: r))
        return abs(n1 - n2)
        
        
    }
    
    /// Calculates Sample Entropy on an array of Doubles
    /// - Parameters:
    ///   - data: Input array. Ideally, its size must not be larger than 64 * 5 because it is O(n^2)
    ///   - m: M parameter in algorithm, must be integer.
    ///   - r: R parameter, must be positive.
    /// - Returns: SampEn metric.
    private mutating func sampleEntropy(data: [Double], m: Int, r: Double) -> Double {
        
        
        /// Implemets the distance used for this algorithm. It is the max between the distances of all dimensions.
        /// - Parameters:
        ///   - vector1: First vector of Doubles.
        ///   - vector2: Second vector of Doubles.
        /// - Returns: The distance between the two inputs.
        func dist(_ vector1: [Double], _ vector2: [Double]) -> Double {
            let length = vector1.count
            if vector2.count == length {
                var max : Double = 0
                for i in 0..<length {
                    let k1 = abs(vector1[i] - vector2[i])
                    if k1 > max {
                        max = k1
                    }
                }
                return max
            } else {
                print("Error! 2 vectors must have the same length.")
                return 0.0
            }
        }
        
        /// Returns the A and B values of the algorithm.
        /// - Parameters:
        ///   - data: Data to be checked. Array of Doubles.
        ///   - m: M value of the algorithm.
        ///   - r: R value of the algorithm.
        /// - Returns: The value for the used M.
        func phi(data: [Double], m: Int, r: Double) -> Int {
            var xArray : [[Double]] = []
            var output : [[Int]] = []
            let N = data.count
            let sz = N - m + 1
            for _ in 0..<sz {
                output.append(Array<Int>(repeating: 0, count: N - m + 1))
            }
            for i in 0..<sz {
                xArray.append(Array<Double>(data[i..<(i + m)]))
            }
            var resultCounter : Int = 0
            for i in 0..<sz {
                for j in (i + 1)..<sz {
                    if dist(xArray[i], xArray[j]) < r {
                        resultCounter += 1  // Add this twice
                    }
                }
            }
            return resultCounter
            
        }
        
        let A = phi(data: data, m: m + 1, r: r)
        let B = phi(data: data, m: m, r: r)
        if A == 0 || B == 0 {
            print("Sample entropy values must not be zero, error.")
            return 0
        } else {
            return -log(Double(A) / Double(B))
        }
        
    }
    
    
    
    internal mutating func getInThere() {
        let input1 = [85.0, 80.0, 89.0, 81.0, 80.0]
        let input2 = input1.repeated(count: 64)
        //print(input2)
        let startingPoint = Date()
        print("Starting analysis!")
        let ress = sampleEntropy(data: input2, m: 2, r: 3)
        print("\(startingPoint.timeIntervalSinceNow * -1) seconds elapsed")
        print(ress)
        print("Comparison of AppEn starting now!")
        var testECG : [Double] = []
        for i in 0..<Int(Double(5) * fs) {
            testECG.append(input[i])
        }
        let test1 = interpolate(input: testECG, ratio: 4)
        let test2 = interpolate(input: testECG, ratio: 8)
        print("Checking out what's going on 1")
        let res1 = sampleEntropy(data: test1, m: 2, r: 0.000004)
        print("Checking out what's going on 2")
        let res2 = sampleEntropy(data: test2, m: 2, r: 0.000004)
        print(String(format: "128 Hz result: %.3f", res1))
        print(String(format: "64 Hz result: %.3f", res2))
        
    }
    
    
    /// Calculates temporal and frequency metrics of the Ultra Short input.
    /// - Parameter printMessage: If true, prints out the results.
    internal mutating func calculateUltraShortMetrics(printMessage: Bool = false) {
        if printMessage {
            print("Starting Ultra Short Analysis...")
        }
        let SDRR = sdrr()
        let ahr = averageHeartRate()
        let SDNN = sdnn()
        let SDSD = sdsd()
        let pNN50 = pnn50()
        let RMSSD = rmssd()
        let HTI = hti()
        let HRMAXMIN = hrMaxMin()
        let myFFT = FFTAnalysis(input: input, fs: fs)
        let fftRes = myFFT.calculateFrequencyMetrics()
//        DispatchQueue.global(qos: .userInitiated).async {
//            sdrr()
//        }
        if printMessage {
            print(String(format: "SDRR: %.4f", SDRR))
            print(String(format: "Average Heart Rate: %.1f", ahr))
            print(String(format: "SDNN: %.4f", SDNN))
            print(String(format: "SDSD: %.4f", SDSD))
            print(String(format: "pNN50: %.4f", pNN50))
            print(String(format: "RMSSD: %.4f", RMSSD))
            print(String(format: "HTI: %.4f", HTI))
            print(String(format: "HRMAXMIN: %.4f", HRMAXMIN))
            print(String(format:"HF Energy: %.9f", fftRes.hfEnergy ))
            print(String(format:"LF Energy: %.9f", fftRes.lfEnergy))
            print(String(format:"HF Peak: %.9f", fftRes.hfPeak))
            print(String(format:"LF Peak: %.9f", fftRes.lfPeak))
            print(String(format: "HF Percentage: %.9f", fftRes.hfPercentage))
            print(String(format: "LF Percentage: %.9f", fftRes.lfPercentage))
            print(String(format: "LF/ HF Ratio: %.6f", fftRes.lfhf))
            
        }
        
    }
    
    /// Calculates an Approximate Entropy of the input, in a window of 5 seconds, starting from (2.5 * counter) sec.
    /// - Parameters:
    ///   - counter: startingTime = counter * 2.5, in seconds.
    ///   - completion: Optional function, for completion.
    internal mutating func calculateAppEn(counter: Int, completion: @escaping ()->Void = {}) -> Double {
        let window : Double = 5.0
        let start : Double = 2.5 * Double(counter)
        let factor = Int(round(fs / 64.0)) // Downscaled frequency is 64 Hz
        let startPoint = start * fs
        var endPoint : Double = (start + window) * fs
        if endPoint > Double(normInput.count) { // check if ending point exceeds signal limits
            endPoint = Double(normInput.count)
        }
        let currentSig = Array<Double>(normInput[Int(startPoint)..<Int(endPoint)])
        let downScaledSig = interpolate(input: currentSig, ratio: factor)
        let res = approximateEntropy(data: downScaledSig, m: 2, r: 0.04)
        print(String(format: "Approximate entropy for interval %.1f - %.1f is %.4f", start, start + window, res))
        completion()
        return res
        
    }
    
    
    /// Calculates a Sample Entropy of the input, in a window of 5 seconds, starting from (2.5 * counter) sec.
    /// - Parameters:
    ///   - counter: startingTime = counter * 2.5, in seconds.
    ///   - completion: Optional function, for completion.
    internal mutating func calculateSampEn(counter: Int, completion: @escaping ()->Void = {}) -> Double {
        let window : Double = 5.0 // window of 5 seconds
        let start : Double = 2.5 * Double(counter)
        let factor = Int(round(fs / 64.0)) // Downscaled frequency is 64 Hz
        let startPoint = start * fs
        var endPoint : Double = (start + window) * fs
        if endPoint > Double(normInput.count) { // check if ending point exceeds signal limits
            endPoint = Double(normInput.count)
        }
        let currentSig = Array<Double>(normInput[Int(startPoint)..<Int(endPoint)])
        let downScaledSig = interpolate(input: currentSig, ratio: factor)
        let res = sampleEntropy(data: downScaledSig, m: 2, r: 0.04)
        print(String(format: "Sample entropy for interval %.1f - %.1f is %.4f", start, start + window, res))
        completion()
        return res
        
    }
    
    
    

    
    
    
    
//    internal mutating func calculateMetrics() {
//
//    }
    
    
    /// Calculates the normalized differences of an ECG.
    /// - Parameter diffs: Array of Ints, representing raw differences of ECG in samples.
    /// - Returns: Array of Ints, representing the filtered differences in samples, only including the normalized ones.
    private func calculateNormalizedDifferences(diffs: [Int]) -> [Int] {
        var normalizedDiffs : [Int] = []
        let compQueue = Queue(size: 4, data: [])
        var count = 0
        var movingMeanDiff : Double
        while compQueue.data.count < 4 && count + 7 < diffs.count {
            movingMeanDiff = mean(input: diffs, start: count, end: count + 6)
            if 0.75 * movingMeanDiff <= Double(diffs[count]) && Double(diffs[count]) <= 1.25 * movingMeanDiff {
                compQueue.insertElement(element: diffs[count])
            }
            count += 1
        }
        
        for i in 0..<diffs.count {
            if compQueue.data.count > 3 {
                movingMeanDiff = compQueue.getDataAsInt().avg()
                if 0.85 * movingMeanDiff <= Double(diffs[i]) && Double(diffs[i]) <= 1.15 * movingMeanDiff {
                    normalizedDiffs.append(diffs[i])
                    compQueue.insertElement(element: diffs[i])
                } else if 0.75 * movingMeanDiff <= Double(diffs[i]) && Double(diffs[i]) <= 1.25 * movingMeanDiff {
                    compQueue.insertElement(element: diffs[i])
                }
                
            }
        }
        return normalizedDiffs
    }
}
