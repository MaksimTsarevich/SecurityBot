//
//  DuplicatePhotosVerticalCellCollectionViewModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.11.22.
//

import UIKit
import Photos

struct DuplicatePhotosVerticalCellCollectionViewModel {
    
    var count: Int
    var duplicatePhotos: [DuplicatePhotosHorizontalCellCollectionViewModel]
    var isSelected: Bool
    
    init(assets: [PHAsset], isSelected: Bool) {
        count = assets.count
        duplicatePhotos = [DuplicatePhotosHorizontalCellCollectionViewModel]()
        
        for index in 0..<assets.count {
            let viewModel = DuplicatePhotosHorizontalCellCollectionViewModel(asset: assets[index], isSelected: isSelected)
            duplicatePhotos.append(viewModel)
        }
        self.isSelected = isSelected
    }
}
