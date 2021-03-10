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
    
    func calculateMetrics() {
        
    }
}
