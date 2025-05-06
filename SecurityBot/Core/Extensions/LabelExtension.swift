//
//  LabelExtension.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 14.12.22.
//

import Foundation
import UIKit

extension UILabel {
    
    static func spaceLabel() -> UILabel {
        let spacingLabel = UILabel()
        spacingLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        spacingLabel.textColor = .white
        spacingLabel.textAlignment = .center
        spacingLabel.font = UIFont.boldSystemFont(ofSize: 18)
        spacingLabel.text = "LIKE ME"
        spacingLabel.backgroundColor = .red
        return spacingLabel
    }
    
    // adding space between each characters
    func addCharacterSpacing(kernValue: Double) {
        if let labelText = text, labelText.isEmpty == false {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(.kern,
                                          value: kernValue,
                                          range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
