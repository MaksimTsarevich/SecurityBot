//
//  DuplicateContactsCollectionDataSource.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import Foundation
import UIKit

protocol DuplicateContactsCollectionDataSourceDelegate: AnyObject {
    func setSelectAll(tag: Int)
    func update(viewModels: [ContactMainViewModel])
}

class DuplicateContactsCollectionDataSource: NSObject{
    
    // - UI
    private unowned var collectionView: UICollectionView
    
    // - Delegate
    weak var delegate: (DuplicateContactsCollectionDataSourceDelegate)?
    
    // - Data
    private var viewModels: [ContactMainViewModel]
    var sectionItem = 0
    
    init(collectionView: UICollectionView, viewModels: [ContactMainViewModel], delegate: DuplicateContactsCollectionDataSourceDelegate) {
        self.collectionView = collectionView
        self.viewModels = viewModels
        self.delegate = delegate
        super.init()
        configure()
    }
    
    func update(viewModels: [ContactMainViewModel], indexPath: IndexPath) {
        self.viewModels = viewModels
        if let cell = collectionView.cellForItem(at: indexPath) as? DuplicateContactsCollectionViewCell {
            cell.selectAllContact(viewModels: viewModels[indexPath.section].viewModels)
        }
    }
    
    func delete(viewModels: [ContactMainViewModel]) {
        self.viewModels = viewModels
        var index = 0
        for viewModel in self.viewModels {
            let selectedViewModels = viewModel.viewModels.map({$0.isSelected}).filter({$0})
            let countViewModels = viewModel.viewModels.count
            let countSelect = selectedViewModels.count
            let diff = countViewModels - countSelect
            if diff == 0 || diff == 1 {
                self.viewModels.remove(at: index)
                
            } else {
                var n = 0
                for viewModel in viewModel.viewModels {
                    if viewModel.isSelected {
                        self.viewModels[index].viewModels.remove(at: n)
                    } else {
                        n += 1
                    }
                }
                index += 1
            }
            collectionView.reloadData()
        }
    }
    
    func update(viewModels: [ContactMainViewModel]) {
        self.viewModels = viewModels
        collectionView.reloadData()
    }
}

// - MARK: -
// - MARK: - Collection Data Source

extension DuplicateContactsCollectionDataSource: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels[section].viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DuplicateContactsCollectionViewCell", for: indexPath) as! DuplicateContactsCollectionViewCell
        cell.setupContactCell(viewModel: viewModels[indexPath.section].viewModels[indexPath.row])
        delegate?.update(viewModels: viewModels)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DuplicateContactsCollectionReusableView", for: indexPath) as! DuplicateContactsCollectionReusableView
            header.setupMainCell(viewModels: viewModels[indexPath.section])
            header.selectAllButton.tag = indexPath.section
            header.delegate = delegate
            delegate?.update(viewModels: viewModels)
            return header
            
            
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterCollectionReusableView", for: indexPath) as! FooterCollectionReusableView
            return footer
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
}

// - MARK: -
// - MARK: - Collection Delegate

extension DuplicateContactsCollectionDataSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        if UIScreen.main.bounds.size.height > 1000 {
            return CGSize(width: 390, height: 90)
        } else {
            return CGSize(width: width, height: 90)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var viewmodel = viewModels[indexPath.section].viewModels[indexPath.row]
        viewmodel.isSelected = !viewmodel.isSelected
        viewModels[indexPath.section].viewModels[indexPath.row] = viewmodel
        if let cell = collectionView.cellForItem(at: indexPath) as? DuplicateContactsCollectionViewCell{
            cell.setSelectedContact(isSelected: viewmodel.isSelected)
        }
        //sectionItem = indexPath.section
        delegate?.update(viewModels: viewModels)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if section == viewModels.count - 1 {
//            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//        } else {
//            return UIEdgeInsets(top: 0, left: 10, bottom: 100, right: 10)
//        }
//    }
}

// MARK: -
// MARK: - Configure

private extension DuplicateContactsCollectionDataSource {
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

