//
//  CleaningGuideCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 22.10.22.
//

import UIKit

class CleaningGuideCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: -
// MARK: - Set

extension CleaningGuideCollectionViewCell {
    
    func set(items: CleanigGuide) {
        titleLabel.text = items.rawValue
        titleImage.image = items.icon
    }
    
}
