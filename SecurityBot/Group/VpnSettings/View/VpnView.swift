//
//  VpnView.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.10.22.
//

import Foundation
import UIKit

class VpnView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        .layer.cornerRadius = 17
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
