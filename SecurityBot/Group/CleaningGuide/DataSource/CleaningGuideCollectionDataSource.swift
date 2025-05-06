//
//  CleaningGuideCollectionDataSource.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 22.10.22.
//

import Foundation
import UIKit

class CleaningGuideCollectionDataSource: NSObject {
    
    // - Delegate
    weak var delegate: CleaningGuideViewControllerDelegate?
    
    // - Data
    private unowned var collectionView: UICollectionView
    
    init(collectionView: UICollectionView, delegate: CleaningGuideViewControllerDelegate) {
        self.delegate = delegate
        self.collectionView = collectionView
        super.init()
        configure()
    }
}

// MARK: -
// MARK: - Collection DataSource

extension CleaningGuideCollectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CleanigGuide.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CleaningGuideCollectionViewCell", for: indexPath) as! CleaningGuideCollectionViewCell
        cell.set(items: CleanigGuide.allCases[indexPath.row])
        return cell
    }
    
    
}

// MARK: -
// MARK: - Collection Delegate

extension CleaningGuideCollectionDataSource: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 57)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.showCleaningGuide(type: .showOffload)
        } else if indexPath.row == 1 {
            delegate?.showCleaningGuide(type: .showClearTelegram)
        } else if indexPath.row == 2 {
            delegate?.showCleaningGuide(type: .showRemoveWhatsApp)
        } else if indexPath.row == 3 {
            delegate?.showCleaningGuide(type: .showMakeViber)
        } else if indexPath.row == 4 {
            delegate?.showCleaningGuide(type: .showClearRecentlyFolder)
        } else if indexPath.row == 5 {
            delegate?.showCleaningGuide(type: .showCleanSafari)
        } else if indexPath.row == 6 {
            delegate?.showCleaningGuide(type: .showDeleteApp)
        }
    }
}

// MARK: -
// MARK: - Configure

private extension CleaningGuideCollectionDataSource {
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}
