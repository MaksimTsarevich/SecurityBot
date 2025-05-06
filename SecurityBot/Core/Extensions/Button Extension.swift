//
//  Button Extension.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 14.12.22.
//

import Foundation
import UIKit

extension UIButton{
   func addTextSpacing(spacing: CGFloat){
       let attributedString = NSMutableAttributedString(string: (self.titleLabel?.text!)!)
       attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSRange(location: 0, length: attributedString.length - 1))
       self.setAttributedTitle(attributedString, for: .normal)
   }
}
