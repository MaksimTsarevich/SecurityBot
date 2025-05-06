//
//  CustomSwitch.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 12.10.22.
//

import Foundation
import QuartzCore
import UIKit

class CSwitcherView: UIView {
    enum SwitcherState {
        case on
        case off
    }
    
    var state: SwitcherState = .off {
        didSet {
            toggleAnimation()
        }
    }
    
    private let maskLayer = CAShapeLayer()
        
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 18)
        maskLayer.frame = rect
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    private func toggleAnimation() {

    }
    
    private let bgLayer = CAShapeLayer()
            
        private lazy var onLayer: CAShapeLayer = {
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.white.cgColor
            return layer
        }()
        
        private let offLayer: CAShapeLayer = {
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.black.cgColor
            return layer
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        private func setup() {
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleHandler)))
            
            bgLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2).cgPath
            layer.insertSublayer(bgLayer, at: 0)
            
            switch state {
            case .on:
                bgLayer.fillColor = onLayer.fillColor
            case .off:
                bgLayer.fillColor = offLayer.fillColor
            }
            
            toggleAnimation()
        }
        
        func toggle() {
            state = state == .on ? .off : .on
        }
    }

    @objc private extension CSwitcherView {
        func toggleHandler() {
            toggle()
        }
        
        private var leftSwitchCenter: CGPoint {
                return CGPoint(x: bounds.height / 2, y: bounds.height / 2)
            }
            
            private var rightSwitchCenter: CGPoint {
                return CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2)
            }
            
            private var minRadius: CGFloat {
                return bounds.height / 6
            }
            
            private var maxRadius: CGFloat {
                return bounds.width
            }
            
            private var durationForAnimation: CFTimeInterval {
                return 0.3
            }
}
