//
//  ContactsCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 21.10.22.
//

import UIKit

class ContactsCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var activeImage: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUp(model: SecretContactModel) {
        contactLabel.text = model.name
        numberLabel.text = model.number
        if !model.isSelected {
            activeImage.isHidden = false
        } else {
            activeImage.isHidden = true
        }
        
        activeImage.image = UIImage(named: model.isSelected ? "activeContact" : "notActiveContact")
    }
    
    func setSelectItem(isSelected: Bool) {
        activeImage.image = UIImage(named: isSelected ? "activeContact" : "notActiveContact")
    }
}
