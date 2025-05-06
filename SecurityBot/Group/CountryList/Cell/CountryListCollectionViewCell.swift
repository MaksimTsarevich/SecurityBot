//
//  CountryListCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.10.22.
//

import Foundation
import UIKit
import Kingfisher

class CountryListCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var nameCountryLabel: UILabel!
    @IBOutlet weak var checkPointView: UIView!
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet weak var lockImage: UIImageView!
    
    // - Data
    var location = [LocationModel]()
    
    // - Delegate
    weak var delegate: VpnSettinsViewControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
}

// - MARK: -
// - MARK: - Configure

extension CountryListCollectionViewCell {
    func set(countries: LocationModel) {
        nameCountryLabel.text = countries.country
        guard let url = URL(string: countries.flag) else { return }
        countryImage.kf.setImage(with: url)
    }
    
    func selectItem(isSelected: Bool) {
        selectView.backgroundColor = isSelected ? UIColor(red: 0.176, green: 0.871, blue: 0.58, alpha: 1) : UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        selectImage.isHidden = isSelected ? false : true
    }
    
    func hidden() {
        lockImage.isHidden = true
    }
    
    func show() {
        lockImage.isHidden = false
    }
}

private extension CountryListCollectionViewCell {
    func configure() {
        configurePointBorder()
    }
    
    func configurePointBorder() {
        checkPointView.layer.borderWidth = 1
        checkPointView.layer.borderColor = UIColor(red: 0.035, green: 0.039, blue: 0.078, alpha: 1).cgColor
    }
    
}

