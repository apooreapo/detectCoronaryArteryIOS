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
    var myQueue = DispatchQueue(label: "m1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format: "Current fs is %.2f and current current ECG count is %d.", fs, selectedECG.count))
        let myPanTompkins = PanTompkins(input: selectedECG, fs: fs)
        let r_locations = myPanTompkins.calculateR()
        var myUltraShortAnalysis = UltraShortAnalysis(input: selectedECG, fs: fs, rLocs: r_locations)
        let start = Date()
//        let myQueue = DispatchQueue(label: "myQueue", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .never, target: .none)
//        DispatchQueue.global(qos: .background).async {
        myQueue.async {
            myUltraShortAnalysis.calculateUltraShortMetrics(printMessage: true)
            for i in 0...10 {
                myUltraShortAnalysis.calculateAppEn(counter: i)
            }
        }
        myQueue.async(group: .none, qos: .userInitiated, flags: .barrier) {
            print("Analysis completed!")
            print("Elapsed time: \(0 - start.timeIntervalSinceNow) seconds")
        }
    }
}
