//
//  ScreenshotsCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import UIKit

class ScreenshotsCollectionViewCell: UICollectionViewCell {
 
    // - UI
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var selectScreenImage: UIImageView!
    
    var index = 0
    
    func setScreenCell(viewModel: ScreenshotsCollectionViewCellModel) {
        contentImage.fetchImageAsset(viewModel.asset, targetSize: contentImage.bounds.size, completionHandler: nil)
        selectScreenImage.image = UIImage(named: viewModel.isSelected ? "Active" : "notActive")
    }
    
    func setSelectedScreenshot(isSelected: Bool) {
        selectScreenImage.image = UIImage(named: isSelected ? "Active" : "notActive")
    }
    
}

