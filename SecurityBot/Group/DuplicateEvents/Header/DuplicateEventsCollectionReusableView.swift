//
//  DuplicateEventsCollectionReusableView.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import Foundation
import UIKit

class DuplicateEventsCollectionReusableView: UICollectionReusableView {
        
    // - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectAllButton: UIButton!
    
    // - Delegate
    weak var delegate: (DuplicateEventsCollectionDataSourceDelegate)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setupDate(viewModels: BigEventsCollectionViewModel, index: Int) {
        titleLabel.text = viewModels.dateEvent[index]
        titleLabel.addCharacterSpacing(kernValue: 1.7)
    }
    
    @IBAction func selectAllButtonAction(_ sender: UIButton) {
        delegate?.setSelectAllEvents(tag: sender.tag)
    }
    
}
