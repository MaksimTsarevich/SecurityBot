//
//  CircleProgressCustomView.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 7.10.22.
//

import Foundation
import UIKit

@objc @IBDesignable open class CircleProgressCustomView: UIView {

    fileprivate struct Constants {
        let circleDegress = 360.0
        let minimumValue = 0.000001
        let maximumValue = 0.999999
        let ninetyDegrees = 90.0
        let twoSeventyDegrees = 270.0
        var contentView:UIView = UIView()
        
        let shadow = UIColor.white
        let shadowOffset = CGSizeMake(3.1, 3.1)
        let shadowBlurRadius: CGFloat = 5
    }

    fileprivate let constants = Constants()
    fileprivate var internalProgress:Double = 0.0

    //fileprivate
    weak var displayLink: CADisplayLink?
    
    fileprivate var destinationProgress: Double = 0.0

    @IBInspectable open var progress: Double = 0.000001 {
        didSet {
            internalProgress = progress
            setNeedsDisplay()
        }
    }

    @IBInspectable open var refreshRate: Double = 0.0 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var roundedCap: Bool = true {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable open var clockwise: Bool = true {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var trackWidth: CGFloat = 10 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var trackImage: UIImage? {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var trackBackgroundColor: UIColor = UIColor.gray {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var trackFillColor: UIColor = UIColor.blue {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var trackBorderColor:UIColor = UIColor.clear {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var trackBorderWidth: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var centerFillColor: UIColor = UIColor.white {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var centerImage: UIImage? {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var contentView: UIView {
        return self.constants.contentView
    }
    

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
        self.addSubview(contentView)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
        self.addSubview(contentView)
    }

    @objc func internalInit() {
        let displayLink = CADisplayLink(target: self, selector: #selector(CircleProgressCustomView.displayLinkTick))
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.isPaused = true
        self.displayLink = displayLink
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)

        let innerRect = rect.insetBy(dx: trackBorderWidth, dy: trackBorderWidth)

        internalProgress = (internalProgress/1.0) == 0.0 ? constants.minimumValue : progress
        internalProgress = (internalProgress/1.0) == 1.0 ? constants.maximumValue : internalProgress
        internalProgress = clockwise ?
                                (-constants.twoSeventyDegrees + ((1.0 - internalProgress) * constants.circleDegress)) :
                                (constants.ninetyDegrees - ((1.0 - internalProgress) * constants.circleDegress))

        let context = UIGraphicsGetCurrentContext()
        // background Drawing
        
        let circlePath = UIBezierPath(ovalIn: CGRect(x: innerRect.minX, y: innerRect.minY, width: innerRect.width, height: innerRect.height))
        if trackBackgroundColor != UIColor.clear {
            trackBackgroundColor.setFill()
            circlePath.fill();
        }
        if trackBorderWidth > 0 {
            circlePath.lineWidth = trackBorderWidth
            trackBorderColor.setStroke()
            circlePath.stroke()
        }
        
        
        // progress Drawing
        let progressPath = UIBezierPath()
        let progressRect: CGRect = CGRect(x: innerRect.minX, y: innerRect.minY, width: innerRect.width, height: innerRect.height)
        let center = CGPoint(x: progressRect.midX, y: progressRect.midY)
        let radius = progressRect.width / 2.0
        
        let startAngle:CGFloat = clockwise ? CGFloat(-internalProgress * Double.pi / 180.0) : CGFloat(constants.twoSeventyDegrees * Double.pi / 180)
        let endAngle:CGFloat = clockwise ? CGFloat(constants.twoSeventyDegrees * Double.pi / 180) : CGFloat(-internalProgress * Double.pi / 180.0)
        
        progressPath.addArc(withCenter: center, radius:radius, startAngle:startAngle, endAngle:endAngle, clockwise:!clockwise)
        let r = radius - trackWidth * 0.5
        if roundedCap {
            let capCenter = CGPoint(x: center.x + r * cos(endAngle), y: center.y + r * sin(endAngle))
        
            progressPath.addArc(withCenter: capCenter, radius: trackWidth * 0.5, startAngle: endAngle, endAngle: endAngle + CGFloat(Double.pi), clockwise: !clockwise)
        }
        progressPath.addArc(withCenter: center, radius:radius-trackWidth, startAngle:endAngle, endAngle:startAngle, clockwise:clockwise)
        progressPath.lineJoinStyle = .round
        
        if roundedCap {
        let capCenter = CGPoint(x: center.x + r * cos(startAngle), y: center.y + r * sin(startAngle))
        
            progressPath.addArc(withCenter: capCenter, radius: trackWidth * 0.5, startAngle: startAngle, endAngle: startAngle + CGFloat(Double.pi), clockwise: clockwise)
        }
        
        progressPath.close()
        
        context?.saveGState()

        progressPath.addClip()

        if let trackImage = trackImage {
            trackImage.draw(in: innerRect)
        } else if trackFillColor != UIColor.clear {
            trackFillColor.setFill()
            circlePath.fill()
        }
        
        

        context?.restoreGState()

        // center Drawing
        let centerPath = UIBezierPath(ovalIn: CGRect(x: innerRect.minX + trackWidth, y: innerRect.minY + trackWidth, width: innerRect.width - (2 * trackWidth), height: innerRect.height - (2 * trackWidth)))

        if centerFillColor != UIColor.clear {
            centerFillColor.setFill()
            centerPath.fill()
        }

        if let centerImage = centerImage {
            context?.saveGState()
            centerPath.addClip()
            centerImage.draw(in: rect)
            context?.restoreGState()
        } else {
            let layer = CAShapeLayer()
            layer.path = centerPath.cgPath
            contentView.layer.mask = layer
        }
    }

    //MARK: - Progress Update

    @objc open func setProgress(_ newProgress: Double, animated: Bool) {
        if animated {
            destinationProgress = newProgress
            displayLink?.isPaused = false
        } else {
            progress = newProgress
            displayLink?.isPaused = true
        }
    }

    //MARK: - CADisplayLink Tick

    @objc internal func displayLinkTick() {
        let renderTime = refreshRate.isZero ? displayLink!.duration : refreshRate
        if destinationProgress > progress {
            progress += renderTime
            if progress >= destinationProgress {
                progress = destinationProgress
            }
        }
        else if destinationProgress < progress {
            progress -= renderTime
            if progress <= destinationProgress {
                progress = destinationProgress
            }
        } else {
            displayLink?.isPaused = true
        }
    }
}

