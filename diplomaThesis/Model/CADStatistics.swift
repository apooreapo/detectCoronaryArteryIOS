//
//  CADStatistics.swift
//  diplomaThesis
//
//  Created by Apostolou Orestis on 11/5/21.
//
//  This struct manages all the statistics of the user. It counts how many
//  records you have, how many of them show CAD, how many of them do not
//  show CAD, what is the final ratio, and what is the final message that
//  must be shown to the user.
//
//  If a user has analyzed less than 10 samples, the result is undefined.

import Foundation
import UIKit


/// A struct for managing the statistics of the subject.
struct CADStatistics {
    var recordArr : [RecordEntity]
    
    init(recordArr : [RecordEntity]) {
        self.recordArr = recordArr
    }
    
    lazy var myFullCount : Int = {
        var count = 0
        for item in recordArr {
            if item.classificationResult == K.UltraShortModel.positiveResult || item.classificationResult == K.UltraShortModel.negativeResult {
                count += 1
            }
        }
        return count
    }()
    
    lazy var myCADCount : Int = {
        var count = 0
        for item in recordArr {
            if item.classificationResult == K.UltraShortModel.positiveResult {
                count += 1
            }
        }
        return count
    }()
    
    lazy var myRatio : Float = {
        if myFullCount > 0 {
            return Float(myCADCount) / Float(myFullCount)
        } else {
            return 0.0
        }
    }()
    
    mutating func getRatio() -> Float {
        return myRatio
    }
    
    mutating func getFullCount() -> Int {
        return myFullCount
    }
    
    mutating func getCADCount() -> Int {
        return myCADCount
    }
    
    mutating func getBackgroundColor() -> UIColor {
        if myRatio <= 0.5 {
            return UIColor(named: K.noCADColorName)!
        } else if myRatio <= 0.6 {
            return UIColor.systemBackground
        } else {
            return UIColor(named: K.CADColorName)!
        }
    }
    
    mutating func getFinalImage() -> UIImage {
        if myFullCount < 10 {
            return UIImage(named: K.finalQuestionImageName)!
        } else {
            if myRatio <= 0.5 {
                return UIImage(named: K.finalNoCADImageName)!
            } else if myRatio <= 0.6 {
                return UIImage(named: K.finalQuestionImageName)!
            } else {
                return UIImage(named: K.finalCADImageName)!
            }
        }
    }
    
    mutating func getResult() -> String {
        if myFullCount < 10 {
            return K.UltraShortModel.smallNumberResult
        } else {
            if myRatio <= 0.5 {
                return K.UltraShortModel.negativeResult
            } else if myRatio <= 0.6 {
                return K.UltraShortModel.errorResult
            } else {
                return K.UltraShortModel.positiveResult
            }
        }
    }
    
    mutating func getFinalMessage() -> String {
        if myFullCount < 10 {
            return K.finalSmallNumberMessage
        } else {
            if myRatio <= 0.5 {
                return K.finalNoCADMessage
            } else if myRatio <= 0.6 {
                return K.finalUndefinedMessage
            } else {
                return K.finalCADMessage
            }
        }
    }
}

