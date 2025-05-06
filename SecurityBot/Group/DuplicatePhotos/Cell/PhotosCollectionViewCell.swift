//
//  PhotosCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 18.10.22.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var duplicateImage: UIImageView!
    @IBOutlet weak var activeImage: UIImageView!
    
    func setupDuplicatePhotoCell(viewModel: DuplicatePhotosHorizontalCellCollectionViewModel, isFirst: Bool) {
        activeImage.isHidden = isFirst
        duplicateImage.fetchImageAsset(viewModel.asset, targetSize: duplicateImage.bounds.size, completionHandler: nil)
        activeImage.image = UIImage(named: viewModel.isSelected ? "Active" : "notActive")
        
    }
    
    func setSelectedPhoto(isSelected: Bool) {
        activeImage.image = UIImage(named: isSelected ? "Active" : "notActive")
    }
    
    func hidden() {
        duplicateImage.isHidden = true
        activeImage.isHidden = true
    }
    
    func show() {
        duplicateImage.isHidden = false
        activeImage.isHidden = false
    }
}


