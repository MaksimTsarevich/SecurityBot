import Foundation
import UIKit
@IBDesignable
class CProgressDownloadView: UIView {
    
    let progressLayer = CAShapeLayer()
    let backgroundLayer = CAShapeLayer()
    
    @IBInspectable var lineWidth: CGFloat = 4.0 {
       didSet {
           backgroundLayer.lineWidth = lineWidth
           progressLayer.lineWidth = lineWidth
       }
    }
    
    @IBInspectable var animationDuration: CGFloat = 1.0 {
       didSet {
           backgroundLayer.lineWidth = lineWidth
           progressLayer.lineWidth = lineWidth
       }
    }
    @IBInspectable var trackColor: UIColor = .black.withAlphaComponent(0.25) {
       didSet {
           backgroundLayer.strokeColor = trackColor.cgColor
       }
    }
    @IBInspectable var circleColor: UIColor = .white {
       didSet {
           progressLayer.strokeColor = circleColor.cgColor
       }
    }
    @IBInspectable var progress: CGFloat = 0 {
       didSet {
           progressLayer.strokeEnd = progress
       }
    }
    
    // MARK: Life Cycle
        public init() {
            super.init(frame: .zero)
            setup()
        }

        override public init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
    
    func setup() {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: self.frame.width/2, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = trackColor.cgColor
        backgroundLayer.lineCap = CAShapeLayerLineCap.round
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.frame = CGRect(x: frame.width/2, y: -frame.height/2, width: frame.width, height: frame.height)
        layer.addSublayer(backgroundLayer)
        progressLayer.path = circularPath.cgPath
        
        progressLayer.strokeColor = circleColor.cgColor
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.frame = CGRect(x: frame.width/2, y: -frame.height/2, width: frame.width, height: frame.height)
        progressLayer.strokeEnd = 0
        backgroundLayer.transform = CATransform3DMakeRotation(-(CGFloat.pi / 2), 0, 0, 1)
        progressLayer.transform = CATransform3DMakeRotation(-(CGFloat.pi / 2), 0, 0, 1)
        
        
        // - Shadow
        progressLayer.shadowOpacity = 1
        progressLayer.shadowColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 1).cgColor
        progressLayer.shadowRadius = 10
        progressLayer.shadowOffset = CGSize(width: 0, height: 0)
        
        backgroundLayer.shadowOpacity = 0
        backgroundLayer.shadowColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 1).cgColor
        backgroundLayer.shadowRadius = 10
        backgroundLayer.shadowOffset = CGSize(width: 0, height: 0)
        layer.addSublayer(progressLayer)
    }
    
    public func setProgress(_ value: Float, animated: Bool, completion: (() -> Void)? = nil) {
        layoutIfNeeded()
        let value = CGFloat(min(value, 1.0))
        let oldValue = progressLayer.presentation()?.strokeEnd ?? progress
        progress = value
        progressLayer.strokeEnd = progress
        CATransaction.begin()
        let path = #keyPath(CAShapeLayer.strokeEnd)
        let fill = CABasicAnimation(keyPath: path)
        fill.fromValue = oldValue
        fill.toValue = value
        fill.duration = animationDuration
        CATransaction.setCompletionBlock(completion)
        progressLayer.add(fill, forKey: "fill")
        CATransaction.commit()
    }
}
