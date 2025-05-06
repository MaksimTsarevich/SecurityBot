//
//  DuplicatePhotoCollectionViewModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.11.22.
//

import UIKit
import Photos

class DuplicatePhotoCollectionViewModel {
    
    func configureDuplicatePhotosViewModel(assets: [[PHAsset]]) -> [DuplicatePhotosVerticalCellCollectionViewModel] {
        var viewModels = [DuplicatePhotosVerticalCellCollectionViewModel]()
        for group in assets {
            let sortedGroup = group.sorted(by: {$0.modificationDate ?? Date() < $1.modificationDate ?? Date()})
            let viewModel = DuplicatePhotosVerticalCellCollectionViewModel(assets: sortedGroup, isSelected: false)
            viewModels.append(viewModel)
        }
        return viewModels
    }
}
