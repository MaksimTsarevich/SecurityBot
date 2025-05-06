//
//  ContactsDelegate.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 23.11.22.
//

import Foundation

protocol UpdateDelegate: AnyObject {
    func updateContacts(viewModels: [ContactMainViewModel])
    func updatePhoto(viewModels: [DuplicatePhotosVerticalCellCollectionViewModel])
    func updateEvents(viewModels: [BigEventsCollectionViewModel])
    func updateScreenshots(viewModels: [ScreenshotsCollectionViewCellModel])
}
