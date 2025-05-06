//
//  CleanerSearchManager.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.11.22.
//

import Foundation
import Contacts
import Photos
import EventKit

class CleanerSearchManager {
    
    static let shared = CleanerSearchManager()
    
    // - Manager
    private let searchEventsManaher = EventsSearchManager.shared
    private let duplicatePhotoManager = DuplicatePhotoManager.shared
    private let searchContactsManager = ContactSearchManager.shared
    
    // - ConfigureModel
    private let duplicateScreenshotsModel = ScreenshotsCollectionViewManager()
    private let duplicatePhotosModel = DuplicatePhotoCollectionViewModel()
    private let duplicateContactsModel = ContactsCollectionViewModelConfigure()
    private let duplicateEventsModel = EventsCollectionViewModelConfigure()
    
    
    
    
    func duplicatePhotos(completion: @escaping (_ models: [DuplicatePhotosVerticalCellCollectionViewModel]) -> Void) {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.predicate = NSPredicate(format: "mediaType == %i", 1)
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        var photos = [PHAsset]()
        for i in 0..<allPhotos.count {
            photos.append(allPhotos.object(at: i))
        }
        let duplicateGroup = duplicatePhotoManager.searchDuplicatePhotos(assets: photos, strictness: .similar)
        let viewModels = duplicatePhotosModel.configureDuplicatePhotosViewModel(assets: duplicateGroup)
        completion(viewModels)
    }
    
    func duplicateEvents(completion: @escaping (_ models: [BigEventsCollectionViewModel]) -> Void) {
        searchEventsManaher.getEvents() {[weak self] events in guard let strongSelf = self else { return }
            print(events.count)
            let viewModels = strongSelf.duplicateEventsModel.configureEventsViewModels(events: events)
            completion(viewModels)
        }
    }
    
    func duplicateContacts(completion: @escaping (_ models: [ContactMainViewModel]) -> Void) {
        searchContactsManager.fetchContacts { [weak self] contacts in
            guard let strongSelf = self else { return }
            let viewModels = strongSelf.duplicateContactsModel.configureContactsViewModels(contacts: contacts)
            completion(viewModels)
        }
    }
    
    func fetchScreenshots(completion: @escaping (_ models: [ScreenshotsCollectionViewCellModel]) -> Void) {
        guard let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject else { return }
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.predicate = NSPredicate(format: "mediaType == %i", 1)
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allPhotos = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
        
        var photos = [PHAsset]()
        for i in 0..<allPhotos.count {
            photos.append(allPhotos.object(at: i))
        }
        
        let viewModels = duplicateScreenshotsModel.configureScreenshotsViewModels(screenshots: photos)
        
        completion(viewModels)
    }
    
    func clean(_ photos: [DuplicatePhotosVerticalCellCollectionViewModel], _ screenshots: [ScreenshotsCollectionViewCellModel], _ events: [BigEventsCollectionViewModel], _ contacts: [ContactMainViewModel], completion: @escaping (_ photoDelete: Bool) -> Void) {
        var photosAccess = false
        let screenshotsAccess = false
        var cnContacts = [CNContact]()
        for viewModel in contacts {
            for i in 1..<viewModel.viewModels.count {
                cnContacts.append(viewModel.viewModels[i].contact)
            }
        }
        searchContactsManager.delete(contacts: cnContacts) {contacts in }
        
        var eventArray = [EKEvent]()
        
        for viewModel in events {
            for i in 1..<viewModel.viewModels.count {
                eventArray.append(viewModel.viewModels[i].event)
            }
        }
        searchEventsManaher.delete(events: eventArray) { events in }
        
        var photosArray = [PHAsset]()
        for model in photos {
            var index = 0
            for viewModel in model.duplicatePhotos {
                if index != 0 {
                    photosArray.append(viewModel.asset)
                } else {
                    index += 1
                }
            }
        }
        
        if photosArray.isEmpty {
            photosAccess = true
        }
        
        photosAccess = true
        
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(photosArray as NSArray)
        } completionHandler: { success, error in
            if success {
                photosAccess = true
                if photosAccess {
                    completion(true)
                }
            }
            
        }
    }
}
