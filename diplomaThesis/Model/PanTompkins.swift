//
//  PanTompkins.swift
//  diplomaThesis
//
//  Created by Apostolou Orestis on 9/3/21.
//
//  This file implements Pan-Tompkins algorithm.
//  It is a Swift implementation of the Matlab Code found on
//   https://www.mathworks.com/matlabcentral/fileexchange/45840-complete-pan-tompkins-implementation-ecg-qrs-detector
//
//  Some Matlab built-in functions are not Swift-built-in, so we had to
//  reconstruct them in C and C++ (matlab's filtfilt, which is a zero-phase
//  filter is such a function). This is the use of C and C++ files.
//
//  The advantage of this version of Pan-Tompkins is that it does not have
//  an error in the first R peaks, and that it finds exactly the spot of
//  the peak (without a constant place error).

import Foundation

/// Class for implementation of Pan Tompkins algorithm
class PanTompkins {
    var input: [CDouble], fs: Double
    init(input: [CDouble], fs: Double) {
        self.input = input
        self.fs = fs
    }
    
    /// Calculates R peaks
    /// - Returns: Array of Int with the locations of peaks, in samples
    func calculateR() -> [Int] {
        /**
        Implements Pan Tompkins algorithm
        
        Includes some C++ code, for applying zero-phase filter, and some C code
        for calculating butterworth coefficients and implementing 1-d convolution
        
        Thanks to Sedghamiz. H, for "Matlab Implementation of Pan Tompkins ECG QRS detector.", March 2014.
        https://www.researchgate.net/publication/313673153_Matlab_Implementation_of_Pan_Tompkins_ECG_QRS_detect
 */
        
        var coeffs : UnsafeMutablePointer<Double> // double array of b and a coeffs
        var aCoeffs : [CDouble] = []  // double array of a coeffs of butterworth filter
        var bCoeffs : [CDouble] = []  // double array of b coeffs of butterworth filter
        let lowFreq = CDouble(5.0 * 2 / fs) // 5 Hz, as a fraction of pi
        let highFreq = CDouble(15.0 * 2 / fs) // 15 Hz, as a fraction of pi
        var input2 = input // A trick to pass immutable var to C++ function
        
        // We implement a bandpass butterworth filter of 3rd degree, with cutoff
        // frequencies at 5 and 15 H`
        let degree = 3
        coeffs = bwbpCoeffs(Int32(degree), Int32(1), lowFreq, highFreq)
        for i in 0..<(2 * degree + 1) {
            bCoeffs.append(coeffs[i])
            aCoeffs.append(coeffs[i + 2 * degree + 1])
        }
        var outputs1 : UnsafeMutablePointer<Double>
        var outputs2 : UnsafeMutablePointer<Double>

        let n: Int32 = Int32(input.count)
        let na: Int32 = Int32(aCoeffs.count)
        let nb: Int32 = Int32(bCoeffs.count)
        
        // impplement zero-phase-filter
        
        outputs1 = filtfiltWrapper().filterfilter(&input2, n: n, aCoeffs: &aCoeffs, na: na, bCoeffs: &bCoeffs, nb: nb, normalize: Int32(1) )
        
//        for i in 0..<Int(n) {
//            print("Output")
//            print(String(format: "%f", outputs[i]))
//        }
        
        // Apply derivative filter
        // Original autoregressive filter: 1/[1, 2, 0, -2, -1]
        
        let factor1 : Double = fs / 8
        let derArray1 : [Double] = [1.0*factor1, 2.0*factor1, 0, -2*factor1, -1*factor1]
        var b1 = interpolate(inputArray:derArray1, step: Double(4.0 / (fs / 40.0)))
        let b1size = Int32(b1.count)
        var a1: [CDouble] = [1]
        outputs2 = filtfiltWrapper().filterfilter(outputs1, n: n, aCoeffs: &a1, na: 1, bCoeffs: &b1, nb: b1size, normalize: Int32(1) )
        
        //Square to get more obvious peaks
        
        for i in 0..<Int(n) {
            outputs2[i] = pow(outputs2[i], 2)
        }
        
        // convolution - moving average
        
        var ones : [CDouble] = []
        let ones1 = Int(round(fs * Double(0.15)))
        for _ in 0..<ones1 {
            ones.append(1.0 / Double(ones1))
        }
        var outputs3 : UnsafeMutablePointer<Double>
        var n2 : Int32 = Int32(0)
        outputs3 = convolve(outputs2, &ones, Int32(n), Int32(ones1), &n2)
        
        let rpeaks = findLocalMaxima(input: outputs3, n: Int(n2), minDist: Int(fs / 5.0))
        // minDist is 200 msec
        
        //initialize arrays for thresholds
        
//        var delay: Double = round(0.15 * fs) / 2
        var skip: Double = 0
        var m_selected_RR: Double = 0
        var mean_RR : Double = 0
        var ser_back : Int = 0
        
        let LLp = rpeaks.count
        var qrs_c : [Double] = []
        var qrs_i : [Int] = []
        var qrs_i_raw : [Int] = []
        var qrs_amp_raw : [Double] = []
        var nois_c : [Double] = []
        var nois_i : [Int] = []
        
        var sigl_buf : [Double] = []
        var noisl_buf : [Double] = []
        var thrs_buf : [Double] = []
        var sigl_buf1 : [Double] = []
        var noisl_buf1 : [Double] = []
        var thrs_buf1 : [Double] = []
        
        //initialize parameters for thresholds
        
        var thr_sig : Double = 0
        var thr_noise : Double = 0
        var sig_level : Double
        var noise_level : Double
        
        // We initialize threshold parameters in the first two seconds
        
        for i in 0...Int(2*fs) {
            thr_noise += outputs3[i]
            if outputs3[i] > thr_sig {
                thr_sig = outputs3[i]
            }
        }
        thr_sig /= 3.0 // thr_sig = 1/3 * max(ecg in first 2 secs)
        thr_noise /= 2.0 * Double(Int(2*fs) + 1) // thr_noise = 1/2 * mean(ecg in first 2)
        sig_level = thr_sig
        noise_level = thr_noise
        
        //initialize parameters for thresholds, bandpass filter
        
        var thr_sig1 : Double = 0
        var thr_noise1 : Double = 0
        var sig_level1 : Double
        var noise_level1 : Double
        
        // We initialize bandpass threshold parameters in the first two seconds
        
        for i in 0...Int(2*fs) {
            thr_noise1 += outputs1[i]
            if outputs1[i] > thr_sig1 {
                thr_sig1 = outputs1[i]
            }
        }
        thr_sig1 /= 3.0 // thr_sig1 = 1/3 * max(ecg in first 2 secs)
        thr_noise1 /= 2.0 * Double(Int(2*fs) + 1) // thr_noise = 1/2 * mean(ecg in first 2)
        sig_level1 = thr_sig1
        noise_level1 = thr_noise1
        
        // Thresholding and decision rule
        
        var beat_C = 0
        var beat_C1 = 0
        var noise_count = 0
        for i in 0..<LLp {
            // Locate the corresponding peak in the filtered signal
            
            var y_i : Double = 0
            var x_i : Int = 0
            
            if rpeaks[i].0 - Int(round(0.15 * fs)) >= 1 && rpeaks[i].0 <= n {
                (y_i, x_i) = maximum(input: outputs1, start: rpeaks[i].0 - Int(round(0.15 * fs)), end: rpeaks[i].0)
            } else {
                if i == 0 {
                    (y_i, x_i) = maximum(input: outputs1, start: 0, end: rpeaks[i].0)
                    ser_back = 1
                } else if rpeaks[i].0 >=  n - 1 {
                    (y_i, x_i) = maximum(input: outputs1, start: rpeaks[i].0 - Int(round(0.15 * fs)), end: Int(n2))

                }
            }
        
        
            // Update the heart rate
            
            if beat_C >= 9 {
    //            var diffRR : [Int] = []
                var tempSum1 : Int = 0
                for j in stride(from: beat_C - 9, through: beat_C - 2, by: 1) {
                    tempSum1 += (qrs_i[j+1] - qrs_i[j])
                }
//                tempSum1 -= qrs_i[beat_C - 2]
                mean_RR = Double(tempSum1) / Double(8) // mean of differences
                let comp : Int = qrs_i[beat_C - 1] - qrs_i[beat_C - 2]
                
                if Double(comp) <= 0.92*mean_RR || Double(comp) >= 1.16*mean_RR {
                    // lower down thresholds to detect better in MVI
                    thr_sig *= 0.5
                    thr_sig1 *= 0.5
                } else {
                    m_selected_RR = mean_RR // the latest regular beats mean
                }
            }
            
            // calculate the mean last 8 R waves to ensure that QRS is not nil
            
            var test_m : Double
            if m_selected_RR > 0 {
                test_m = m_selected_RR
            } else if mean_RR > 0 && m_selected_RR == 0 {
                test_m = mean_RR
            } else {
                test_m = 0.0
            }
            
            if test_m > 0 {
                if rpeaks[i].0 - qrs_i[beat_C - 1] >= Int(round(1.66 * test_m)) {
                    var pks_temp : Double
                    var locs_temp : Int
                    (pks_temp, locs_temp) = maximum(input: outputs3, start: qrs_i[beat_C - 1] + Int(round(0.2 * fs)), end: rpeaks[i].0 - Int(round(0.2 * fs)))
                    locs_temp = qrs_i[beat_C - 1] + Int(round(0.2 * fs)) + locs_temp - 1
                    
                    if pks_temp > thr_noise {
                        beat_C += 1
                        qrs_c.append(pks_temp)
                        qrs_i.append(locs_temp)
                        // locate in filtered sig
                        var y_i_t : Double
                        var x_i_t : Int
                        if locs_temp <= Int(n) - 1 {
                            (y_i_t, x_i_t) = maximum(input: outputs1, start: locs_temp - Int(round(0.15 * fs)) - 1, end: locs_temp - 1)
                        } else {
                            (y_i_t, x_i_t) = maximum(input: outputs1, start: locs_temp - Int(round(0.15 * fs)) - 1, end: Int(n) - 1)
                        }
                        // Band pass sig threshold
                        if y_i_t > thr_noise1 {
                            beat_C1 += 1
                            qrs_i_raw.append(locs_temp - Int(round(0.15 * fs)) + x_i_t)
                            qrs_amp_raw.append(y_i_t)
                            sig_level1 = 0.25 * y_i_t + 0.75 * sig_level1
                        }
                        sig_level = 0.25*pks_temp + 0.75*sig_level
                    }
                }
            }
            
            // find noise and qrs peaks
            
            if rpeaks[i].1 >= thr_sig {
                // if no qrs in 360ms of the previous qrs see if t wave
                if beat_C >= 3 {
                    if rpeaks[i].0 - qrs_i[beat_C - 1] <= Int(round(0.36 * fs)) {
                        let diff1 = diff(input: outputs3, length: Int(n2))
                        let slope1 = mean(input: diff1, start: rpeaks[i].0 - Int(round(0.075 * fs)), end: rpeaks[i].0)
                        let slope2 = mean(input: outputs3, start: qrs_i[beat_C - 1] - Int(round(0.075 * fs)), end: qrs_i[beat_C - 1])
                        if abs(slope1) <= abs(0.5 * slope2) {
                            noise_count += 1
                            nois_c.append(rpeaks[i].1)
                            nois_i.append(rpeaks[i].0)
                            skip = 1
                            // adjust noise levels
                            noise_level1 = 0.125 * y_i + 0.875 * noise_level1
                            noise_level = 0.125 * rpeaks[i].1 + 0.875 * noise_level
                        } else {
                            skip = 0
                        }
                    }
                }
                // skip is 1 when a T wave is detected
                if skip == 0 {
                    beat_C += 1
                    qrs_c.append(rpeaks[i].1)
                    qrs_i.append(rpeaks[i].0)
                
                    // bandpass filter check threshold
                    if y_i >= thr_sig1 {
                        beat_C1 += 1
                        if ser_back == 1 {
                            qrs_i_raw.append(x_i)
                        } else {
                            qrs_i_raw.append(rpeaks[i].0 - Int(round(0.15 * fs)) + x_i)
                        }
                        qrs_amp_raw.append(y_i)
                        sig_level1 = 0.125 * y_i + 0.875 * sig_level1
                    }
                    sig_level = 0.125 * rpeaks[i].1 + 0.875 * sig_level
                }
            } else if thr_noise <= rpeaks[i].1 && rpeaks[i].1 < thr_sig {
                noise_level1 = 0.125 * y_i + 0.875 * noise_level1
                noise_level = 0.125 * rpeaks[i].1 + 0.875 * noise_level
            } else if rpeaks[i].1 < thr_noise {
                noise_count += 1
                nois_c.append(rpeaks[i].1)
                nois_i.append(rpeaks[i].0)
                noise_level1 = 0.125 * y_i + 0.875 * noise_level1
                noise_level = 0.125 * rpeaks[i].1 + 0.875 * noise_level
            }
            
            // adjust the threshold with SNR
            
            if noise_level != 0 || sig_level != 0 {
                thr_sig = noise_level + 0.25 * (abs(sig_level - noise_level))
                thr_noise = 0.5 * thr_sig
            }
            
            // adjust the threshold with SNR for bandpassed signal
            
            if noise_level1 != 0 || sig_level1 != 0 {
                thr_sig1 = noise_level1 + 0.25 * (abs(sig_level1 - noise_level1))
                thr_noise1 = 0.5 * thr_sig1
            }
            
            // take a track of thresholds of smoothed signal
            sigl_buf.append(sig_level)
            noisl_buf.append(noise_level)
            thrs_buf.append(thr_sig)
           
            // take a track of thresholds of filtered signal
            sigl_buf1.append(sig_level1)
            noisl_buf1.append(noise_level1)
            thrs_buf1.append(thr_sig1)
            
            //reset parameters
            skip = 0
            ser_back = 0
            
        }
        var testOut : [(Double, Double)] = []
        for i in 0..<Int(n) {
            testOut.append((Double(input[i]), Double(i) / fs))
        }
//        self.updateCharts(ecgSamples: testOut, animated: false, peaks: qrs_i_raw)
        
        return qrs_i_raw
    }
    
    
    
}
