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
    var fs: Double = 0.0
    var selectedECG : [CDouble] = []
    var basicQueue = DispatchQueue(label: "m1")
    var workItem : [DispatchWorkItem] = []
    var totalTasks : Int = 22
    var completedTasks : Int = 0
    var percentage : Float = 0
    let helpingQueue = DispatchQueue(label: K.helpingQueueID, qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .never, target: .none)
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.title = "Analyzing ECGs"
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format: "Current fs is %.2f and current current ECG count is %d.", fs, selectedECG.count))
        let myPanTompkins = PanTompkins(input: selectedECG, fs: fs)
        let r_locations = myPanTompkins.calculateR()
        var myUltraShortAnalysis = UltraShortAnalysis(input: selectedECG, fs: fs, rLocs: r_locations)
        let start = Date()
        workItem.append(DispatchWorkItem(block: {
            myUltraShortAnalysis.calculateUltraShortMetrics(printMessage: true)
        }))
        
        for i in 0...10 {
            workItem.append(DispatchWorkItem(block: {
                myUltraShortAnalysis.calculateAppEn(counter: i) {
                    self.helpingQueue.sync {
                        self.percentage += self.percentage + 1.0 / Float(self.totalTasks)
                        self.completedTasks += 1
                    }
                }
            }))
        }
        for i in 0...10 {
            workItem.append(DispatchWorkItem(block: {
                myUltraShortAnalysis.calculateSampEn(counter: i) {
                    self.helpingQueue.sync {
                        self.percentage += self.percentage + 1.0 / Float(self.totalTasks)
                        self.completedTasks += 1
                    }
                }
            }))
        }
        for item in workItem {
            basicQueue.async(execute: item)
        }
        basicQueue.async(group: .none, qos: .userInitiated, flags: .barrier) {
            print("Analysis completed!")
            print(String(format: "%d/%d tasks completed", self.completedTasks, self.totalTasks))
            print("Elapsed time: \(0 - start.timeIntervalSinceNow) seconds")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Canceling all tasks...")
        for item in workItem {
            if !item.isCancelled {
                item.cancel()
            }
        }
        super.viewWillDisappear(animated)
    }
    

}
