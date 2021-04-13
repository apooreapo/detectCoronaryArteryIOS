//
//  UltraShortFeaturesStruct.swift
//  diplomaThesis
//
//  Created by User on 7/4/21.
//

import Foundation


/// Struct for having complete features of Ultra Short Analysis.
struct UltraShortFeaturesStruct {
    var SDRR: Double
    var AverageHeartRate: Double
    var SDNN: Double
    var SDSD: Double
    var pNN50: Double
    var RMSSD: Double
    var HTI: Double
    var HRMaxMin: Double
    var LFEnergy: Double
    var LFEnergyPercentage: Double
    var HFEnergy: Double
    var HFEnergyPercentage: Double
    var PoincareSD1: Double
    var PoincareSD2: Double
    var PoincareRatio: Double
    var PoincareEllipsisArea: Double
    var MeanApproximateEntropy: Double
    var StdApproximateEntropy: Double
    var MeanSampleEntropy: Double
    var StdSampleEntropy: Double
    var LFPeak: Double
    var HFPeak: Double
    var LFHFRatio: Double
    
    init(SDRR: Double, AverageHeartRate: Double, SDNN: Double, SDSD: Double, pNN50: Double,RMSSD: Double, HTI: Double, HRMaxMin: Double, LFEnergy: Double, LFEnergyPercentage: Double, HFEnergy: Double, HFEnergyPercentage: Double, PoincareSD1: Double, PoincareSD2: Double, PoincareRatio: Double, PoincareEllipsisArea: Double, MeanApproximateEntropy: Double, StdApproximateEntropy: Double, MeanSampleEntropy: Double, StdSampleEntropy: Double, LFPeak: Double, HFPeak: Double, LFHFRatio: Double) {
        self.SDRR = SDRR
        self.AverageHeartRate = AverageHeartRate
        self.SDNN = SDNN
        self.SDSD = SDSD
        self.pNN50 = pNN50
        self.RMSSD = RMSSD
        self.HTI = HTI
        self.HRMaxMin = HRMaxMin
        self.LFEnergy = LFEnergy
        self.LFEnergyPercentage = LFEnergyPercentage
        self.HFEnergy = HFEnergy
        self.HFEnergyPercentage = HFEnergyPercentage
        self.PoincareSD1 = PoincareSD1
        self.PoincareSD2 = PoincareSD2
        self.PoincareRatio = PoincareRatio
        self.PoincareEllipsisArea = PoincareEllipsisArea
        self.MeanApproximateEntropy = MeanApproximateEntropy
        self.StdApproximateEntropy = StdApproximateEntropy
        self.MeanSampleEntropy = MeanSampleEntropy
        self.StdSampleEntropy = StdSampleEntropy
        self.LFPeak = LFPeak
        self.HFPeak = HFPeak
        self.LFHFRatio = LFHFRatio
        
    }
    
    init(_ t: [Double]) {
        if t.count != K.UltraShortModel.input_names.count {
            fatalError("Input array for UltraShortFeaturesStruct must have exactly 24 features")
        } else {
            self.SDRR = t[0]
            self.AverageHeartRate = t[1]
            self.SDNN = t[2]
            self.SDSD = t[3]
            self.pNN50 = t[4]
            self.RMSSD = t[5]
            self.HTI = t[6]
            self.HRMaxMin = t[7]
            self.LFEnergy = t[8]
            self.LFEnergyPercentage = t[9]
            self.HFEnergy = t[10]
            self.HFEnergyPercentage = t[11]
            self.PoincareSD1 = t[12]
            self.PoincareSD2 = t[13]
            self.PoincareRatio = t[14]
            self.PoincareEllipsisArea = t[15]
            self.MeanApproximateEntropy = t[16]
            self.StdApproximateEntropy = t[17]
            self.MeanSampleEntropy = t[18]
            self.StdSampleEntropy = t[19]
            self.LFPeak = t[20]
            self.HFPeak = t[21]
            self.LFHFRatio = t[22]
        }
    }
    
    func toArray() -> [Double] {
        var output: [Double] = []
        output.append(SDRR)
        output.append(AverageHeartRate)
        output.append(SDNN)
        output.append(SDSD)
        output.append(pNN50)
        output.append(RMSSD)
        output.append(HTI)
        output.append(HRMaxMin)
        output.append(LFEnergy)
        output.append(LFEnergyPercentage)
        output.append(HFEnergy)
        output.append(HFEnergyPercentage)
        output.append(PoincareSD1)
        output.append(PoincareSD2)
        output.append(PoincareRatio)
        output.append(PoincareEllipsisArea)
        output.append(MeanApproximateEntropy)
        output.append(StdApproximateEntropy)
        output.append(MeanSampleEntropy)
        output.append(StdSampleEntropy)
        output.append(LFPeak)
        output.append(HFPeak)
        output.append(LFHFRatio)
        return output
    }
    
    func printValues(){
        for i in 0..<K.UltraShortModel.input_names.count {
            print(String(format: K.UltraShortModel.input_names[i] + ": %.4f", self.toArray()[i]))
        }
    }
}
