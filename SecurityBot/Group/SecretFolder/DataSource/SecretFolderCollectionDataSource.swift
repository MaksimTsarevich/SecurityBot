//
//  SecretFolderCollectionDataSource.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 21.10.22.
//

import Foundation
import UIKit


class SecretFolderCollectionDataSource: NSObject{
    
    // - UI
    private unowned var collectionView: UICollectionView
    
    // - Delegate
    weak var delegate: SecretFolderCollectionDataSourceDelegate?
    
    // - Data
    var type: SecretType
    var contactModels: [SecretContactModel]
    var photoModels: [SecretImageModel]
    var selectType: selectType = .select
    
    
    init(collectionView: UICollectionView, type: SecretType, contactModels: [SecretContactModel],photoModels: [SecretImageModel], delegate: SecretFolderCollectionDataSourceDelegate) {
        self.collectionView = collectionView
        self.type = type
        self.contactModels = contactModels
        self.photoModels = photoModels
        self.delegate = delegate
        super.init()
        configure()
    }
    
    func update(type: SecretType) {
        if self.type == type { return }
        self.type = type
        collectionView.reloadData()
    }
    
    func updateDataContact(models: [SecretContactModel], reloadData: Bool) {
        self.contactModels = models
        if reloadData {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                
                UIView.transition(with: strongSelf.collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    strongSelf.collectionView.reloadData()
                })
            }
        }
    }
    
    func updateDataPhoto(models: [SecretImageModel], reloadData: Bool) {
        self.photoModels = models
        if reloadData {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                
                UIView.transition(with: strongSelf.collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    strongSelf.collectionView.reloadData()
                })
            }
        }
    }
}

// MARK: -
// MARK: - Collection Data Source

extension SecretFolderCollectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch type{
        case .photo:
            return photoModels.count
        case .contact:
            return contactModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch type{
        case .photo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecretFolderCollectionViewCell", for: indexPath) as! SecretFolderCollectionViewCell
            cell.setUp(model: photoModels[indexPath.row])
            if selectType == .select {
                cell.selectedImage.isHidden = true
            }
//            cell.selectedImage.isHidden = globalBool
            return cell
        case .contact:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactsCollectionViewCell", for: indexPath) as! ContactsCollectionViewCell
            cell.setUp(model: contactModels[indexPath.row])
            if selectType == .select {
                cell.activeImage.isHidden = true
            }
            //            cell.selectedImage.isHidden = globalBool
            return cell
        }
    }
}

// MARK: -
// MARK: - Collection Delegate

extension SecretFolderCollectionDataSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch type{
        case .photo:
            if UIScreen.main.bounds.size.height < 580 {
                return CGSize(width: 130, height: 150)
            } else {
                return CGSize(width: 100, height: 120)
            }
        case .contact:
            return CGSize(width: collectionView.frame.width, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch type {
        case .photo:
            var model = photoModels[indexPath.row]
            model.isSelected = !model.isSelected
            photoModels[indexPath.row] = model
            if let cell = collectionView.cellForItem(at: indexPath) as? SecretFolderCollectionViewCell {
                cell.setSelectItem(isSelected: model.isSelected)
            }
            delegate?.updateImage(models: photoModels)
        case .contact:
            var model = contactModels[indexPath.row]
            model.isSelected = !model.isSelected
            contactModels[indexPath.row] = model
            if let cell = collectionView.cellForItem(at: indexPath) as? ContactsCollectionViewCell{
                cell.setSelectItem(isSelected: model.isSelected)
            }
            delegate?.updateContact(models: contactModels)
        }
        
    }
}

// MARK: -
// MARK: - Configure

private extension SecretFolderCollectionDataSource {
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

enum SecretType {
    case photo
    case contact
}
