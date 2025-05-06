//
//  CleanerScanViewControllerDelegate.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 12.12.22.
//

import Foundation

protocol CleanerScanViewControllerDelegate: AnyObject {
    func updateContacts(viewModels: [ContactMainViewModel])
    func updatePhoto(viewModels: [DuplicatePhotosVerticalCellCollectionViewModel])
    func updateEvents(viewModels: [BigEventsCollectionViewModel])
    func updateScreenshots(viewModels: [ScreenshotsCollectionViewCellModel])
}
