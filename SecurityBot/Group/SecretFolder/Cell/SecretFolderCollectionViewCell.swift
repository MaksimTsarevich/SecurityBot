//
//  SecretFolderCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 21.10.22.
//

import UIKit

class SecretFolderCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var selectedImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setUp(model: SecretImageModel) {
        photoImage.image = model.image
        
        if !model.isSelected {
            selectedImage.isHidden = false
        } else {
            selectedImage.isHidden = true
        }
        
        selectedImage.image = UIImage(named: model.isSelected ? "activePhoto" : "notActivePhoto")
    }
    
    func setSelectItem(isSelected: Bool) {
        selectedImage.image = UIImage(named: isSelected ? "activePhoto" : "notActivePhoto")
    }
}
