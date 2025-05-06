//
//  SettingsCollectionDataSource.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 21.10.22.
//

import Foundation
import UIKit

class SettingsCollectionDataSource: NSObject{
    
    // - Data
    private unowned var collectionView: UICollectionView
    var indexPath: IndexPath?
    
    // - Delegate
    weak var delegate: SettingsViewControllerDelegate?
    
    // - Data
    private var models: [SettingsItem]
    private let profile = UserDefaultsManager().getProfile()
    
    init(collectionView: UICollectionView, models: [SettingsItem], delegate: SettingsViewControllerDelegate) {
        self.collectionView = collectionView
        self.models = models
        self.delegate = delegate
        super.init()
        configure()
    }
}

// MARK: -
// MARK: - Collection DataSource

extension SettingsCollectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.indexPath = indexPath
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingsCollectionViewCell", for: indexPath) as! SettingsCollectionViewCell
        cell.set(items: models[indexPath.item])
        cell.delegate = delegate
        return cell
    }
    
    
}

// MARK: -
// MARK: - Collection Delegate

extension SettingsCollectionDataSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if !profile.isAdmin {
            if models[indexPath.item] == .support || models[indexPath.item] == .faceId {
                return CGSize(width: collectionView.frame.width, height: 58 + 26)
            } else {
                return CGSize(width: collectionView.frame.width, height: 58)
            }
        } else {
            if indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5 {
                return CGSize(width: collectionView.frame.width, height: 58 + 26)
            } else {
                return CGSize(width: collectionView.frame.width, height: 58)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.showGuide()
        } else if indexPath.row == 1 {
            delegate?.supportShow()
        } else if indexPath.row == 2 {
            delegate?.chatsShow()
        } else if indexPath.row == 3 {
            print("Roots")
//            delegate?.supportShow()
        } else if indexPath.row == 4 {
            delegate?.termsShow()
        } else if indexPath.row == 5 {
            delegate?.privacyShow()
        } else if indexPath.row == 6 {
            delegate?.rateUsShow()
        }
    }
}

// MARK: -
// MARK: - Configure

private extension SettingsCollectionDataSource {
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}
