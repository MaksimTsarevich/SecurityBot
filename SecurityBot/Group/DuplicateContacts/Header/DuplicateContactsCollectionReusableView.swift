//
//  DuplicateContactsCollectionReusableView.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import UIKit

class DuplicateContactsCollectionReusableView: UICollectionReusableView {
        
    // - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectAllButton: UIButton!
    
    // - Delegate
    weak var delegate: DuplicateContactsCollectionDataSourceDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setupMainCell(viewModels: ContactMainViewModel) {
        titleLabel.text = "\(viewModels.viewModels.count)" + " DUPLICATES"
        titleLabel.addCharacterSpacing(kernValue: 1.7)
    }
    
    @IBAction func selectAllButtonAction(_ sender: UIButton) {
        delegate?.setSelectAll(tag: sender.tag)
    }
    
}
