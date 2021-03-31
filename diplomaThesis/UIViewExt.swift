//
//  UIViewExt.swift
//  diplomaThesis
//
//  Created by User on 31/3/21.
//

import Foundation
import UIKit

extension UIView {
    
    
    /// Simple fade out for a UIView.
    /// - Parameters:
    ///   - duration: duration of effect in seconds
    ///   - completion: function that gets triggered by the completion of the effect
    func fadeOut(withDuration duration: TimeInterval = 1.0, withCompletion completion: @escaping () -> Void = {}) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut) {
            self.alpha = 0.0
        } completion: { (finished: Bool) in
            completion()
        }
    }
    
    /// Simple fade in for a UIView.
    /// - Parameters:
    ///   - duration: duration of effect in seconds
    ///   - completion: function that gets triggered by the completion of the effect
    func fadeIn(withDuration duration: TimeInterval = 1.0, withCompletion completion: @escaping () -> Void = {}) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn) {
            self.alpha = 1.0
        } completion: { (finished: Bool) in
            completion()
        }
    }
}
