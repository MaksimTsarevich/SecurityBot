//
//  CustomProgressView.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 12.10.22.
//

import Foundation
import UIKit

class CustomProgressView: UIView{
        
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
        gradientLayer.startPoint = CGPoint(x: 0.3, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = frame.height / 2
        gradientLayer.borderWidth = 5
        gradientLayer.borderColor = UIColor.black.cgColor
    }
        
    private func setupGradient(){
        self.layer.addSublayer(gradientLayer)
        gradientLayer.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor, UIColor(red: 1, green: 0.149, blue: 0.353, alpha: 1).cgColor]
    }
}
