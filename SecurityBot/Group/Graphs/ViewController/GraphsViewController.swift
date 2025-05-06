//
//  GraphsViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.03.24.
//

import UIKit
import PanModal
import MTCircleChart
import PhotosUI
import EventKit
import Contacts
//import Starscream

class GraphsViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var backView: UIView!
    
    var circleChart: MTCircleChart!
    
    
    // - Data
    let totalMemory = UIDevice.current.totalDiskSpaceInGBInt
    let usedMemory = UIDevice.current.storageUsedSpace
    var eventStore = EKEventStore()
    let contactStore = CNContactStore()
    var panScrollable: UIScrollView?
    
    var models: [GraphModel] = []
    
    var sizePhoto = 0.0
    var sizeVideo = 0.0
    var sizeEvents = 0.0
    var sizeContacts = 0.0
    var allSize = 0.0
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSize()
    }
}

// MARK: -
// MARK: - Delegate PanModal

extension GraphsViewController: PanModalPresentable {

    var topOffset: CGFloat {
        if UIScreen.main.bounds.height < 570 {
            return 30
        } else {
            return UIScreen.main.bounds.height - 400
        }
    }
    
    var cornerRadius: CGFloat {
        return 15
    }
    
    var showDragIndicator: Bool {
        return true
    }
}

extension GraphsViewController{
    
    func configureSize() {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        DispatchQueue.global().async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.getPhotos{ [weak self] size in
                guard let strongSelf = self else { return }
                strongSelf.sizePhoto = size
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        DispatchQueue.global().async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.getVideos{ [weak self] size in
                guard let strongSelf = self else { return }
                strongSelf.sizeVideo = size
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        DispatchQueue.global().async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.getContacts{ [weak self] size in
                guard let strongSelf = self else { return }
                strongSelf.sizeContacts = size
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        DispatchQueue.global().async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.getEvents{ [weak self] size in
                guard let strongSelf = self else { return }
                strongSelf.sizeEvents = size
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.setupCircleGraph()
            }
        }
    }
    
    func setupCircleGraph() {
        let newColor = UIColor(red: 0.286, green: 0.612, blue: 0.643, alpha: 1)
        
        let mainColor = UIColor(red: 185/255, green: 212/255, blue: 235/255, alpha: 1.0)
        let textColor = UIColor.white
//        print(sizePhoto)
//        print(sizeVideo)
//        print(sizeContacts)
//        print(sizeEvents)
        let v = MTCircleChart(tracks: [
            MTTrack(value: 64, total: 100, color: newColor, text: "Photo"),
            MTTrack(value: 73, total: 100, color: newColor.withAlphaComponent(0.85), text: "Video"),
            MTTrack(value: 43, total: 100, color: newColor.withAlphaComponent(0.65), text: "Contacts"),
            MTTrack(value: 32, total: 100, color: newColor.withAlphaComponent(0.45), text: "Events")
        ], MTConfig(textColor: textColor))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        circleChart = v
        circleChart.frame = CGRect(x: 0, y: 0, width: ECScreenW, height: 300)
        backView.addSubview(circleChart)
    }
    
    
}

// MARK: -
// MARK: - Configure

private extension GraphsViewController {
    
    func calculatePercentage(of number: Double, from total: Double) -> Double {
        let persent  = (number * 100) / total
        return persent / 100.0
    }
    
    func getPhotos(completion: @escaping ((_ fullSize: Double) -> Void)) {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.predicate = NSPredicate(format: "mediaType == %i", PHAssetMediaType.image.rawValue)
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        
        var totalSize: UInt64 = 0
        let group = DispatchGroup()
        
        for index in 0..<allPhotos.count {
            group.enter()
            let asset = allPhotos.object(at: index)
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: requestOptions) { (imageData, _, _, _) in
                if let data = imageData {
                    totalSize += UInt64(data.count)
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            let totalSizeInGigabytes = Double(totalSize) / (1024 * 1024 * 1024)
            completion(totalSizeInGigabytes)
        }
    }

    func getVideos(completion: @escaping (_ fullsize: Double) -> Void) {
        let allVideosOptions = PHFetchOptions()
        allVideosOptions.predicate = NSPredicate(format: "mediaType == %i", PHAssetMediaType.video.rawValue)
        allVideosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allVideos = PHAsset.fetchAssets(with: allVideosOptions)
        
        var totalSize: UInt64 = 0
        let group = DispatchGroup()
        
        for index in 0..<allVideos.count {
            group.enter()
            let asset = allVideos.object(at: index)
            
            let requestOptions = PHVideoRequestOptions()
            requestOptions.version = .original
            
            PHImageManager.default().requestAVAsset(forVideo: asset, options: requestOptions) { (avAsset, _, _) in
                if let avAsset = avAsset as? AVURLAsset {
                    do {
                        let videoData = try Data(contentsOf: avAsset.url)
                        totalSize += UInt64(videoData.count)
                    } catch {
                        print("Error while fetching video data: \(error)")
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            let totalSizeInGigabytes = Double(totalSize) / (1024 * 1024 * 1024)
            completion(totalSizeInGigabytes)
        }
    }
    
    func getContacts(completion: @escaping (_ size: Double) -> Void) {
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactImageDataKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactDepartmentNameKey,
            CNContactPhoneticGivenNameKey,
            CNContactPhoneticMiddleNameKey,
            CNContactPhoneticFamilyNameKey,
            CNContactNicknameKey,
            CNContactPreviousFamilyNameKey,
            CNContactJobTitleKey,
            CNContactPostalAddressesKey,
            CNContactUrlAddressesKey,
            CNContactRelationsKey,
            CNContactSocialProfilesKey,
            CNContactBirthdayKey,
            CNContactInstantMessageAddressesKey
        ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                contacts.append(contact)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
        DispatchQueue.main.async {
            completion((Double(contacts.count) * 0.6) / 1024)
        }
    }
  
    func getEvents(completion: @escaping (_ size: Double) -> Void) {
        
        eventStore.requestAccess(to: .event) {_,_ in
            
            let end = Date(timeIntervalSinceNow: -4*365*24*3600)
            let now = Date()
            
            let predicate = self.eventStore.predicateForEvents(withStart: end, end: now, calendars: nil)
            let events = self.eventStore.events(matching: predicate)
            DispatchQueue.main.async {
                completion((Double(events.count) * 0.6) / 1024)
            }
        }
    }
    
    
}
