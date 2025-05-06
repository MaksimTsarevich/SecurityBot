//
//  FooterDuplicateEventsCollectionReusableView.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import UIKit

class FooterDuplicateEventsCollectionReusableView: UICollectionReusableView {
      
    // - UI
    @IBOutlet weak var footerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
}

// MARK: -
// MARK: - Configure

private extension FooterDuplicateEventsCollectionReusableView {
    
    func configure() {
        footerView.layer.cornerRadius = 20
        footerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
}
