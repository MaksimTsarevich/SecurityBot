//
//  ScreenshotsCollectionDataSource.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import Foundation
import UIKit

protocol ScreenshotsCollectionDataSourceDelegate: AnyObject {
    func update(viewModels: [ScreenshotsCollectionViewCellModel])
}

class ScreenshotsCollectionDataSource: NSObject {
    
    // - UI
    private unowned var collectionView: UICollectionView
    
    // - Data
    private var viewModels: [ScreenshotsCollectionViewCellModel]
    var index = 0
    
    // - Delegate
    weak var delegate: ScreenshotsCollectionDataSourceDelegate?
    
    init(collectionView: UICollectionView, viewModels: [ScreenshotsCollectionViewCellModel], delegate: ScreenshotsCollectionDataSourceDelegate) {
        self.collectionView = collectionView
        self.viewModels = viewModels
        self.delegate = delegate
        super.init()
        configure()
    }
    
    func update(viewModels: [ScreenshotsCollectionViewCellModel]) {
        self.viewModels = viewModels
        collectionView.reloadData()
    }
    
    func update(viewModels: [ScreenshotsCollectionViewCellModel], indexPath: IndexPath, select: Bool) {
        self.viewModels = viewModels
        if let cell = collectionView.cellForItem(at: indexPath) as? ScreenshotsCollectionViewCell {
            cell.setSelectedScreenshot(isSelected: select)
        }
    }
    
    func delete(viewModels: [ScreenshotsCollectionViewCellModel]) {
        self.viewModels = viewModels
        
        var n = 0
        for viewModel in self.viewModels {
            if viewModel.isSelected {
                self.viewModels.remove(at: n)
                collectionView.cellForItem(at: IndexPath(row: n, section: 0))
            } else {
                n += 1
            }
        }
        collectionView.reloadData()
        
    }
}

// - MARK: -
// - MARK: - Collection Data Source

extension ScreenshotsCollectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotsCollectionViewCell", for: indexPath) as! ScreenshotsCollectionViewCell
        cell.setScreenCell(viewModel: viewModels[indexPath.row])
        delegate?.update(viewModels: viewModels)
        return cell
    }
    
    
}

// - MARK: -
// - MARK: - Collection Delegate

extension ScreenshotsCollectionDataSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIScreen.main.bounds.size.height < 580{
            return CGSize(width: 90, height: 200)
        } else {
            return CGSize(width: 100, height: 200)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var viewmodel = viewModels[indexPath.row]
        viewmodel.isSelected = !viewmodel.isSelected
        viewModels[indexPath.row] = viewmodel
        if let cell = collectionView.cellForItem(at: indexPath) as? ScreenshotsCollectionViewCell{
            cell.setSelectedScreenshot(isSelected: viewmodel.isSelected)
        }
        delegate?.update(viewModels: viewModels)
        index = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == viewModels.count - 1 {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        } else {
            return UIEdgeInsets(top: 0, left: 10, bottom: 100, right: 10)
        }
    }
}

// MARK: -
// MARK: - Configure

private extension ScreenshotsCollectionDataSource {
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

