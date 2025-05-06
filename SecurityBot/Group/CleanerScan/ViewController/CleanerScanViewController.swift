//
//  CleanerScanViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 12.10.22.
//

import Foundation
import UIKit

class CleanerScanViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var CleanerImage: UIImageView!
    @IBOutlet weak var cleanerNameLabel: AnimatedLabel!
    @IBOutlet weak var scanButtonView: UIButton!
    @IBOutlet weak var loadingView: CPLoadingView!
    @IBOutlet weak var notFoundLabel: UILabel!
    
    // - Constraint
    @IBOutlet weak var scanButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var stackviewToTopConstraint: NSLayoutConstraint!
    
    // - Delegate
    weak var delegate: UpdateDelegate?
    
    // - Data
    var cleanerList: CleanerList = .duplicatePhoto
    var scanType: ScanType = .begin
    let searchManager = CleanerSearchManager.shared
    var isScan: Bool = false
    
    // - Model
    var duplicatePhotosModel = [DuplicatePhotosVerticalCellCollectionViewModel]()
    var duplicateScreenshots = [ScreenshotsCollectionViewCellModel]()
    var duplicateContacts = [ContactMainViewModel]()
    var duplicateEvents = [BigEventsCollectionViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - Action
    @IBAction func backButtonAction(_ sender: Any) {
        configureUpdateModels()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func scanButtonAction(_ sender: Any) {
        self.updateScanType(isCancel: self.scanType == .cancel)
    }
    
}


// MARK: -
// MARK: - Configure

private extension CleanerScanViewController {
    
    func configure() {
        configureSetView()
        configureModelsIsEmply()
        configureConstraint()
    }
    
    func configureModelsIsEmply() {
        if isScan == true{
            loadingView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateScanType(isCancel: false)
            }
            cleanerNameLabel.isHidden = true
            notFoundLabel.isHidden = false
        }
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.height < 580 {
            scanButtonWidth.constant = 280
            stackviewToTopConstraint.constant = 5
        }
    }
    
    func configureSetView() {
        titleLabel.text = cleanerList.rawValue
        CleanerImage.image = cleanerList.icon
        cleanerNameLabel.text = cleanerList.rawValue
        scanButtonView.backgroundColor = cleanerList.color
    }
    
    func updateScanType(isCancel: Bool) {
        switch scanType {
        case .begin:
            scanType = .cancel
            isScan = true
            loadingView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.cleanerNameLabel.font = UIFont(name: "Barlow-Medium", size: 20)
                if self.cleanerList == .duplicatePhoto {
                    self.cleanerNameLabel.count(from: 0, to: 98, duration: .random)
                } else {
                    self.cleanerNameLabel.count(from: 0, to: 100, duration: .random)
                }
                if self.cleanerList == .events {
                    self.getViewModels()
                }
                
                self.loadingView.isHidden = false
                self.loadingView.startLoading()
            })
            UIView.transition(with: scanButtonView, duration: 0.3, options:  .transitionCrossDissolve) { [weak self] in
                self?.scanButtonView.setTitle("CANCEL", for: .normal)
                self?.scanButtonView.setTitleColor(.white, for: .normal)
                self?.scanButtonView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.06)
            }
            cleanerNameLabel.completion = { [weak self] in
                guard let sSelf = self else { return }
                if sSelf.cleanerList == .duplicatePhoto {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                        sSelf.searchManager.duplicatePhotos { [weak self] models in
                            guard let strongSelf = self else { return }
                            strongSelf.duplicatePhotosModel = models
                            strongSelf.cleanerNameLabel.count(from: 98, to: 100, duration: .random)
                            //strongSelf.loadingView.completeLoading(success: true)
                        }
                        sSelf.delegate?.updatePhoto(viewModels: sSelf.duplicatePhotosModel)
                        Cleaner.photo = true
                    }
                    sSelf.cleanerNameLabel.completion = { [ weak self] in
                        if sSelf.duplicatePhotosModel.count == 0 {
                            sSelf.loadingView.isHidden = false
                            sSelf.loadingView.completeLoading(success: true)
                            sSelf.scanType = .cancel
                            sSelf.updateScanType(isCancel: false)
                            sSelf.loadingView.completeLoading(success: true)
                            sSelf.cleanerNameLabel.isHidden = true
                            sSelf.notFoundLabel.isHidden = false
                        } else {
                            sSelf.cleanerNameLabel.isHidden = false
                            sSelf.notFoundLabel.isHidden = true
                            sSelf.loadingView.completeLoading(success: true)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                                guard let strongSelf = self else { return }
                                let photoVC = UIStoryboard(name: "DuplicatePhotos", bundle: nil).instantiateInitialViewController() as! DuplicatePhotosViewController
                                photoVC.duplicatePhotosModel = strongSelf.duplicatePhotosModel
                                photoVC.delegate = strongSelf.delegate
                                photoVC.isPresent = true
                                strongSelf.navigationController?.pushViewController(photoVC, animated: true)
                            }
                        }
                    }
                } else if sSelf.cleanerList == .events {
                    sSelf.getViewModels()
                    if sSelf.duplicateEvents.count == 0 {
                        sSelf.loadingView.isHidden = false
                        sSelf.loadingView.completeLoading(success: true)
                        sSelf.scanType = .cancel
                        sSelf.updateScanType(isCancel: false)
                        sSelf.loadingView.completeLoading(success: true)
                        sSelf.cleanerNameLabel.isHidden = true
                        sSelf.notFoundLabel.isHidden = false
                    } else {
                        sSelf.cleanerNameLabel.isHidden = false
                        sSelf.notFoundLabel.isHidden = true
                        sSelf.loadingView.completeLoading(success: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                            guard let strongSelf = self else { return }
                            let eventVC = UIStoryboard(name: "DuplicateEvents", bundle: nil).instantiateInitialViewController() as! DuplicateEventsViewController
                            eventVC.duplicateEvents = strongSelf.duplicateEvents
                            eventVC.delegateUpdate = strongSelf.delegate
                            eventVC.isPresent = true
                            strongSelf.navigationController?.pushViewController(eventVC, animated: true)
                        }
                    }
                } else if sSelf.cleanerList == .duplicateContact {
                    sSelf.getViewModels()
                    if sSelf.duplicateContacts.count == 0 {
                        sSelf.loadingView.isHidden = false
                        sSelf.loadingView.completeLoading(success: true)
                        sSelf.scanType = .cancel
                        sSelf.updateScanType(isCancel: false)
                        sSelf.loadingView.completeLoading(success: true)
                        sSelf.cleanerNameLabel.isHidden = true
                        sSelf.notFoundLabel.isHidden = false
                    } else {
                        sSelf.cleanerNameLabel.isHidden = false
                        sSelf.notFoundLabel.isHidden = true
                        sSelf.loadingView.completeLoading(success: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                            guard let strongSelf = self else { return }
                            let contactVC = UIStoryboard(name: "DuplicateContacts", bundle: nil).instantiateInitialViewController() as! DuplicateContactsViewController
                            contactVC.duplicateContacts = strongSelf.duplicateContacts
                            contactVC.delegateContact = strongSelf.delegate
                            contactVC.isPresent = true
                            strongSelf.navigationController?.pushViewController(contactVC, animated: true)
                        }
                    }
                } else if sSelf.cleanerList == .screenshot {
                    sSelf.getViewModels()
                    if sSelf.duplicateScreenshots.count == 0 {
                        sSelf.loadingView.isHidden = false
                        sSelf.loadingView.completeLoading(success: true)
                        sSelf.scanType = .cancel
                        sSelf.updateScanType(isCancel: false)
                        sSelf.loadingView.completeLoading(success: true)
                        sSelf.cleanerNameLabel.isHidden = true
                        sSelf.notFoundLabel.isHidden = false
                    } else {
                        sSelf.cleanerNameLabel.isHidden = false
                        sSelf.notFoundLabel.isHidden = true
                        sSelf.loadingView.completeLoading(success: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                            guard let strongSelf = self else { return }
                            let screenshotsVC = UIStoryboard(name: "Screenshots", bundle: nil).instantiateInitialViewController() as! ScreenshotsViewController
                            screenshotsVC.duplicateScreenshots = strongSelf.duplicateScreenshots
                            screenshotsVC.delegateUpdate = strongSelf.delegate
                            screenshotsVC.isPresent = true
                            strongSelf.navigationController?.pushViewController(screenshotsVC, animated: true)
                        }
                    }
                }
            }
        case .cancel:
            scanType = isCancel ? .begin : .returnScan
            scanButtonView.setTitle(isCancel ? "START SCAN" : "RETURN BACK", for: .normal)
            scanButtonView.setTitleColor(UIColor(red: 0.034, green: 0.041, blue: 0.079, alpha: 1), for: .normal)
            scanButtonView.backgroundColor = cleanerList.color
            cleanerNameLabel.isHidden = isCancel ? false : true
            loadingView.isHidden = isCancel ? true : false
            notFoundLabel.isHidden = isCancel ? true : false
            cleanerNameLabel.stop()
            if isCancel {
                cleanerNameLabel.text = cleanerList.rawValue
                cleanerNameLabel.font = UIFont(name: "Thunder-LC", size: 30)
            } else {
                cleanerNameLabel.font = UIFont(name: "Barlow-Medium", size: 20)
                loadingView.completeLoading(success: true)
            }
        case .returnScan:
            navigationController?.popViewController(animated: true)
        }
    }
    func configureUpdateModels() {
        if cleanerList == .events {
            delegate?.updateEvents(viewModels: duplicateEvents)
        }
        
        if cleanerList == .duplicateContact {
            delegate?.updateContacts(viewModels: duplicateContacts)
        }
        
        if cleanerList == .duplicatePhoto {
            delegate?.updatePhoto(viewModels: duplicatePhotosModel)
        }
        
        if cleanerList == .screenshot {
            delegate?.updateScreenshots(viewModels: duplicateScreenshots)
        }
    }
    
    func getViewModels() {
        if cleanerList == .events {
            searchManager.duplicateEvents{ [weak self] models in
                guard let sSelf = self else { return }
                sSelf.duplicateEvents = models
            }
            delegate?.updateEvents(viewModels: duplicateEvents)
            Cleaner.event = true
        }
        
        if cleanerList == .duplicateContact {
            searchManager.duplicateContacts{ [weak self] models in
                guard let sSelf = self else { return }
                sSelf.duplicateContacts = models
            }
            delegate?.updateContacts(viewModels: duplicateContacts)
            Cleaner.contact = true
        }
        
        if cleanerList == .screenshot {
            searchManager.fetchScreenshots{ [weak self] models in
                guard let sSelf = self else { return }
                sSelf.duplicateScreenshots = models
            }
            delegate?.updateScreenshots(viewModels: duplicateScreenshots)
            Cleaner.screenshot = true
        }
    }
}

enum ScanType {
    
    case begin
    case cancel
    case returnScan
}
