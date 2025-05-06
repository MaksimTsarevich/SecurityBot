//
//  SecretFolderViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 20.10.22.
//

import UIKit
import Photos
import TLPhotoPicker

class SecretFolderViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var segmentControlView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lockStackView: UIStackView!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var accessImage: UIImageView!
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var selectLabel: UILabel!
    
    
    
    // - Constraint
    @IBOutlet weak var leadingSegmentContraint: NSLayoutConstraint!
    @IBOutlet weak var widthSegmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectLabelWidthConstraint: NSLayoutConstraint!
    
    // - Data
    private var isOn: Bool = false
    private var dataSource:SecretFolderCollectionDataSource!
    private var type: SecretType = .photo
    var selectTypeContact: selectType = .select
    var selectTypePhoto: selectType = .select
    var contactModels: [SecretContactModel] = []
    var photoModels: [SecretImageModel] = []
    var isSelect = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if isActive {
            let passwordEnable = UserDefaultsManager().getBoolValue(data: .passwordEnable)
            if passwordEnable {
                lockStatus()
            }
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        widthSegmentConstraint.constant = (segmentControlView.bounds.width - 8) / 2
    }
    
    // - Action
    @IBAction func addAction(_ sender: Any) {
        if !SecretFolder.lock {
            return
        } else {
            if type == .photo {
                addImages()
            } else if type == .contact {
                addContact()
            }
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        if type == .contact {
            deleteContacts()
        } else if type == .photo {
            deleteImages()
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
        var sharingImages = [UIImage]()
        for model in photoModels {
            if model.isSelected == true {
                sharingImages.append(model.image)
            }
        }
        if sharingImages.isEmpty {
            return
        } else {
            let vc = UIActivityViewController(activityItems: sharingImages, applicationActivities: [])
            present(vc, animated: true)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        let passwordEnable = UserDefaultsManager().getBoolValue(data: .passwordEnable)
        if passwordEnable {
            SecretFolder.lock = true
        }
    }
    
    
    @IBAction func selectImageAction(_ sender: Any) {
        
        if type == .contact {
            if !contactModels.isEmpty {
                switch selectTypeContact {
                case .select:
                    dataSource.selectType = .cancel
                    selectTypeContact = .cancel
                    selectLabel.text = "Cancel"
                    selectContacts()
                    addButton.isHidden = true
                    buttonStackView.isHidden = false
                    deleteButton.isHidden = false
                case .cancel:
                    dataSource.selectType = .select
                    selectTypeContact = .select
                    selectLabel.text = "Select"
                    cancelContacts()
                    addButton.isHidden = false
                    buttonStackView.isHidden = true
                    deleteButton.isHidden = true
                }
            }
        }
        
        if type == .photo {
            if !photoModels.isEmpty {
                switch selectTypePhoto {
                case .select:
                    dataSource.selectType = .cancel
                    selectTypePhoto = .cancel
                    selectLabel.text = "Cancel"
                    selectImages()
                    addButton.isHidden = true
                    buttonStackView.isHidden = false
                    deleteButton.isHidden = false
                    shareButton.isHidden = false
                case .cancel:
                    dataSource.selectType = .select
                    selectTypePhoto = .select
                    selectLabel.text = "Select"
                    cancelImages()
                    addButton.isHidden = false
                    buttonStackView.isHidden = true
                    deleteButton.isHidden = true
                    shareButton.isHidden = true
                }
            }
        }
        if UIScreen.main.bounds.height > 570 {
            selectLabel.addCharacterSpacing(kernValue: 1.0)
        }
    }
    
    @IBAction func lockAction(_ sender: Any) {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if isActive {
            let passwordEnable = UserDefaultsManager().getBoolValue(data: .passwordEnable)
            if passwordEnable {
                if !SecretFolder.lock {
                    configurePassword()
                } else {
                    configureToUnlock(type: type)
                }
            }
        } else {
//            let premiumVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            premiumVC.modalPresentationStyle = .fullScreen
//            present(premiumVC, animated: true)
        }
    }
    
    // - Animation
    @objc func someAction() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.leadingSegmentContraint.constant = sSelf.isOn ?  4 : sSelf.segmentView.frame.width + 4
            sSelf.accessImage.image = UIImage(named: sSelf.isOn ? "AccessPhotoImage" : "accessContact")
            sSelf.accessLabel.text = sSelf.isOn ? "Tap on a Lock to see private\nphotos" : "Tap on a Lock to see private\ncontacts"
        }
        self.buttonStackView.isHidden = true
        self.shareButton.isHidden = !self.isOn
        self.deleteButton.isHidden = true
        self.selectTypePhoto = .select
        self.selectTypeContact = .select
        self.selectLabel.text = "Select"
        self.dataSource.selectType = .select
        self.addButton.isHidden = !SecretFolder.lock
        if self.type == .photo {
            self.type = .contact
        } else {
            self.type = .photo
        }
        self.dataSource.update(type: self.type)
        self.addButton.setTitle(self.isOn ? "ADD PHOTO" : "ADD CONTACTS", for: .normal)
        self.isOn = !self.isOn
        if UIScreen.main.bounds.height > 570 {
            selectLabel.addCharacterSpacing(kernValue: 1.0)
        }
    }
}

