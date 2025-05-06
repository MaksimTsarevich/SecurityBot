//
//  DuplicatePhotosViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 18.10.22.
//

import UIKit
import Photos

class DuplicatePhotosViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectCountLabel: UILabel!
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var duplicatePhotosLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    // - Constraint
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    
    // - DataSource
    private var dataSource: DuplicatePhotosCollectionDataSource!
    
    weak var delegate: UpdateDelegate?
    
    // Data
    var duplicatePhotosModel = [DuplicatePhotosVerticalCellCollectionViewModel]()
    private var selectedPhotos = [PHAsset]()
    var isPresent: Bool = false
    private var type: selectPhotoType = .select
    
    
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
            delegate?.updatePhoto(viewModels: duplicatePhotosModel)
        } else {
            navigationController?.popViewController(animated: true)
            delegate?.updatePhoto(viewModels: duplicatePhotosModel)
        }
        
    }
    
    @IBAction func cleanButtonAction(_ sender: Any) {
        PHPhotoLibrary.shared().performChanges {
            [weak self] in
            guard let strongSelf = self else {return}
            PHAssetChangeRequest.deleteAssets(strongSelf.selectedPhotos as NSArray)
        } completionHandler: { [weak self] (deleted, _) in
            guard let sSelf = self else { return }
            DispatchQueue.main.async {
                if deleted {
                    sSelf.dataSource.delete(viewModels: sSelf.duplicatePhotosModel)
                    var index = 0
                    for viewModel in sSelf.duplicatePhotosModel {
                        let selectedViewModels = viewModel.duplicatePhotos.map({$0.isSelected}).filter({$0})
                        let countViewModels = viewModel.duplicatePhotos.count
                        let countSelect = selectedViewModels.count
                        let diff = countViewModels - countSelect
                        if diff == 0 || diff == 1 {
                            sSelf.duplicatePhotosModel.remove(at: index)
                            if sSelf.duplicatePhotosModel.count == 0 {
                                DispatchQueue.main.async {
                                    sSelf.navigationController?.popViewController(animated: true)
                                    sSelf.delegate?.updatePhoto(viewModels: sSelf.duplicatePhotosModel)
                                }
                            }
                        }
                        else {
                            var n = 0
                            for viewModel in viewModel.duplicatePhotos {
                                if viewModel.isSelected {
                                    sSelf.duplicatePhotosModel[index].duplicatePhotos.remove(at: n)
                                } else {
                                    n += 1
                                }
                            }
                            index += 1
                        }
                    }
                    self?.selectCountLabel.text = "SELECTED 0"
                }
            }
        }
        delegate?.updatePhoto(viewModels: duplicatePhotosModel)
    }
    
    @IBAction func selectAllButtonAction(_ sender: UIButton) {
        switch type{
        case .select:
            for index in 0..<duplicatePhotosModel.count {
                selectDuplicate(tag: index, select: true)
            }
            configureSelectedPhoto()
            selectButton.setTitle("DESELECT ALL", for: .normal)
            type = .deselect
        case .deselect:
            for index in 0..<duplicatePhotosModel.count {
                selectDuplicate(tag: index, select: false)
            }
            configureSelectedPhoto()
            selectButton.setTitle("SELECT ALL", for: .normal)
            type = .select
        }
        
    }
    
}

// MARK: -
// MARK: - Data Source Delegate

extension DuplicatePhotosViewController: DuplicatePhotosCollectionDataSourceDelegate {
    
    func selectPhoto(index: IndexPath) {
        duplicatePhotosModel[index.section].duplicatePhotos[index.row].isSelected = !duplicatePhotosModel[index.section].duplicatePhotos[index.row].isSelected
        configureSelectedPhoto()
        dataSource.updateSelection(viewModels: duplicatePhotosModel)
    }
    
    func selectDuplicate(tag: Int, select: Bool) {
        for i in 1..<duplicatePhotosModel[tag].duplicatePhotos.count {
            duplicatePhotosModel[tag].duplicatePhotos[i].isSelected = select
        }
        dataSource.update(viewModel: duplicatePhotosModel, indexPath: IndexPath(item: tag, section: 0), select: select)
        configureSelectedPhoto()
    }
    
    func update(viewModels: [DuplicatePhotosVerticalCellCollectionViewModel]) {
        self.duplicatePhotosModel = viewModels
        configureSelectedPhoto()
    }
}


// MARK: -
// MARK: - Configure

private extension DuplicatePhotosViewController {
    
    func configure() {
        configureDataSource()
        configureSelectedPhoto()
        configureButton()
        configureLabel()
        Cleaner.photo = true
    }
    
    func update(viewModel: [DuplicatePhotosVerticalCellCollectionViewModel]) {
        self.duplicatePhotosModel = viewModel
        configureSelectedPhoto()
    }
    
    
    func configureDataSource() {
        dataSource = DuplicatePhotosCollectionDataSource(collectionView: collectionView, viewModel: duplicatePhotosModel, delegate: self)
    }
    
    func configureSelectedPhoto() {
        selectedPhotos = []
        var countAllModels = 0
        for duplicatePhotos in duplicatePhotosModel {
            countAllModels += duplicatePhotos.duplicatePhotos.count - 1
            for i in 0..<duplicatePhotos.duplicatePhotos.count {
                if duplicatePhotos.duplicatePhotos[i].isSelected {
                    selectedPhotos.append(duplicatePhotos.duplicatePhotos[i].asset)
                }
            }
        }
        selectCountLabel.text = "SELECTED \(selectedPhotos.count)"
        
        if selectedPhotos.count == countAllModels {
            type = .deselect
            selectButton.setTitle("DESELECT ALL", for: .normal)
        } else if selectedPhotos.count == 0 {
            type = .select
            selectButton.setTitle("SELECT ALL", for: .normal)
        }
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
        duplicatePhotosLabel.addCharacterSpacing(kernValue: 1.21)
    }
}

enum selectPhotoType {
    case select
    case deselect
}
