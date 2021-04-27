//
//  AnalyzeECGViewController.swift
//  diplomaThesis
//
//  Created by User on 24/3/21.
//

import Foundation
import UIKit
import CoreML
import SwiftyGif


/// The class responsible for handling and showing the ECG analysis.
class AnalyzeECGViewController : UIViewController {
    
    // The variables below are passed by the Starting ViewController.
    // However, they need an initial value (or else they would need initializing function).
    var fs: Double = 0.0
    var selectedECG : [CDouble] = []
    var basicQueue = DispatchQueue(label: "m1")
    var workItem : [DispatchWorkItem] = []
    var totalTasks : Int = 22
    let helpingQueue = DispatchQueue(label: K.helpingQueueID, qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .never, target: .none)
    
    
    @IBOutlet weak var loadingHeartImageView: UIImageView!
    
    // The custom progress bar we use.
    @IBOutlet weak var progressBar: PlainHorizontalProgressBar!
    
    @IBOutlet weak var loadingText: UILabel!
    
    @IBOutlet weak var resultsText: UILabel!
    
    @IBOutlet weak var resultsImageView: UIImageView!
    
    @IBOutlet weak var learnMoreButton: UIButton!
    
    
    
    // Needed in order to set the title, and to set navigation bar visible.
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.title = "Analyzing ECGs"
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let gif = try UIImage(gifName: "loading.gif")
            DispatchQueue.main.async {
                self.loadingHeartImageView.setGifImage(gif, loopCount: -1) // Will loop forever
                self.loadingHeartImageView.startAnimating()
            }
        } catch {
            print("Error showing gif")
            self.loadingHeartImageView.isHidden = true
        }
        
        print(String(format: "Current fs is %.2f and current current ECG count is %d.", fs, selectedECG.count))
        
        // Pan Tompkins algorithm for R peaks detection.
        let myPanTompkins = PanTompkins(input: selectedECG, fs: fs)
        let r_locations = myPanTompkins.calculateR()
        
        // Check if the recording is of high quality or not
        if isRecordingQualityGood(rPeaks: r_locations) {
            print("GOOD QUALITY")
            
            // Starting Ultra Short Analysis.
            var myUltraShortAnalysis = UltraShortAnalysis(input: selectedECG, fs: fs, rLocs: r_locations)
            let start = Date() // Count elapsed time
            var fast = UltraShortFeaturesStruct(SDRR: 0, AverageHeartRate: 0, SDNN: 0, SDSD: 0, pNN50: 0, RMSSD: 0, HTI: 0, HRMaxMin: 0, LFEnergy: 0, LFEnergyPercentage: 0, HFEnergy: 0, HFEnergyPercentage: 0, PoincareSD1: 0, PoincareSD2: 0, PoincareRatio: 0, PoincareEllipsisArea: 0, MeanApproximateEntropy: 0, StdApproximateEntropy: 0, MeanSampleEntropy: 0, StdSampleEntropy: 0, LFPeak: 0, HFPeak: 0, LFHFRatio: 0)
            
            // workItem is a DispatchWorkItem. We use this, so that we can
            // cancel the jobs remaining if user cancels analysis.
            workItem.append(DispatchWorkItem(block: {
                fast = myUltraShortAnalysis.calculateUltraShortMetrics(printMessage: true)
            }))
            
            // Upon calculation, we increment the progress bar. Sample Entropy
            // and Approximate Entropy are the most time consuming tasks in
            // the whole analysis, because they are O(N^2).
            var sampEn = Array<Double>(repeating: 0.0, count: 11)
            var appEn = Array<Double>(repeating: 0.0, count: 11)
            for i in 0...10 {
                workItem.append(DispatchWorkItem(block: {
                    appEn[i] = myUltraShortAnalysis.calculateAppEn(counter: i) {
                        DispatchQueue.main.sync {
                            self.progressBar.incrementProgress(1.0 / Float(self.totalTasks))
                        }
                    }
                }))
            }
            for i in 0...10 {
                workItem.append(DispatchWorkItem(block: {
                    sampEn[i] = myUltraShortAnalysis.calculateSampEn(counter: i) {
                        DispatchQueue.main.sync {
                            self.progressBar.incrementProgress(1.0 / Float(self.totalTasks))
                        }
                    }
                }))
            }
            
            // Execute each one of the jobs describe above, asynchronously.
            for item in workItem {
                basicQueue.async(execute: item)
            }
            
            // The operation below has a barrier, meaning that it will only start
            // when all the other operations started before this one have been
            // completed.
            basicQueue.async(group: .none, qos: .userInitiated, flags: .barrier) {
                print("Analysis completed!")
                print("Elapsed time: \(0 - start.timeIntervalSinceNow) seconds")
                print(String(format: "Mean approximate entropy: %.4f", appEn.avg()))
                print(String(format: "Mean sample entropy: %.4f", sampEn.avg()))
                print(String(format: "Std of approximate entropy: %.4f", appEn.std()))
                print(String(format: "Std of sample entropy: %.4f", sampEn.std()))
                let inputFeatures = UltraShortFeaturesStruct(SDRR: fast.SDRR, AverageHeartRate: fast.AverageHeartRate, SDNN: fast.SDNN, SDSD: fast.SDSD, pNN50: fast.pNN50, RMSSD: fast.RMSSD, HTI: fast.HTI, HRMaxMin: fast.HRMaxMin, LFEnergy: fast.LFEnergy, LFEnergyPercentage: fast.LFEnergyPercentage, HFEnergy: fast.HFEnergy, HFEnergyPercentage: fast.HFEnergyPercentage, PoincareSD1: fast.PoincareSD1, PoincareSD2: fast.PoincareSD2, PoincareRatio: fast.PoincareRatio, PoincareEllipsisArea: fast.PoincareEllipsisArea, MeanApproximateEntropy: appEn.avg(), StdApproximateEntropy: appEn.std(), MeanSampleEntropy: sampEn.avg(), StdSampleEntropy: sampEn.std(), LFPeak: fast.LFPeak, HFPeak: fast.HFPeak, LFHFRatio: fast.LFHFRatio)
                print("Presenting the features as they are at the start:")
                inputFeatures.printValues()
                print("Adding to record...")
                globalTestData.append(inputFeatures.toArray())
                if globalTestData.count == 38 {
                    self.createCSVX(from: globalTestData, output: "orestis_data.csv")
                }
                print("Calculating result...")
                let finalResult = self.analyzeUltraShortECGSVM(inputArray: inputFeatures.toArray())
                print("Do I have CAD? : " + finalResult)
                
                DispatchQueue.main.async(group: .none, qos: .userInitiated, flags: .barrier, execute: {
                    self.resultsText.numberOfLines = 0
                    if finalResult == "Yes" {
                        self.resultsImageView.image = UIImage(named: K.UltraShortModel.CADImageName)
                        self.resultsText.text = K.UltraShortModel.CADResultMessage
                    } else if finalResult == "No" {
                        self.resultsImageView.image = UIImage(named: K.UltraShortModel.noCADImageName)
                        self.resultsText.text = K.UltraShortModel.noCADResultMessage
                    } else {
                        self.resultsImageView.image = UIImage(named: K.UltraShortModel.noResultImageName)
                        self.resultsText.text = K.UltraShortModel.noResultMessage
                    }
                    self.progressBar.fadeOut()
                    self.loadingHeartImageView.fadeOut()
                    self.learnMoreButton.isEnabled = true
                    self.loadingText.fadeOut(withDuration: 1.0) {
                        self.resultsImageView.fadeIn()
                        self.resultsText.fadeIn()
                        self.learnMoreButton.fadeIn()
                        self.loadingHeartImageView.stopAnimating()
                    }
                })
            }
        } else {
            print("BAD QUALITY")
            
            // Show the error graphics
            DispatchQueue.main.async(group: .none, qos: .userInitiated, flags: .barrier, execute: {
                self.resultsText.numberOfLines = 0
                self.resultsImageView.image = UIImage(named: K.UltraShortModel.noResultImageName)
                self.resultsText.text = K.UltraShortModel.badQualityMessage
                self.progressBar.fadeOut()
                self.loadingHeartImageView.fadeOut()
//                self.learnMoreButton.isEnabled = true
                self.loadingText.fadeOut(withDuration: 1.0) {
                    self.resultsImageView.fadeIn()
                    self.resultsText.fadeIn()
//                    self.learnMoreButton.fadeIn()
                    self.loadingHeartImageView.stopAnimating()
                }
            })
        }
        
        
    }
    
    // In case the user cancels the analysis, we want the processes that are left to be terminated, or canceled.
    override func viewWillDisappear(_ animated: Bool) {
        print("Canceling all running tasks and exiting...")
        for item in workItem {
            if !item.isCancelled {
                item.cancel()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    
    /// Applies PCA and machine learning algorithm.
    /// - Parameter inputArray: Array including extracted features.
    /// - Returns: Answer to question "Do I have CAD?". Possible answers: "Yes", "No", or anything else means error.
    func analyzeUltraShortECGSVM(inputArray: [Double]) -> String {
        //        let ultraShortAnalysis = UltraShortHRV(configuration)
        if inputArray.count != K.UltraShortModel.input_mean_values.count {
            // Check if input has right length of data
            print(String(format: "Error. The input array for Ultra Short Data Analysis SVM model must have exactly %d arguments. Instead it has %d.", K.UltraShortModel.input_mean_values.count, inputArray.count))
            return K.UltraShortModel.errorResult
        } else {
            // Normalize the data by subtracting mean value and dividing by std value
            var normalizedInput : [Double] = []
            for i in 0..<inputArray.count {
                normalizedInput.append((inputArray[i] - K.UltraShortModel.input_mean_values[i]) / K.UltraShortModel.input_std_values[i])
            }
            let normalizedFeatures = UltraShortFeaturesStruct(normalizedInput)
            print("Presenting normalized values:")
            normalizedFeatures.printValues()
            // Apply PCA:
            let pcaInput = applyPCA(inputArray: normalizedInput, pcaFactors: K.UltraShortModel.PCAComponents)
            if pcaInput.count == 12 {
                if let ultraShortAnalysis = try? UltraShortHRV_PCA(configuration: .init()){
                    let input = UltraShortHRV_PCAInput(PC1: pcaInput[0], PC2: pcaInput[1], PC3: pcaInput[2], PC4: pcaInput[3], PC5: pcaInput[4], PC6: pcaInput[5], PC7: pcaInput[6], PC8: pcaInput[7], PC9: pcaInput[8], PC10: pcaInput[9], PC11: pcaInput[10], PC12: pcaInput[11])
                    if let output = try? ultraShortAnalysis.prediction(input: input){
                        return output.HasCAD} else {
                            print("The SVM model failed to make a prediction. Exiting now...")
                            return K.UltraShortModel.errorResult
                        }
                }
                else {
                    print("Cannot load model")
                    return K.UltraShortModel.errorResult
                }
            } else {
                print("Error, the PCA dimensions weren't right.")
                return K.UltraShortModel.errorResult
            }
            
        }
        
    }
    
    func applyPCA(inputArray: [Double], pcaFactors: [[Double]]) -> [Double] {
        var output : [Double] = []
        for pcai in pcaFactors {
            if pcai.count != inputArray.count {
                print("Error in PCA analysis. Returning an empty array...")
                break
            } else {
                var tempSum: Double = 0.0
                for i in 0..<pcai.count {
                    tempSum += inputArray[i] * pcai[i]
                }
                output.append(tempSum)
            }
        }
        return output
    }
    
    func createCSVX(from recArray:[[Double]], output: String) {
        
        var strings : [String] = []
        var csvString : String = ""
        
        for item in K.UltraShortModel.input_names_R_style {
            csvString.append(item + ",")
        }
        csvString.removeLast()
        csvString.append("\n")
        
        for dataRecord in recArray {
            for dataValue in dataRecord {
                csvString.append(String(format: "%f,", dataValue))
            }
            csvString.removeLast()
            csvString.append("\n")
        }
        
        //            for i in 0..<recArray.count {
        //                strings.append(String(format: "%f", recArray[i]))
        //            }
        //        let csvString = strings.joined(separator: ",\n")
        
        
        let fileManager = FileManager.default
        
        do {
            
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil , create: false )
            
            let fileURL = path.appendingPathComponent(output)
            
            try csvString.write(to: fileURL, atomically: true , encoding: .utf8)
            
            print("Done writing .csv file!")
        } catch {
            
            print("error creating file")
            
        }
        
        
    }
    
    
    /// A function that checks if the quality of the recording is good or not. Uses deep learning.
    /// - Parameter rPeaks: The locations of the R peaks.
    func isRecordingQualityGood(rPeaks: [Int]) -> Bool {
        if rPeaks.count > 1 {
            var qualityResults : [Float] = []
            let threshold : Float = 0.0430497 // this is (mean + 2.5 * std)
            for i in 0..<rPeaks.count - 1 {
                let rInterval = Array<Double>(selectedECG[rPeaks[i]..<rPeaks[i + 1]])
                var interpolated = interpolate(inputArray: rInterval, step: Double(rInterval.count) / 140.0)
                if interpolated.count == 140 + 1 {
                    // Very rare occasion, caused by interpolation error in calculation
                    interpolated.removeLast()
                }
                if interpolated.count == 140 - 1 {
                    // Very rare occasion as well, caused by interpolation error in calculation
                    interpolated.append(rInterval.last!)
                }
                if interpolated.count != 140 {
                    print("Error, the length of the input array must be 140.")
                    qualityResults.append(100.0)
                } else {
                    let minValue = interpolated.min()!
                    let maxValue = interpolated.max()!
                    
                    // Normalize between 0 and 1
                    for i in 0..<interpolated.count {
                        interpolated[i] = (interpolated[i] - minValue) / (maxValue - minValue)
                    }
                    
                    // Apply machine learning algorithm
                    if let rrAnalysis = try? checkRRfinal(configuration: .init()){
                        if let mlMultiArray = try? MLMultiArray(shape:[1,140], dataType:MLMultiArrayDataType.float32){
                            for (index, element) in interpolated.enumerated() {
                                mlMultiArray[index] = NSNumber(floatLiteral: element)
                            }
                            let input = checkRRfinalInput(x: mlMultiArray)
                            if let output = try? rrAnalysis.prediction(input: input){
                                let res = output.Identity
                                var outputArray : [Float32] = []
                                for j in 0..<res.count {
                                    outputArray.append(Float32(truncating: res[j]))
                                }
                                qualityResults.append(calculateMAE(input1: outputArray, input2: interpolated.asArrayOfFloat))
                            }
                            else {
                                print("The SVM model failed to make a prediction. Exiting now...")
                                qualityResults.append(100.0)
                            }
                        }
                        else {
                            qualityResults.append(100.0)
                        }
                        
                    }
                    else {
                        print("Cannot load model")
                        qualityResults.append(100.0)
                    }
                }
            }
            print(qualityResults)
            var badQuality = 0
            for i in 0..<qualityResults.count {
                if qualityResults[i] > threshold {
                    badQuality += 1
                }
            }
            print(Float(badQuality) / Float(rPeaks.count - 1))
            if Float(badQuality) / Float(rPeaks.count - 1) > 0.5 {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func calculateMAE(input1: [Float], input2: [Float]) -> Float {
        var output: [Float] = []
        if input1.count != 140 || input2.count != 140 {
            print("Error here, each vector must have length equal to 140.")
            return 101.0
        } else {
            for i in 0..<input1.count {
                output.append(abs(input1[i] - input2[i]))
            }
            return output.avg()
        }
    }
    
    
    /// Action performed when user clicks "Learn More" button.
    /// - Parameter sender: The sender of the click. Here it has no use.
    @IBAction func learnMoreButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.segueLoadMore, sender: self)
    }
    
    
    
    
    
}