// MARK: -
// MARK: - UIGestureRecognizerDelegate

extension SecretFolderViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive
                           touch: UITouch) -> Bool {
        return !segmentView.bounds.contains(touch.location(in: segmentView))
    }
}


// MARK: -
// MARK: - Configure

private extension SecretFolderViewController {
    
    func configure() {
        configureView()
        configureSegmentControl()
        configureDataSource()
        configureConstraint()
        configureModels()
        configurePassword()
        configureButton()
        configureLabel()
        let passwordEnable = UserDefaultsManager().getBoolValue(data: .passwordEnable)
        if passwordEnable {
            SecretFolder.lock = true
        }
    }
    
    func configureView() {
        topView.layer.cornerRadius = 30
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func configureSegmentControl() {
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.someAction))
        tapView.delegate = self
        segmentControlView.addGestureRecognizer(tapView)
    }
    
    func configureDataSource() {
        dataSource = SecretFolderCollectionDataSource(collectionView: collectionView, type: type, contactModels: contactModels, photoModels: photoModels, delegate: self)
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.height < 580 {
            selectButtonWidthConstraint.constant = 50
            selectLabelWidthConstraint.constant = 50
        }
        if UIScreen.main.bounds.height < 1000 {
            viewWidthConstraint.constant = UIScreen.main.bounds.width
            collectionViewWidthConstraint.constant = UIScreen.main.bounds.width - 50
        } else {
            viewWidthConstraint.constant = UIScreen.main.bounds.width
        }
    }
    
    func configurePassword() {
        let passwordEnable = UserDefaultsManager().getBoolValue(data: .passwordEnable)
        if passwordEnable {
            let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateInitialViewController() as! PasswordViewController
            passwordVC.modalPresentationStyle = .overCurrentContext
            passwordVC.delegate = self
            present(passwordVC, animated: true)
        } else {
            collectionView.isHidden = false
            dataSource.updateDataPhoto(models: photoModels, reloadData: true)
            dataSource.updateDataContact(models: contactModels, reloadData: true)
        }
    }
    
    func configureButton() {
        addButton.layer.shadowColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.3).cgColor
        addButton.layer.shadowOpacity = 1
        addButton.layer.shadowRadius = 20
        addButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        addButton.layer.shadowPath = UIBezierPath(rect: addButton.bounds).cgPath
        addButton.layer.masksToBounds = false
    }
    
    func configureToUnlock(type: SecretType) {
        self.type = type
        collectionView.isHidden = SecretFolder.lock
        self.lockStackView.isHidden = !SecretFolder.lock
        self.lockButton.setImage(UIImage(named: SecretFolder.lock ? "LockDarkImage" : "unlockImage"), for: .normal)
        self.selectLabel.isHidden = SecretFolder.lock
        self.selectImageButton.isHidden = SecretFolder.lock
        self.buttonStackView.isHidden = true
        self.addButton.isHidden = SecretFolder.lock
        SecretFolder.lock = !SecretFolder.lock
        
    }
    
    func getContacts() {
        var countOfLoadedContacts = 0
        var number: Int = 1
        let fileManager = FileManager.default
        while countOfLoadedContacts < UserDefaultsManager.shared.getIntValue(data: .countOfSavedContacts) {
            guard var fileURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else { return }
            fileURL.appendPathComponent("SecretContacts")
            fileURL.appendPathComponent("\(number).txt")
            if fileManager.fileExists(atPath: fileURL.path), let fileData = fileManager.contents(atPath: fileURL.path), let string = String(data: fileData, encoding: .utf8) {
                let substrings = string.components(separatedBy: "\n")
                contactModels.insert(SecretContactModel(name: substrings[0], number: substrings[1], isSelected: false, filePath: fileURL.path), at: 0)
                countOfLoadedContacts += 1
            }
            number += 1
        }
    }
    
    func addContact() {
        let alert = UIAlertController(title: "Add Contact", message: "Please enter Name and Phohe Number", preferredStyle: .alert)
        alert.addTextField { nameTextField in
            nameTextField.placeholder = "Name"
        }
        alert.addTextField { numberTextField in
            numberTextField.placeholder = "Number"
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addButton = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            let name = alert.textFields?[0].text
            let number = alert.textFields?[1].text
            self?.saveContact(name: name ?? "Name", number: number ?? "Number", completion: { path in
                self?.contactModels.insert(SecretContactModel(name: name ?? "Name", number: number ?? "Number", isSelected: false, filePath: path), at: 0)
                self?.dataSource.updateDataContact(models: self?.contactModels ?? [], reloadData: true)
            })
        }
        alert.addAction(cancelButton)
        alert.addAction(addButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveContact(name: String, number: String, completion: @escaping (_ path: String) -> Void) {
        let fileManager = FileManager.default
        guard var directoryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else { return }
        directoryURL.appendPathComponent("SecretContacts")
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: [:])
        }
        catch {
            return
        }
        
        let fileURL = directoryURL.appendingPathComponent("\(UserDefaultsManager.shared.getIntValue(data: .lastSavedContact) + 1).txt")
        let string = (name + "\n" + number).data(using: .utf8)
        fileManager.createFile(atPath: fileURL.path, contents: string, attributes: [:])
        UserDefaultsManager.shared.setIntValue(value: UserDefaultsManager.shared.getIntValue(data: .countOfSavedContacts) + 1, data: .countOfSavedContacts)
        UserDefaultsManager.shared.setIntValue(value: UserDefaultsManager.shared.getIntValue(data: .lastSavedContact) + 1, data: .lastSavedContact)
        
        completion(fileURL.path)
    }
    
    func selectContacts() {
        isSelect = false
        for i in 0..<contactModels.count {
            contactModels[i].isSelected = false
        }
        dataSource.updateDataContact(models: contactModels, reloadData: true)
    }
    
    func cancelContacts() {
        isSelect = true
        for i in 0..<contactModels.count {
            contactModels[i].isSelected = true
        }
        dataSource.updateDataContact(models: contactModels, reloadData: true)
    }
    
    
    func getImages() {
        var countOfLoadedImages = 0
        var number: Int = 1
        let fileManager = FileManager.default
        while countOfLoadedImages < UserDefaultsManager.shared.getIntValue(data: .countOfSavedImages) {
            guard var fileURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else { return }
            fileURL.appendPathComponent("SecretImages")
            fileURL.appendPathComponent("\(number).png")
            if fileManager.fileExists(atPath: fileURL.path), let fileData = fileManager.contents(atPath: fileURL.path), let image = UIImage(data: fileData) {
                photoModels.insert(SecretImageModel(image: image, isSelected: false, filePath: fileURL.path), at: 0)
                countOfLoadedImages += 1
            }
            number += 1
        }
    }
    
    
    
    func saveImage(image: UIImage, asset: PHAsset, completion: @escaping (_ path: String) -> Void) {
        let fileManager = FileManager.default
        guard var directoryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else { return }
        directoryURL.appendPathComponent("SecretImages")
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: [:])
        }
        catch {
            return
        }
        
        let fileURL = directoryURL.appendingPathComponent("\(UserDefaultsManager.shared.getIntValue(data: .lastSavedImage) + 1).png")
        if let pngRepresentation = image.pngData() {
            do {
                try pngRepresentation.write(to: fileURL, options: .atomic)
                UserDefaultsManager.shared.setIntValue(value: UserDefaultsManager.shared.getIntValue(data: .lastSavedImage) + 1, data: .lastSavedImage)
                UserDefaultsManager.shared.setIntValue(value: UserDefaultsManager.shared.getIntValue(data: .countOfSavedImages) + 1, data: .countOfSavedImages)
                completion(fileURL.path)
            }
            catch {
                return
            }
        }
    }
    
    func addImages() {
        PHPhotoLibrary.requestAuthorization{ [weak self] status in
            let required = status == .authorized
            if required {
                DispatchQueue.main.async { [weak self] in
                    let picker = TLPhotosPickerViewController()
                    picker.delegate = self
                    var configure = TLPhotosPickerConfigure()
                    configure.mediaType = .image
                    configure.maxSelectedAssets = 5
                    picker.configure = configure
                    self?.present(picker, animated: true)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let sSelf = self else { return }
                    let vc = UIStoryboard(name: "Access", bundle: nil).instantiateInitialViewController() as! AccessViewController
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.type = .gallery
                    sSelf.present(vc, animated: true)
                }
                
            }
        }
        
    }
    
    func selectImages() {
        isSelect = false
        for i in 0..<photoModels.count {
            photoModels[i].isSelected = false
        }
        dataSource.updateDataPhoto(models: photoModels, reloadData: true)
        
    }
    
    func cancelImages() {
        isSelect = true
        for i in 0..<photoModels.count {
            photoModels[i].isSelected = true
        }
        dataSource.updateDataPhoto(models: photoModels, reloadData: true)
    }
    
    
    func deleteContacts() {
        let fileManager = FileManager.default
        var newModels = [SecretContactModel]()
        for model in contactModels {
            if model.isSelected != true {
                newModels.append(model)
            } else {
                try? fileManager.removeItem(atPath: model.filePath)
                UserDefaultsManager.shared.setIntValue(value: UserDefaultsManager.shared.getIntValue(data: .countOfSavedContacts) - 1, data: .countOfSavedContacts)
            }
        }
        contactModels = newModels
        dataSource.updateDataContact(models: contactModels, reloadData: true)
        
        if contactModels.count == 0 {
            addButton.isHidden = false
            buttonStackView.isHidden = true
            selectTypeContact = .select
            selectLabel.text = "Select"
            //selectImageButton.setTitle("Select", for: .normal)
            dataSource.selectType = .select
            if UIScreen.main.bounds.height > 570 {
                selectLabel.addCharacterSpacing(kernValue: 1.0)
            }
        }
    }
    
    func deleteImages() {
        let fileManager = FileManager.default
        var newModels = [SecretImageModel]()
        for model in photoModels {
            if model.isSelected != true {
                newModels.append(model)
            } else {
                try? fileManager.removeItem(atPath: model.filePath)
                UserDefaultsManager.shared.setIntValue(value: UserDefaultsManager.shared.getIntValue(data: .countOfSavedImages) - 1, data: .countOfSavedImages)
            }
        }
        photoModels = newModels
        dataSource.updateDataPhoto(models: photoModels, reloadData: true)
        if photoModels.count == 0 {
            addButton.isHidden = false
            buttonStackView.isHidden = true
            selectTypePhoto = .select
            selectLabel.text = "Select"
            //selectImageButton.setTitle("Select", for: .normal)
            dataSource.selectType = .select
            if UIScreen.main.bounds.height > 570 {
                selectLabel.addCharacterSpacing(kernValue: 1.0)
            }
        }
    }
    
    func configureModels() {
        getContacts()
        getImages()
    }
    
    func configureLabel() {
        if UIScreen.main.bounds.height > 570 {
            selectLabel.addCharacterSpacing(kernValue: 1.0)
        }
    }
}

