import Foundation
import UIKit


/// An animated progress bar, for indicating the progress of the analysis to the user.
class PlainHorizontalProgressBar: UIView {
    
    /// The primary bar color. Current choice is a pinky color.
    var color: UIColor = UIColor(red: 1.0, green: CGFloat(214.0/255.0), blue: CGFloat(245.0/255.0), alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }
    
    
    /// The secondary gradient color. Current choice is a pinky white.
    var gradientColor: UIColor = UIColor(red: 1.0, green: CGFloat(245.0/255.0), blue: CGFloat(253.0/255.0), alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }

    
    /// Each update causes an update to what is displayed.
    var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    private let progressLayer = CALayer()
    private let gradientLayer = CAGradientLayer()
    private let backgroundMask = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        createAnimation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        createAnimation()
    }
    
    
    /// Initialize layers.
    private func setupLayers() {
        layer.addSublayer(gradientLayer)

        gradientLayer.mask = progressLayer
        gradientLayer.locations = [0.35, 0.5, 0.65]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    }
    
    
    /// The gradient flow animation.
    private func createAnimation() {
        let flowAnimation = CABasicAnimation(keyPath: "locations")
        flowAnimation.fromValue = [-0.3, -0.15, 0]
        flowAnimation.toValue = [1, 1.15, 1.3]

        flowAnimation.isRemovedOnCompletion = false
        flowAnimation.repeatCount = Float.infinity
        flowAnimation.duration = 1

        gradientLayer.add(flowAnimation, forKey: "flowAnimation")
    }

    
    /// The fundamental function for creating a drawable element.
    /// - Parameter rect: The rect we are going to use.
    override func draw(_ rect: CGRect) {
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.25).cgPath
        layer.mask = backgroundMask

        let progressRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progress, height: rect.height))

        progressLayer.frame = progressRect
        progressLayer.backgroundColor = UIColor.systemGray.cgColor

        gradientLayer.frame = rect
        gradientLayer.colors = [color.cgColor, gradientColor.cgColor, color.cgColor]
        gradientLayer.endPoint = CGPoint(x: progress, y: 0.5)
    }
    
    
    /// This function updates the pogress bar's width.
    /// - Parameter factor: The increment we want to add, as a Float.
    func incrementProgress(_ factor: Float){
        DispatchQueue.main.async {
            self.progress += CGFloat(factor)
        }
    }
}
