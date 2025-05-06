//
//  CleanerViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 12.10.22.
//

import Foundation
import UIKit
import Contacts
import Photos
import EventKit

class CleanerViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var BackgroundView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var guideStackView: UIStackView!
    @IBOutlet var loadingView: [CPLoadingView]!
    @IBOutlet var duplicateSearchView: [UIView]!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var countDuplicatePhotosLabel: UILabel!
    @IBOutlet weak var countDuplicateContactsLabel: UILabel!
    @IBOutlet weak var countDuplicateEventsLabel: UILabel!
    @IBOutlet weak var countDuplicateScreenshotsLabel: UILabel!
    @IBOutlet weak var progressView: CustomProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var photosButton: UIButton!
    @IBOutlet weak var contactsButton: UIButton!
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var screenshotsButton: UIButton!
    
    // - Delegate
    weak var delegate: CleanerViewControllerDelegate?
    
    // - Data
    private var smartScan: SmartScan = .begin
    var countPhotos = 0
    var countContacts = 0
    var countEvents = 0
    var countScreenshots = 0
    var accessPhotos = false
    var accessContacts = false
    var accessEvents = false
    var typeAccess: AccessList = .contacts
    var isPresent = false
    
    // - Manager
    let searchManager = CleanerSearchManager.shared
    
    // - Model
    var duplicatePhotosModel = [DuplicatePhotosVerticalCellCollectionViewModel]()
    var duplicateScreenshots = [ScreenshotsCollectionViewCellModel]()
    var duplicateContacts = [ContactMainViewModel]()
    var duplicateEvents = [BigEventsCollectionViewModel]()
    
    // - Constraint
    @IBOutlet weak var stackViewMenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewGuideWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonHeghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var cleaningGuideHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var batteryExtensionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var progressViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonToTopConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showInfoDuplicate()
        configureRequest()
    }
    
    // - Action
    @IBAction func backButtonAction(_ sender: Any) {
        delegate?.update(contactMainViewModel: duplicateContacts, duplicatePhotosVerticalCellCollectionViewModel: duplicatePhotosModel, bigEventsCollectionViewModel: duplicateEvents, screenshotsCollectionViewCellModel: duplicateScreenshots)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startScanButtonAction(_ sender: Any) {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
//        let accessPhotos = UserDefaultsManager().getBoolValue(data: .accessGallery)
//        let accessEvents = UserDefaultsManager().getBoolValue(data: .accessEvents)
//        let accessContacts = UserDefaultsManager().getBoolValue(data: .accessContacts)
        let isPresent = UserDefaultsManager().getBoolValue(data: .accessAll)
        if !isActive {
//            let premiumVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            premiumVC.modalPresentationStyle = .fullScreen
//            present(premiumVC, animated: true)
        } else {
            //configureRequest()
            if accessEvents && accessPhotos && accessContacts {
                switch smartScan {
                case .begin:
                    smartScan = .clean
                    configureLoad()
                    findDuplicate()
                    startScanning()
                case .clean:
                    showCleanAccessAlert()
                }
            } else {
                if isPresent {
                    if !accessPhotos {
                        presentAccess(type: .gallery)
                    }
                    if !accessEvents {
                        presentAccess(type: .events)
                    }
                    if !accessContacts {
                        presentAccess(type: .contacts)
                    }
                }
            }
        }
    }
    
    @IBAction func duplicatePhotosButton(_ sender: Any) {
        //let accessPhotos = UserDefaultsManager().getBoolValue(data: .accessGallery)
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
//            let premiumVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            premiumVC.modalPresentationStyle = .fullScreen
//            present(premiumVC, animated: true)
        } else {
            if !accessPhotos {
                PHPhotoLibrary.requestAuthorization{ [weak self] status in
                    let required = status == .authorized
                    if self?.accessPhotos != required {
                        self?.accessPhotos = required
                        //UserDefaultsManager().setBoolValue(value: true, data: .accessGallery)
                    } else {
                        DispatchQueue.main.async {
                            self?.presentAccess(type: .gallery)
                        }
                    }
                }
            } else {
                if !Cleaner.photo {
                    let photoVC = UIStoryboard(name: "CleanerScan", bundle: nil).instantiateInitialViewController() as! CleanerScanViewController
                    photoVC.cleanerList = .duplicatePhoto
                    photoVC.delegate = self
                    navigationController?.pushViewController(photoVC, animated: true)
                } else {
                    if duplicatePhotosModel.count != 0 {
                        let photoVC = UIStoryboard(name: "DuplicatePhotos", bundle: nil).instantiateInitialViewController() as! DuplicatePhotosViewController
                        photoVC.duplicatePhotosModel = duplicatePhotosModel
                        photoVC.delegate = self
                        photoVC.isPresent = false
                        navigationController?.pushViewController(photoVC, animated: true)
                    } else {
                        let photoVC = UIStoryboard(name: "CleanerScan", bundle: nil).instantiateInitialViewController() as! CleanerScanViewController
                        photoVC.cleanerList = .duplicatePhoto
                        photoVC.isScan = true
                        photoVC.scanType = .cancel
                        photoVC.duplicatePhotosModel = duplicatePhotosModel
                        navigationController?.pushViewController(photoVC, animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func duplicateContactsAction(_ sender: Any) {
        //let accessContacts = UserDefaultsManager().getBoolValue(data: .accessContacts)
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
//            let premiumVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            premiumVC.modalPresentationStyle = .fullScreen
//            present(premiumVC, animated: true)
        } else {
            if !accessContacts {
                CNContactStore().requestAccess(for: .contacts) { [weak self] (access, error) in
                    if self?.accessContacts != access {
                        self?.accessContacts = access
                        //UserDefaultsManager().setBoolValue(value: true, data: .accessContacts)
                    } else {
                        DispatchQueue.main.async {
                            self?.presentAccess(type: .contacts)
                        }
                    }
                }
            } else {
                if !Cleaner.contact {
                    let contactVC = UIStoryboard(name: "CleanerScan", bundle: nil).instantiateInitialViewController() as! CleanerScanViewController
                    contactVC.cleanerList = .duplicateContact
                    contactVC.delegate = self
                    navigationController?.pushViewController(contactVC, animated: true)
                } else {
                    if duplicateContacts.count != 0 {
                        let contactVC = UIStoryboard(name: "DuplicateContacts", bundle: nil).instantiateInitialViewController() as! DuplicateContactsViewController
                        contactVC.duplicateContacts = duplicateContacts
                        contactVC.delegateContact = self
                        contactVC.isPresent = false
                        navigationController?.pushViewController(contactVC, animated: true)
                    } else {
                        let contactVC = UIStoryboard(name: "CleanerScan", bundle: nil).instantiateInitialViewController() as! CleanerScanViewController
                        contactVC.cleanerList = .duplicateContact
                        contactVC.isScan = true
                        contactVC.scanType = .cancel
                        contactVC.duplicateContacts = duplicateContacts
                        navigationController?.pushViewController(contactVC, animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func eventsAction(_ sender: Any) {
        //let accessEvents = UserDefaultsManager().getBoolValue(data: .accessEvents)
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
//            let premiumVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            premiumVC.modalPresentationStyle = .fullScreen
//            present(premiumVC, animated: true)
        } else {
            if !accessEvents {
                EKEventStore().requestAccess(to: .event) { [weak self] (success, error) in
                    if self?.accessEvents != success {
                        self?.accessEvents = success
                    } else {
                        DispatchQueue.main.async {
                            self?.presentAccess(type: .events)
                        }
                    }
                }
            } else {
                if !Cleaner.event {
                    let eventsVC = UIStoryboard(name: "CleanerScan", bundle: nil).instantiateInitialViewController() as! CleanerScanViewController
                    eventsVC.cleanerList = .events
                    eventsVC.delegate = self
                    navigationController?.pushViewController(eventsVC, animated: true)
                } else {
                    if duplicateEvents.count != 0 {
                        let eventsVC = UIStoryboard(name: "DuplicateEvents", bundle: nil).instantiateInitialViewController() as! DuplicateEventsViewController
                        eventsVC.delegateUpdate = self
                        eventsVC.duplicateEvents = duplicateEvents
                        eventsVC.isPresent = false
                        navigationController?.pushViewController(eventsVC, animated: true)
                    } else {
                        let eventsVC = UIStoryboard(name: "CleanerScan", bundle: nil).instantiateInitialViewController() as! CleanerScanViewController
                        eventsVC.cleanerList = .events
                        eventsVC.isScan = true
                        eventsVC.scanType = .cancel
                        eventsVC.duplicateEvents = duplicateEvents
                        navigationController?.pushViewController(eventsVC, animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func screenshotsAction(_ sender: Any) {
        
        //let accessPhotos = UserDefaultsManager().getBoolValue(data: .accessGallery)
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
//            let premiumVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            premiumVC.modalPresentationStyle = .fullScreen
//            present(premiumVC, animated: true)
        } else {
            if accessPhotos {
                if !Cleaner.screenshot{
                    let screenshotVC = UIStoryboard(name: "CleanerScan", bundle: nil).instantiateInitialViewController() as! CleanerScanViewController
                    screenshotVC.cleanerList = .screenshot
                    screenshotVC.delegate = self
                    navigationController?.pushViewController(screenshotVC, animated: true)
                } else {
                    if duplicateScreenshots.count != 0 {
                        let screenshotVC = UIStoryboard(name: "Screenshots", bundle: nil).instantiateInitialViewController() as! ScreenshotsViewController
                        screenshotVC.delegateUpdate = self
                        screenshotVC.duplicateScreenshots = duplicateScreenshots
                        screenshotVC.isPresent = false
                        navigationController?.pushViewController(screenshotVC, animated: true)
                    } else {
                        let screenshotVC = UIStoryboard(name: "CleanerScan", bundle: nil).instantiateInitialViewController() as! CleanerScanViewController
                        screenshotVC.cleanerList = .screenshot
                        screenshotVC.isScan = true
                        screenshotVC.scanType = .cancel
                        screenshotVC.duplicateScreenshots = duplicateScreenshots
                        navigationController?.pushViewController(screenshotVC, animated: true)
                    }
                }
            } else {
                PHPhotoLibrary.requestAuthorization{ [weak self] status in
                    let required = status == .authorized
                    if self?.accessPhotos != required {
                        self?.accessPhotos = required
                        //UserDefaultsManager().setBoolValue(value: true, data: .accessGallery)
                    } else {
                        DispatchQueue.main.async {
                            self?.presentAccess(type: .gallery)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func cleaningGuideAction(_ sender: Any) {
        let cleaningGuideVC = UIStoryboard(name: "CleaningGuide", bundle: nil).instantiateInitialViewController() as! CleaningGuideViewController
        navigationController?.pushViewController(cleaningGuideVC, animated: true)
    }
    
    @IBAction func batteryExtensionAction(_ sender: Any) {
        let batteryVC = UIStoryboard(name: "BatteryExtension", bundle: nil).instantiateInitialViewController() as! BatteryExtensionViewController
        navigationController?.pushViewController(batteryVC, animated: true)
    }
    
}

// - MARK: -
// - MARK: - Configure

private extension CleanerViewController {
    
    func configure() {
        configureView()
        configureConstraint()
        configureSpace()
        configureButton()
    }
    
    func showCleanAccessAlert() {
        let alertController = UIAlertController(title: "Confirm".localized, message: "Are you sure that you want to remove all duplicates photos, screenshots, duplicates events and duplicates contacts?".localized, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return}
            strongSelf.searchManager.clean(strongSelf.duplicatePhotosModel, strongSelf.duplicateScreenshots, strongSelf.duplicateEvents, strongSelf.duplicateContacts) { [weak self] (photoDelete) in
                guard let sSelf = self else { return }
                if photoDelete {
//                    sSelf.countPhotos = 0
//                    sSelf.countScreenshots = 0
                    sSelf.duplicateScreenshots = []
                    sSelf.duplicatePhotosModel = []
                }
                DispatchQueue.main.async {
                    sSelf.delegate?.update(contactMainViewModel: sSelf.duplicateContacts, duplicatePhotosVerticalCellCollectionViewModel: sSelf.duplicatePhotosModel, bigEventsCollectionViewModel: sSelf.duplicateEvents, screenshotsCollectionViewCellModel: sSelf.duplicateScreenshots)
                    sSelf.presentCount()
                    sSelf.showEmptyAlert()
                }
            }
            self?.countEvents = 0
            self?.countContacts = 0
            self?.duplicateEvents = []
            self?.duplicateContacts = []
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.delegate?.update(contactMainViewModel: sSelf.duplicateContacts, duplicatePhotosVerticalCellCollectionViewModel: sSelf.duplicatePhotosModel, bigEventsCollectionViewModel: sSelf.duplicateEvents, screenshotsCollectionViewCellModel: sSelf.duplicateScreenshots)
                sSelf.presentCount()
                Cleaner.contact = false
                Cleaner.event = false
                Cleaner.photo = false
                Cleaner.screenshot = false
                sSelf.showEmptyAlert()
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
    func configureSpace() {
        let maxWidthGradientView = progressView.bounds.width
        let totalMemory = UIDevice.current.totalDiskSpaceInBytes
        let usedMemory = UIDevice.current.usedDiskSpaceInBytes
        let finalMemory = (usedMemory * 100) / totalMemory
        progressViewConstraint.constant = CGFloat(maxWidthGradientView) - ((CGFloat(maxWidthGradientView) / CGFloat(UIDevice.current.totalDiskSpaceInBytes)) * CGFloat(UIDevice.current.usedDiskSpaceInBytes))
        progressLabel.text = "\(String(describing: finalMemory))% USED"
        
        if finalMemory <= 30 {
            progressView.gradientLayer.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor, UIColor(red: 0.149, green: 1, blue: 0.54, alpha: 1).cgColor]
        } else if finalMemory > 30 && finalMemory < 70 {
            progressView.gradientLayer.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor, UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 1).cgColor]
        } else {
            progressView.gradientLayer.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor, UIColor(red: 1, green: 0.149, blue: 0.353, alpha: 1).cgColor]
        }
        
    }
    
    func configureView() {
        BackgroundView.layer.cornerRadius = 38
        BackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.height < 580 {
            buttonHeghtConstraint.constant = 45
            backgroundViewHeightConstraint.constant = 250
            stackViewTopHeightConstraint.constant = 90
            stackViewBottomHeight.constant = 70
            cleaningGuideHeightConstraint.constant = 45
            batteryExtensionHeightConstraint.constant = 45
            buttonToTopConstraint.constant = 8
        }
        if UIScreen.main.bounds.size.height < 670 && UIScreen.main.bounds.height > 580{
            buttonHeghtConstraint.constant = 55
            backgroundViewHeightConstraint.constant = 290
            buttonToTopConstraint.constant = 14
            
            cleaningGuideHeightConstraint.constant = 50
            batteryExtensionHeightConstraint.constant = 50
            stackViewTopHeightConstraint.constant = 110
            stackViewBottomHeight.constant = 90
            menuStackView.spacing = 5
            guideStackView.spacing = 5
        }
        
        if UIScreen.main.bounds.size.height > 1000 {
            backgroundViewHeightConstraint.constant = 500
        } else {
            stackViewGuideWidthConstraint.constant = UIScreen.main.bounds.width - 50
            stackViewMenuWidthConstraint.constant = UIScreen.main.bounds.width - 50
        }
    }
    
    func configureButton() {
        scanButton.layer.shadowColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.4).cgColor
        if UIScreen.main.bounds.size.height < 670 {
            scanButton.layer.shadowOpacity = 0.6
            if UIScreen.main.bounds.size.height < 580 {
                scanButton.layer.shadowOpacity = 0.3
            }
        } else {
            scanButton.layer.shadowOpacity = 1
        }
        scanButton.layer.shadowRadius = 30
        scanButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        scanButton.layer.shadowPath = UIBezierPath(rect: scanButton.bounds).cgPath
        scanButton.layer.masksToBounds = false
    }
    
    func findDuplicate() {
        searchManager.duplicatePhotos { [weak self] models in
            self?.duplicatePhotosModel = models
            Cleaner.photo = true
        }
        searchManager.fetchScreenshots{ [weak self] models in
            self?.duplicateScreenshots = models
            Cleaner.screenshot = true
        }
        searchManager.duplicateContacts{ [weak self] models in
            self?.duplicateContacts = models
            Cleaner.contact = true
        }
        searchManager.duplicateEvents{ [weak self] models in
            self?.duplicateEvents = models
            Cleaner.event = true
        }
    }
    
    func configureLoad() {
        countDuplicate(isHidden: true)
        loadingView.forEach { view in
            view.isHidden = false
            view.startLoading()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4 ) {
            self.loadingView.forEach { view in
                view.isHidden = true
                view.removeFromSuperview()
            }
            self.countDuplicate(isHidden: false)
        }
    }
    
    func viewHidden(isHidden: Bool){
        duplicateSearchView.forEach{view in
            view.isHidden = isHidden
        }
    }
    
    func countDuplicate(isHidden: Bool) {
        countDuplicatePhotosLabel.isHidden = isHidden
        countDuplicateContactsLabel.isHidden = isHidden
        countDuplicateEventsLabel.isHidden = isHidden
        countDuplicateScreenshotsLabel.isHidden = isHidden
        presentCount()
    }
    
    func presentCount() {
        countEvents = 0
        countPhotos = 0
        countContacts = 0
        countScreenshots = duplicateScreenshots.count
        for duplicatePhotos in duplicatePhotosModel {
            countPhotos += duplicatePhotos.duplicatePhotos.count - 1
        }
        for duplicateContact in duplicateContacts {
            countContacts += duplicateContact.viewModels.count
        }
        for duplicateEvent in duplicateEvents {
            countEvents += duplicateEvent.viewModels.count
        }
        countDuplicatePhotosLabel.text = "\(countPhotos)"
        countDuplicateContactsLabel.text = "\(countContacts)"
        countDuplicateScreenshotsLabel.text = "\(countScreenshots)"
        countDuplicateEventsLabel.text = "\(countEvents)"
    }
    
    func configureRequest() {
        PHPhotoLibrary.requestAuthorization{ [weak self] status in
            let required = status == .authorized
            if self?.accessPhotos != required {
                self?.accessPhotos = required
                UserDefaultsManager().setBoolValue(value: true, data: .accessGallery)
            }
        }
        CNContactStore().requestAccess(for: .contacts) { [weak self] (access, error) in
            if self?.accessContacts != access {
                self?.accessContacts = access
                UserDefaultsManager().setBoolValue(value: true, data: .accessContacts)
            }
        }
        EKEventStore().requestAccess(to: .event) { [weak self] (success, error) in
            if self?.accessEvents != success {
                self?.accessEvents = success
                UserDefaultsManager().setBoolValue(value: true, data: .accessEvents)
            }
        }
        DispatchQueue.main.async {
            self.isPresent = true
            UserDefaultsManager().setBoolValue(value: self.isPresent, data: .accessAll)
        }
    }
    
    func presentAccess(type: AccessList) {
        let vc = UIStoryboard(name: "Access", bundle: nil).instantiateInitialViewController() as! AccessViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.type = type
        present(vc, animated: true)
    }
    
    func startScanning() {
        photosButton.isUserInteractionEnabled = false
        contactsButton.isUserInteractionEnabled = false
        eventsButton.isUserInteractionEnabled = false
        screenshotsButton.isUserInteractionEnabled = false
        viewHidden(isHidden: false)
        scanButton.isUserInteractionEnabled = false
        scanButton.setTitle("SCANNING...", for: .normal)
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        scanButton.layer.shadowOpacity = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 4 ) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.scanButton.setTitle("SMART CLEAN", for: .normal)
            sSelf.scanButton.backgroundColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 1)
            sSelf.scanButton.setTitleColor(.black, for: .normal)
            sSelf.scanButton.isUserInteractionEnabled = true
            sSelf.scanButton.layer.shadowColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 0.3).cgColor
            sSelf.scanButton.layer.shadowOpacity = 1
            sSelf.photosButton.isUserInteractionEnabled = true
            sSelf.contactsButton.isUserInteractionEnabled = true
            sSelf.eventsButton.isUserInteractionEnabled = true
            sSelf.screenshotsButton.isUserInteractionEnabled = true
        }
    }
    
    func reloadScreen () {
        presentCount()
        loadingView.forEach { view in
            view.isHidden = true
        }
    }
    
    func showInfoDuplicate() {
        if Cleaner.photo {
            duplicateSearchView[0].isHidden = false
        }
        if Cleaner.contact {
            duplicateSearchView[1].isHidden = false
        }
        if Cleaner.event {
            duplicateSearchView[2].isHidden = false
        }
        if Cleaner.screenshot {
            duplicateSearchView[3].isHidden = false
        }
        if Cleaner.photo && Cleaner.contact && Cleaner.event && Cleaner.screenshot {
            smartScan = .clean
            self.scanButton.setTitle("SMART CLEAN", for: .normal)
            self.scanButton.backgroundColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 1)
            self.scanButton.setTitleColor(.black, for: .normal)
            self.scanButton.layer.shadowColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 0.3).cgColor
        }
        countDuplicate(isHidden: false)
        loadingView.forEach { view in
            view.isHidden = true
        }
    }
    
    func showEmptyAlert() {
        let alert = UIAlertController(title: "Your device is clean", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                self.navigationController?.popViewController(animated: true)
            case .cancel:
                print("cancel")
            case .destructive:
                print("cancel")
            @unknown default:
                print("cancel")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// - MARK: -
// - MARK: - Delegate

extension CleanerViewController: UpdateDelegate {
    
    func updatePhoto(viewModels: [DuplicatePhotosVerticalCellCollectionViewModel]) {
        duplicatePhotosModel = viewModels
        countPhotos = 0
        for duplicatePhotos in viewModels {
            countPhotos += duplicatePhotos.duplicatePhotos.count - 1
        }
        countDuplicatePhotosLabel.text = "\(countPhotos)"
    }
    
    func updateEvents(viewModels: [BigEventsCollectionViewModel]) {
        duplicateEvents = viewModels
        countEvents = 0
        for duplicateEvent in duplicateEvents {
            countEvents += duplicateEvent.viewModels.count
        }
        countDuplicateEventsLabel.text = "\(countEvents)"
    }
    
    func updateScreenshots(viewModels: [ScreenshotsCollectionViewCellModel]) {
        duplicateScreenshots = viewModels
        countDuplicateScreenshotsLabel.text = "\(duplicateScreenshots.count)"
    }
    
    func updateContacts(viewModels: [ContactMainViewModel]) {
        duplicateContacts = viewModels
        countContacts = 0
        for duplicateContact in duplicateContacts {
            countContacts += duplicateContact.viewModels.count
        }
        countDuplicateContactsLabel.text = "\(countContacts)"
    }
}

extension CleanerViewController: CleanerViewControllerDelegate {
    
    func update(contactMainViewModel: [ContactMainViewModel], duplicatePhotosVerticalCellCollectionViewModel: [DuplicatePhotosVerticalCellCollectionViewModel], bigEventsCollectionViewModel: [BigEventsCollectionViewModel], screenshotsCollectionViewCellModel: [ScreenshotsCollectionViewCellModel]) {
        duplicateContacts = contactMainViewModel
        duplicatePhotosModel = duplicatePhotosVerticalCellCollectionViewModel
        duplicateEvents = bigEventsCollectionViewModel
        duplicateScreenshots = screenshotsCollectionViewCellModel
    }
}

enum SmartScan {
    case begin
    case clean
}