// MARK: -
// MARK: - Delegate

extension SecretFolderViewController: SecretFolderCollectionDataSourceDelegate {
    func updateImage(models: [SecretImageModel]) {
        self.photoModels = models
    }
    
    func updateContact(models: [SecretContactModel]) {
        self.contactModels = models
    }
}

extension SecretFolderViewController: PasswordViewControllerDelegate {
    func passwordEnable() {
        
    }
    
    func lockStatus() {
        collectionView.isHidden = false
        dataSource.updateDataPhoto(models: photoModels, reloadData: true)
        dataSource.updateDataContact(models: contactModels, reloadData: true)
        configureToUnlock(type: type)
    }
    
}

extension SecretFolderViewController: TLPhotosPickerViewControllerDelegate {
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        if withPHAssets.count == 0 { return }
        
        var newPhotos = [SecretImageModel]()
        var loadedAssets = 0
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        let targetSize = PHImageManagerMaximumSize
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            for asset in withPHAssets {
                if asset.mediaType == .image {
                    PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { [weak self] image, _ in
                        guard let strongSelf = self else { return }
                        
                        if let image = image {
                            strongSelf.saveImage(image: image, asset: asset, completion: { path in
                                newPhotos.append(SecretImageModel(image: image, isSelected: false, filePath: path))
                            })
                            loadedAssets += 1
                            
                            if loadedAssets == withPHAssets.count {
                                strongSelf.photoModels = newPhotos + strongSelf.photoModels
                                DispatchQueue.main.async {
                                    strongSelf.dataSource.updateDataPhoto(models: strongSelf.photoModels, reloadData: true)
                                    PHPhotoLibrary.shared().performChanges({
                                        PHAssetChangeRequest.deleteAssets(withPHAssets as NSArray)
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

enum selectType {
    case select
    case cancel
}
