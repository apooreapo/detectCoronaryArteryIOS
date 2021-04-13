//
//  FFTAnalysis.swift
//  diplomaThesis
//
//  Created by User on 17/3/21.
//

import Foundation


/// The class for implementing FFT and calculate frequency field metrics.
class FFTAnalysis {
    var input: [CDouble]
    var fs: Double
    
    init(input: [CDouble], fs: Double) {
        self.input = input
        self.fs = fs
    }
    
    lazy var n: Int = self.input.count
    lazy var samplingInterval : Double = 1 / self.fs
    lazy var timePeriod : Double = Double(n) / self.fs
    lazy var resolution : Double = 1.0 / self.timePeriod // Frequency resolution
    
    
    // An array containing all the frequencies of the FFT.
    lazy var frequencies : [Double] = {[unowned self] in
        var output: [Double] = []
        for i in 0..<(self.n/2){
            // We only need the half frequencies, because of the symmetry
            output.append(Double(i) / self.timePeriod)
        }
        return output
    }()
    
    // An array containing the transformed Fourier values.
    lazy var fourierTransform : [Double] = {[unowned self] in
        if let maxVal = input.max(){
            for i in 0..<input.count {
                input[i] /= maxVal
            }
        } else {
            print("Important error here. No values in input matrix for FFT")
        }
        
        let output = implement_fft(Int32(n), &self.input)
        var fourier : [Double] = []
        for i in 0..<(n/2){
            fourier.append(output![i])
        }
        return fourier
    }()
    
    
    /// Calculates the energy of the Low Frequency Band (0.04 - 0.15 Hz)
    /// - Returns: The LF energy, its percentage to the full energy and the peak energy of the band in a tuple: (energy, percentage, peak).
    private func lfBand() -> (energy: Double, percentage: Double, peak: Double) {
        let lowerLimit = 0.04 * self.timePeriod
        let upperLimit = 0.15 * self.timePeriod
        var tempSum : Double = 0.0
        var fullSum : Double = 0.0
        var peakEnergy : Double = 0.0
        var peakEnergyPosition : Double = 0.0
        
//        print("Step1")
        for i in 0..<(n/2) {
            fullSum += fourierTransform[i] * fourierTransform[i]
        }
//        print("Step2")
        for i in 0..<(n/2) {
            if Double(i) > lowerLimit {
                if Double(i) <= upperLimit {
                    let temp1 = fourierTransform[i] * fourierTransform[i]
                    tempSum += temp1
                    if peakEnergy < temp1 {
                        peakEnergy = temp1
                        peakEnergyPosition = Double(i) / self.timePeriod
                    }
                } else {
                    break
                }
            }
        }
        let percentage = tempSum / fullSum
//        print(String(format: "Percentage is %.6f", percentage))
        tempSum *= self.resolution // Resolution is equivalent to dx in our computation sum
        return (tempSum, percentage, peakEnergyPosition)
    }
    
    /// Calculates the energy of the High Frequency Band (0.15 - 0.4 Hz)
    /// - Returns: The HF energy, its percentage to the full energy and the peak energy of the band in a tuple: (energy, percentage, peak).
    private func hfBand() -> (energy: Double, percentage: Double, peak: Double) {
        let lowerLimit = 0.15 * self.timePeriod
        let upperLimit = 0.401 * self.timePeriod
        var tempSum : Double = 0.0
        var fullSum : Double = 0.0
        var peakEnergy : Double = 0.0
        var peakEnergyPosition : Double = 0.0
        
        for i in 0..<(n/2) {
            fullSum += fourierTransform[i] * fourierTransform[i]
        }
        for i in 0..<(n/2) {
            if Double(i) > lowerLimit {
                if Double(i) <= upperLimit {
                    let temp1 = fourierTransform[i] * fourierTransform[i]
                    tempSum += temp1
                    if peakEnergy < temp1 {
                        peakEnergy = temp1
                        peakEnergyPosition = Double(i) / self.timePeriod
                    }
                } else {
                    break
                }
            }
        }
        let percentage = tempSum / fullSum
        print(String(format: "Percentage is %.6f", percentage))
        tempSum *= self.resolution // Resolution is equivalent to dx in our computation sum
        return (tempSum, percentage, peakEnergyPosition)
    }
    
    
    /// Calculates all frequency metrics of current FFT Analysis.
    /// - Returns: (LF Energy, LF Percentage, LF Peak, HF Energy, HF Percentage, HF Peak, LF / HF Ratio)
    internal func calculateFrequencyMetrics() -> (lfEnergy: Double, lfPercentage: Double, lfPeak: Double, hfEnergy: Double, hfPercentage: Double, hfPeak: Double, lfhf: Double) {
        let lf = self.lfBand()
        let hf = self.hfBand()
        return (lf.energy, lf.percentage, lf.peak, hf.energy, hf.percentage, hf.peak, lf.energy / hf.energy)
    }
    
    
}
