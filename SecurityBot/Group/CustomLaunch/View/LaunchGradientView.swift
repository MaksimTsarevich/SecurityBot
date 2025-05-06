//
//  LaunchGradientView.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 15.03.24.
//

import UIKit

class LaunchGradientView: UIView{
        
    // - Data
    var gradientLayer = CAGradientLayer()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
//        gradientLayer.cornerRadius = frame.height / 2
//        gradientLayer.borderWidth = 5
        gradientLayer.borderColor = UIColor.black.cgColor
    }
        
    private func setupGradient(){
        self.layer.addSublayer(gradientLayer)
        gradientLayer.colors = [UIColor(red: 0.882, green: 0.980, blue: 0.988, alpha: 0).cgColor, UIColor(red: 0.882, green: 0.980, blue: 0.988, alpha: 1).cgColor]
    }
}
