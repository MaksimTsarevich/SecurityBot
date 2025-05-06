//
//  CleanerViewControllerDelegate.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 26.11.22.
//

import Foundation

protocol CleanerViewControllerDelegate: AnyObject {
    func update(contactMainViewModel: [ContactMainViewModel], duplicatePhotosVerticalCellCollectionViewModel: [DuplicatePhotosVerticalCellCollectionViewModel], bigEventsCollectionViewModel: [BigEventsCollectionViewModel], screenshotsCollectionViewCellModel: [ScreenshotsCollectionViewCellModel]) 
}
