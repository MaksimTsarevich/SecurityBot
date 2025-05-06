//
//  ScreenshotsCollectionViewManager.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.11.22.
//

import UIKit
import Photos

class ScreenshotsCollectionViewManager {
    
    func configureScreenshotsViewModels(screenshots: [PHAsset]) -> [ScreenshotsCollectionViewCellModel] {
        var viewModels = [ScreenshotsCollectionViewCellModel]()
        for screenshot in screenshots {
            let viewModel = ScreenshotsCollectionViewCellModel(asset: screenshot, isSelected: false)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
}
