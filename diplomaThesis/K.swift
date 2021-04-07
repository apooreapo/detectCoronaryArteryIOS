//
//  K.swift
//  diplomaThesis
//
//  Created by User on 24/3/21.
//

import Foundation


/// A file including all constants in the project.
struct K {
    static let segueAnalyzeECGIdentifier : String = "analyzeECG"
    static let basicQueueID : String = "basicQueue"
    static let helpingQueueID : String = "helpingQueue"
    
    struct UltraShortModel {
        static let input_names : [String] = ["SDRR", "AverageHeartRate", "SDNN", "SDSD", "pNN50", "RMSSD", "HTI", "HRMaxMin", "LFEnergy", "LFEnergyPercentage", "HFEnergy", "HFEnergyPerentage", "PoincareSD1", "PoincareSD2", "PoincareRatio", "PoincareEllipsisArea", "MeanApproximateEntropy", "StdApproximateEntropy", "MeanSampleEntropy", "StdSampleEntropy", "LFPeak", "HFPeak", "LFHFRatio"]
        static let input_names_R_style : [String] = ["SDRR", "Average.Heart.Rate", "SDNN", "SDSD", "pNN50", "RMSSD", "HTI", "HR.max...HR.min", "LF.Energy", "LF.Energy.Percentage", "HF.Energy", "HF.Energy.Percentage", "Poincare.sd1", "Poincare.sd2", "Poincare.ratio", "Poincare.Ellipsis.Area", "Mean.Approximate.Entropy", "Standard.Deviation.of.Approximate.Entropy", "Mean.Sample.Entropy", "Standard.Deviation.of.Sample.Entropy", "LF.Peak", "HF.Peak", "LF.HF.Energy"]
        static let input_mean_values : [Double] = [335.306196, 73.770255, 39.038637, 18.742782, 0.117766, 30.326347, 0.189191, 13.107065, 0.000018, 0.015165, 0.000023, 0.025508, 21.334041, 48.174729, 2.711403, 4159.671363, 0.415497, 0.041034, 0.345755, 0.047581, 0.107722, 0.258881, 1.254386]
        static let input_std_values: [Double] = [1487.917383, 14.742424, 24.686022, 14.232484, 0.181337, 23.445275, 0.078377, 7.493964, 0.000118, 0.037817, 0.000107, 0.062863, 16.447153, 31.200352, 1.539388, 5921.777303, 0.167089, 0.036707, 0.226342, 0.047042, 0.028022, 0.074426, 2.225333]
        static let positiveResult : String = "Yes"
        static let negativeResult : String = "No"
        static let errorResult : String = "Error"
        static let CADImageName : String = "health_test-512-CAD-veggies"
        static let noCADImageName : String = "health_test-512-noCAD"
        static let noResultImageName : String = "health_test-512-question"
        static let noCADResultMessage : String = "Well done, it seems that this ECG shows no signs of Coronary Artery Disease!"
        static let CADResultMessage : String = "Hmm, it seems that this ECG shows some signs of Coronary Artery Disease. Maybe it's time for some broccoli!"
        static let noResultMessage : String = "We seem to have a problem calculating your results. Try again with another sample."
    }
}
