//
//  ScreenshotsViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import UIKit
import Photos

class ScreenshotsViewController: UIViewController {

    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectCountLabel: UILabel!
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    // - DataSource
    private var dataSource: ScreenshotsCollectionDataSource!
    
    // - Delegate
    weak var delegateUpdate: UpdateDelegate?
    
    // - Manager
    let searchManager = CleanerSearchManager.shared
    
    // - Data
    var duplicateScreenshots = [ScreenshotsCollectionViewCellModel]()
    var selectScreenshots = [PHAsset]()
    var screenshots = [PHAsset]()
    var isPresent = false
    private var type: selectButtonType = .select
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // - Action
    @IBAction func backButtonAction(_ sender: Any) {
        if isPresent {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            delegateUpdate?.updateScreenshots(viewModels: duplicateScreenshots)
        } else {
            navigationController?.popViewController(animated: true)
            delegateUpdate?.updateScreenshots(viewModels: duplicateScreenshots)
        }
    }
    
    @IBAction func selectAllButtonAction(_ sender: Any) {
        switch type {
        case .select:
            for i in 0..<duplicateScreenshots.count {
                duplicateScreenshots[i].isSelected = true
                dataSource.update(viewModels: duplicateScreenshots, indexPath: IndexPath(row: i, section: 0), select: true)
            }
            configureSelectScreenshots()
            selectButton.setTitle("DESELECT ALL", for: .normal)
            type = .deselect
        case .deselect:
            for i in 0..<duplicateScreenshots.count {
                duplicateScreenshots[i].isSelected = false
                dataSource.update(viewModels: duplicateScreenshots, indexPath: IndexPath(row: i, section: 0), select: false)
            }
            configureSelectScreenshots()
            selectButton.setTitle("SELECT ALL", for: .normal)
            type = .select
        }
        
    }
    
    @IBAction func cleanButtonAction(_ sender: Any) {
        PHPhotoLibrary.shared().performChanges { [weak self] in
            guard let sSelf = self else { return }
            PHAssetChangeRequest.deleteAssets(sSelf.selectScreenshots as NSArray)
        } completionHandler: { [weak self] (deleted, _) in
            guard let sSelf = self else { return }
            DispatchQueue.main.async {
                if deleted {
                    sSelf.dataSource.delete(viewModels: sSelf.duplicateScreenshots)
                    sSelf.delegateUpdate?.updateScreenshots(viewModels: sSelf.duplicateScreenshots)
                    //sSelf.update(viewModels: sSelf.duplicateScreenshots)
                    var n = 0
                    for viewModel in sSelf.duplicateScreenshots {
                        if viewModel.isSelected {
                            sSelf.duplicateScreenshots.remove(at: n)
                            sSelf.update(viewModels: sSelf.duplicateScreenshots)
                            if sSelf.duplicateScreenshots.isEmpty {
                                sSelf.update(viewModels: sSelf.duplicateScreenshots)
                                DispatchQueue.main.async {
                                    if sSelf.isPresent {
                                        let viewControllers: [UIViewController] = sSelf.navigationController!.viewControllers as [UIViewController]
                                        sSelf.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                                        //sSelf.delegateUpdate?.updateScreenshots(viewModels: sSelf.duplicateScreenshots)
                                        
                                    } else {
                                        sSelf.navigationController?.popViewController(animated: true)
                                        sSelf.delegateUpdate?.updateScreenshots(viewModels: sSelf.duplicateScreenshots)
                                    }
                                }
                            }
                        } else {
                            n += 1
                        }
                    }
                    sSelf.selectCountLabel.text = "SELECTED 0"
                }
            }
        }
        delegateUpdate?.updateScreenshots(viewModels: duplicateScreenshots)
    }
}

// MARK: -
// MARK: - Delegate

extension ScreenshotsViewController: ScreenshotsCollectionDataSourceDelegate {
    
    func update(viewModels: [ScreenshotsCollectionViewCellModel]) {
        self.duplicateScreenshots = viewModels
        configureSelectScreenshots()
    }
    
}

// MARK: -
// MARK: - Configure

private extension ScreenshotsViewController {
    
    func configure() {
        configureDataSource()
        configureSelectScreenshots()
        configureButton()
        configureLabel()
    }
    
    func configureDataSource() {
        dataSource = ScreenshotsCollectionDataSource(collectionView: collectionView, viewModels: duplicateScreenshots, delegate: self)
    }
    
    func configureSelectScreenshots() {
        Cleaner.screenshot = true
        selectScreenshots = []
        for i in 0..<duplicateScreenshots.count {
            if duplicateScreenshots[i].isSelected {
                selectScreenshots.append(duplicateScreenshots[i].asset)
            }
        }
        selectCountLabel.text = "SELECTED \(selectScreenshots.count)"
        if selectScreenshots.count == duplicateScreenshots.count {
            type = .deselect
            selectButton.setTitle("DESELECT ALL", for: .normal)
        } else if selectScreenshots.count == 0 {
            type = .select
            selectButton.setTitle("SELECT ALL", for: .normal)
        }
    }
    
    func configureReload() {
        searchManager.fetchScreenshots{ [weak self] models in
            self?.duplicateScreenshots = models
            self?.dataSource.update(viewModels: models)
        }
    }
    
    func updatePhotos() {
        guard let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject else { return }
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.predicate = NSPredicate(format: "mediaType == %i", 1)
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allPhotos = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
        var photos = [PHAsset]()
        for i in 0..<allPhotos.count {
            photos.append(allPhotos.object(at: i))
        }
        _ = ScreenshotsCollectionViewManager().configureScreenshotsViewModels(screenshots: photos)
    }
    
    func configureButton() {
        cleanButton.layer.shadowColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.3).cgColor
        cleanButton.layer.shadowOpacity = 1
        cleanButton.layer.shadowRadius = 20
        cleanButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        cleanButton.layer.shadowPath = UIBezierPath(rect: cleanButton.bounds).cgPath
        cleanButton.layer.masksToBounds = false
    }
    
    func configureLabel() {
        titleLabel.addCharacterSpacing(kernValue: 1.21)
    }
}


enum selectButtonType {
    case select
    case deselect
}
