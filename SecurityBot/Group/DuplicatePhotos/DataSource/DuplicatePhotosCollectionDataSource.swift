//
//  DuplicatePhotosCollectionDataSource.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 18.10.22.
//

import Foundation
import UIKit

protocol DuplicatePhotosCollectionDataSourceDelegate: AnyObject {
    func selectDuplicate(tag: Int, select: Bool)
    func selectPhoto(index: IndexPath)
    func update(viewModels: [DuplicatePhotosVerticalCellCollectionViewModel])
}

class DuplicatePhotosCollectionDataSource: NSObject{
    
    // - UI
    private unowned var collectionView: UICollectionView
    
    // - Data
    private var viewModel: [DuplicatePhotosVerticalCellCollectionViewModel]
    
    // - Delegate
    unowned var delegate: DuplicatePhotosCollectionDataSourceDelegate
    
    init(collectionView: UICollectionView, viewModel: [DuplicatePhotosVerticalCellCollectionViewModel], delegate: DuplicatePhotosCollectionDataSourceDelegate) {
        self.collectionView = collectionView
        self.viewModel = viewModel
        self.delegate = delegate
        super.init()
        configure()
    }
    
    func update(viewModel: [DuplicatePhotosVerticalCellCollectionViewModel], indexPath: IndexPath, select: Bool) {
        self.viewModel = viewModel
        if let cell = collectionView.cellForItem(at: indexPath) as? DuplicatePhotosCollectionViewCell {
            cell.selectAll(viewModels: viewModel[indexPath.row].duplicatePhotos, select: select)
        }
    }
    
    func updateSelection(viewModels: [DuplicatePhotosVerticalCellCollectionViewModel]) {
        self.viewModel = viewModels
    }
    
//    func update(viewModels: [DuplicatePhotosVerticalCellCollectionViewModel]) {
//        self.viewModel = viewModels
//        collectionView.reloadData()
//    }
    
    func delete(viewModels: [DuplicatePhotosVerticalCellCollectionViewModel]) {
        self.viewModel = viewModels
        var index = 0
        for viewModel in self.viewModel {
            let selectedViewModels = viewModel.duplicatePhotos.map({$0.isSelected}).filter({$0})
            let countViewModels = viewModel.duplicatePhotos.count
            let countSelect = selectedViewModels.count
            let diff = countViewModels - countSelect
            if diff == 0 || diff == 1 {
                self.viewModel.remove(at: index)
            } else {
                var n = 0
                for viewModel in viewModel.duplicatePhotos {
                    if viewModel.isSelected {
                        if let cell = collectionView.cellForItem(at: IndexPath(item: n, section: 0)) as? DuplicatePhotosCollectionViewCell {
                            //cell.delete(viewModels: viewModels[n].duplicatePhotos, index: n)
                        }
                        self.viewModel[index].duplicatePhotos.remove(at: n)
                    } else {
                        n += 1
                    }
                }
                index += 1
            }
            collectionView.reloadData()
        }
    }
}

// - MARK: -
// - MARK: - Collection Data Source

extension DuplicatePhotosCollectionDataSource:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DuplicatePhotosCollectionViewCell", for: indexPath) as! DuplicatePhotosCollectionViewCell
        cell.setupMainCell(viewModels: viewModel[indexPath.row], index: indexPath.row)
        cell.delegate = delegate
        return cell
    }
    
}

// - MARK: -
// - MARK: - Collection Delegate

extension DuplicatePhotosCollectionDataSource:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: 294)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(viewModel[indexPath.row].duplicatePhotos.map({$0.isSelected == true}))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == viewModel.count - 1 {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        } else {
            return UIEdgeInsets(top: 0, left: 10, bottom: 100, right: 10)
        }
    }
}

// - MARK: -
// - MARK: - Configure

private extension DuplicatePhotosCollectionDataSource {
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}
