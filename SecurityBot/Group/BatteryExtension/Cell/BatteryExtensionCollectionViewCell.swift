//
//  BatteryExtensionCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 4.11.22.
//

import UIKit

class BatteryExtensionCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: -
// MARK: - Configure

extension BatteryExtensionCollectionViewCell {
    
    func set(items: BatteryExtension) {
        titleLabel.text = items.rawValue
        titleImage.image = items.icon
    }
}

