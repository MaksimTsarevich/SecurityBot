//
//  DuplicateContactsCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import UIKit

class DuplicateContactsCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectContactImage: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    
    var viewModels = [ContactCollectionViewCellModel]()
    
    func setupContactCell(viewModel: ContactCollectionViewCellModel) {
        nameLabel.text = "\(viewModel.name)"
        numberLabel.text = "\(viewModel.phoneNumber)"
        selectContactImage.image = UIImage(named: viewModel.isSelected ? "Active" : "notActive")
    }
    
    func setSelectedContact(isSelected: Bool) {
        selectContactImage.image = UIImage(named: isSelected ? "Active" : "notActive")
    }
    
    func selectAllContact(viewModels: [ContactCollectionViewCellModel]) {
        self.viewModels = viewModels
        for _ in 0..<viewModels.count {
            setSelectedContact(isSelected: true)
        }
    }
    
}

