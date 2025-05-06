//
//  SettingsViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 21.10.22.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController {

    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var trialView: UIView!
    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var cleanIconImage: UIImageView!
    @IBOutlet weak var vpnIconImage: UIImageView!
    @IBOutlet weak var adblockIconImage: UIImageView!
    @IBOutlet weak var secretFolderIconImage: UIImageView!
    
    // -  Constraint
    @IBOutlet weak var statusViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var trialViewWidthConstraint: NSLayoutConstraint!
    
    // - DataSource
    private var dataSource: SettingsCollectionDataSource!
    
    // - Delegate
    // - Data
    private var models: [SettingsItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func premiumAction(_ sender: Any) {
//        let shopVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//        shopVC.modalPresentationStyle = .fullScreen
//        shopVC.delegate = self
//        //shopVC.delegate = delegate
//        present(shopVC, animated: true)
    }
}

// MARK: -
// MARK: - Delegate

//extension SettingsViewController: FirstShoppingBasketViewControllerDelegate {
//    func updateUI() {
//        vpnIconImage.isHidden = true
//        cleanIconImage.isHidden = true
//        adblockIconImage.isHidden = true
//        secretFolderIconImage.isHidden = true
//        trialView.isHidden = true
//        premiumView.isHidden = false
//        delegate?.updateUI()
//    }
//}
//
// MARK: -
// MARK: - Delegate

extension SettingsViewController: SettingsViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    func updateCollection() {
        if let cell = collectionView.cellForItem(at: IndexPath(row: 4, section: 0)) as? SettingsCollectionViewCell {
            cell.offFaceId()
        }
    }
    
    func showPassword(passVC: PasswordViewController) {
        let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateInitialViewController() as! PasswordViewController
        passwordVC.modalPresentationStyle = .overCurrentContext
        present(passVC, animated: true)
    }
    
    func showShop() {
//        let shopVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//        shopVC.modalPresentationStyle = .fullScreen
//        shopVC.delegate = self
//        present(shopVC, animated: true)
    }
    
    func showRequestId(idVC: IdentificationViewController) {
        present(idVC, animated: true)
    }
    
    func showGuide() {
        let guideVC = UIStoryboard(name: "Guide", bundle: nil).instantiateInitialViewController() as! GuideViewController
        Setting.guideisPresent = true
        guideVC.modalTransitionStyle = .crossDissolve
        guideVC.modalPresentationStyle = .overCurrentContext
        present(guideVC, animated: true)
    }
    
    func supportShow() {
        let vc = UIStoryboard(name: "SupportChat", bundle: nil).instantiateInitialViewController() as! SupportChatViewController
        
        navigationController?.pushViewController(vc, animated: true)
//        vc.modalTransitionStyle = .coverVertical
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
//        if MFMailComposeViewController.canSendMail() {
//            showMailVC()
//        } else {
//            showAlertController(title: "Support:", message: Email.email, handler: nil)
//        }
    }
    
    func chatsShow() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! ViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func termsShow() {
        let termsVC = UIStoryboard(name: "WebView", bundle: nil).instantiateInitialViewController() as! WebViewController
        termsVC.site = .terms
        termsVC.modalPresentationStyle = .fullScreen
        present(termsVC, animated: true)
    }
    
    func privacyShow() {
        let policyWebVC = UIStoryboard(name: "WebView", bundle: nil).instantiateInitialViewController() as! WebViewController
        policyWebVC.site = .policy
        policyWebVC.modalPresentationStyle = .fullScreen
        present(policyWebVC, animated: true)
    }
    
    func rateUsShow() {
        let rateUsVC = UIStoryboard(name: "RateUs", bundle: nil).instantiateInitialViewController() as! RateUsViewController
        rateUsVC.modalTransitionStyle = .crossDissolve
        rateUsVC.modalPresentationStyle = .overCurrentContext
        present(rateUsVC, animated: true)
    }
    
    func showMailVC() {
        let ContactUsViewController = MFMailComposeViewController()
        ContactUsViewController.mailComposeDelegate = self
        ContactUsViewController.setToRecipients([Email.email])
        present(ContactUsViewController, animated: true, completion: nil)
    }
    
    func showIdentification() {
        let idVC = UIStoryboard(name: "Identification", bundle: nil).instantiateInitialViewController() as! IdentificationViewController
        idVC.modalTransitionStyle = .crossDissolve
        idVC.modalPresentationStyle = .overCurrentContext
        present(idVC, animated: true)
    }
}
// MARK: -
// MARK: - Configure

private extension SettingsViewController {
    
    func configure() {
        configureModels()
        configureConstraint()
        checkPay()
    }
    
    func configureModels() {
        let profile = UserDefaultsManager().getProfile()
        SettingsItem.allCases.forEach { [weak self] item in
            guard let self else { return }
            if profile.isAdmin {
                self.models.append(item)
            } else {
                if item != .chats /*&& item != .subscription*/ {
                    self.models.append(item)
                }
            }
        }
        configureDataSource()
    }
    
    func configureDataSource() {
        
        dataSource = SettingsCollectionDataSource(collectionView: collectionView, models: models, delegate: self)
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.height < 580 {
            trialViewWidthConstraint.constant = UIScreen.main.bounds.width - 50
    }
        if UIScreen.main.bounds.height < 1000 {
            statusViewWidthConstraint.constant = UIScreen.main.bounds.width - 50
            collectionWidthConstraint.constant = UIScreen.main.bounds.size.width - 50
        }
    }
    
    
    
    func checkPay() {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
            trialView.isHidden = false
            premiumView.isHidden = true
            vpnIconImage.isHidden = false
            cleanIconImage.isHidden = false
            adblockIconImage.isHidden = false
            secretFolderIconImage.isHidden = false
        } else {
            vpnIconImage.isHidden = true
            cleanIconImage.isHidden = true
            adblockIconImage.isHidden = true
            secretFolderIconImage.isHidden = true
            trialView.isHidden = true
            premiumView.isHidden = true
        }
    }
    
    func showAlertController(title: String?, message: String?, handler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(ac, animated: true, completion: nil)
    }
}

