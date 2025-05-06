//
//  BatteryExtensionCollectionDataSource.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 4.11.22.
//

import UIKit

class BatteryExtensionCollectionDataSource: NSObject {
    
    // - Delegate
    weak var delegate: BatteryExtensionViewControllerDelegate?
    
    // - Data
    private unowned var collectionView: UICollectionView
    
    init(collectionView: UICollectionView, delegate: BatteryExtensionViewControllerDelegate) {
        self.delegate = delegate
        self.collectionView = collectionView
        super.init()
        configure()
    }
}

// MARK: -
// MARK: - Collection DataSource

extension BatteryExtensionCollectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BatteryExtension.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BatteryExtensionCollectionViewCell", for: indexPath) as! BatteryExtensionCollectionViewCell
        cell.set(items: BatteryExtension.allCases[indexPath.row])
        return cell
    }
    
    
}

// MARK: -
// MARK: - Collection Delegate

extension BatteryExtensionCollectionDataSource: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 57)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.lowPower(type: .lowPower)
        } else if indexPath.row == 1 {
            delegate?.lowPower(type: .wifi)
        } else if indexPath.row == 2 {
            delegate?.lowPower(type: .limit)
        } else if indexPath.row == 3 {
            delegate?.lowPower(type: .overheating)
        } else if indexPath.row == 4 {
            delegate?.lowPower(type: .managing)
        } else if indexPath.row == 5 {
            delegate?.lowPower(type: .location)
        } else if indexPath.row == 6 {
            delegate?.lowPower(type: .batteryUsage)
        } else if indexPath.row == 7 {
            delegate?.lowPower(type: .backgroundRefresh)
        } else if indexPath.row == 8 {
            delegate?.lowPower(type: .brightness)
        }
    }
}

// MARK: -
// MARK: - Configure

private extension BatteryExtensionCollectionDataSource {
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}
