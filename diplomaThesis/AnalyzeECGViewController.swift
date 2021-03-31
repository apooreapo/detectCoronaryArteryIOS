//
//  AnalyzeECGViewController.swift
//  diplomaThesis
//
//  Created by User on 24/3/21.
//

import Foundation
import UIKit


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
    
    
    // The custom progress bar we use.
    @IBOutlet weak var progressBar: PlainHorizontalProgressBar!
    
    @IBOutlet weak var loadingText: UILabel!
    
    @IBOutlet weak var resultsText: UILabel!
    
    @IBOutlet weak var resultsImageView: UIImageView!
    
    
    // Needed in order to set the title, and to set navigation bar visible.
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.title = "Analyzing ECGs"
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format: "Current fs is %.2f and current current ECG count is %d.", fs, selectedECG.count))
        
        // Pan Tompkins algorithm for R peaks detection.
        let myPanTompkins = PanTompkins(input: selectedECG, fs: fs)
        let r_locations = myPanTompkins.calculateR()
        
        // Starting Ultra Short Analysis.
        var myUltraShortAnalysis = UltraShortAnalysis(input: selectedECG, fs: fs, rLocs: r_locations)
        let start = Date() // Count elapsed time
        
        // workItem is a DispatchWorkItem. We use this, so that we can
        // cancel the jobs remaining if user cancels analysis.
        workItem.append(DispatchWorkItem(block: {
            myUltraShortAnalysis.calculateUltraShortMetrics(printMessage: true)
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
            DispatchQueue.main.async(group: .none, qos: .userInitiated, flags: .barrier, execute: {
                self.progressBar.fadeOut()
                self.loadingText.fadeOut(withDuration: 1.0) {
                    self.resultsImageView.fadeIn()
                    self.resultsText.fadeIn()
                }
            })
        }
        
    }
    
    // In case the user cancels the analysis, we want the processes that are left to be terminated, or canceled.
    override func viewWillDisappear(_ animated: Bool) {
        print("Canceling all tasks and exiting...")
        for item in workItem {
            if !item.isCancelled {
                item.cancel()
            }
        }
        super.viewWillDisappear(animated)
    }
    

    
    

}
