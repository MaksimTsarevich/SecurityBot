//
//  LoginCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 12.02.24.
//

import UIKit

class LoginCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func setup(_ model: DataModel) {
        nameLabel.text = model.Book
        authorLabel.text = model.Name
        priceLabel.text = "\(model.Price)"
    }
}
