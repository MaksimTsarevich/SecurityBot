//
//  SecondScreenViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 5.10.22.
//

import Foundation
import UIKit
import Lottie
import Photos
import Contacts
import EventKit

class SecondScreenViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var vpnLabel: UILabel!
    @IBOutlet weak var adblockLabel: UILabel!
    @IBOutlet weak var vpnButtonView: UIButton!
    @IBOutlet weak var adblockButtonView: UIButton!
    @IBOutlet weak var diskSpaceLabel: UILabel!
    @IBOutlet weak var securityStatusLabel: UILabel!
    @IBOutlet weak var ShieldImage: UIImageView!
    @IBOutlet weak var progressView: CircleProgressCustomView!
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet var typeViews: [UIView]!
    
    
    // - Constraint
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var shieldImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var diskSpaceLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var securityLabelToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageCenterConstraint: NSLayoutConstraint!
    
    
    // - Data
    private var model: ProfileModel?
    let store = EKEventStore()
    private var vpnIsOn = false
    private var adblockIsOn = false
    private var duplicatePhotosModel = [DuplicatePhotosVerticalCellCollectionViewModel]()
    private var duplicateScreenshots = [ScreenshotsCollectionViewCellModel]()
    private var duplicateContacts = [ContactMainViewModel]()
    private var duplicateEvents = [BigEventsCollectionViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureProfileButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureButtonAdblock()
        configureButtonVpn()
        configureSecurityStatus()
//        checkPay()
        configureRequest()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - Action
    @IBAction func spaceAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Graphs", bundle: nil).instantiateInitialViewController() as! GraphsViewController
        presentPanModal(vc)
    }
    
    
    @IBAction func vpnAction(_ sender: Any) {
        if !Vpn.vpnIsOn {
            let vpnSettingVC = UIStoryboard(name: "VpnSettings", bundle: nil).instantiateInitialViewController() as! VpnSettinsViewController
            navigationController?.pushViewController(vpnSettingVC, animated: true)
        } else {
            vpnButtonView.setTitle("OFF" , for: .normal)
            vpnButtonView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor
            vpnButtonView.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBAction func adblockAction(_ sender: Any) {
        if !Adblock.adblockIsOn {
            let adBlockSettingsVC = UIStoryboard(name: "AdblockSettings", bundle: nil).instantiateInitialViewController() as! AdblockSettingsViewController
            navigationController?.pushViewController(adBlockSettingsVC, animated: true)
        } else {
            adblockButtonView.setTitle("OFF", for: .normal)
            adblockButtonView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor
            adblockButtonView.setTitleColor(.white, for: .normal)
            Adblock.adblockIsOn = false
        }
    }
    
    @IBAction func AdBlockButton(_ sender: Any) {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if isActive {
            let adblockVC = UIStoryboard(name: "AdblockSettings", bundle: nil).instantiateInitialViewController() as! AdblockSettingsViewController
            adblockVC.delegate = self
            navigationController?.pushViewController(adblockVC, animated: true)
        } else {
            let adBlockVC = UIStoryboard(name: "Adblock", bundle: nil).instantiateInitialViewController() as! AdblockViewController
            adBlockVC.delegate = self
//            adBlockVC.delegateUpdate = self
            navigationController?.pushViewController(adBlockVC, animated: true)
        }
    }
    
    @IBAction func VpnButtonAction(_ sender: Any) {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if isActive {
            let vpnSettingVC = UIStoryboard(name: "VpnSettings", bundle: nil).instantiateInitialViewController() as! VpnSettinsViewController
            vpnSettingVC.delegate = self
            navigationController?.pushViewController(vpnSettingVC, animated: true)
        } else {
            let vpnVC = UIStoryboard(name: "Vpn", bundle: nil).instantiateInitialViewController() as! VpnViewController
            vpnVC.delegate = self
            navigationController?.pushViewController(vpnVC, animated: true)
        }
    }
    
    @IBAction func CleanerButtonAction(_ sender: Any) {
        let cleanerVC = UIStoryboard(name: "Cleaner", bundle: nil).instantiateInitialViewController() as! CleanerViewController
        cleanerVC.duplicateScreenshots = duplicateScreenshots
        cleanerVC.duplicateContacts = duplicateContacts
        cleanerVC.duplicateEvents = duplicateEvents
        cleanerVC.duplicatePhotosModel = duplicatePhotosModel
        cleanerVC.delegate = self
        navigationController?.pushViewController(cleanerVC, animated: true)
    }
    
    @IBAction func SecretFolderAction(_ sender: Any) {
//        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
//        if isActive {
            let secretVC = UIStoryboard(name: "SecretFolder", bundle: nil).instantiateInitialViewController() as! SecretFolderViewController
            navigationController?.pushViewController(secretVC, animated: true)
//        } else {
//            let premiumVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            premiumVC.modalPresentationStyle = .fullScreen
//            present(premiumVC, animated: true)
//        }
        
    }
    
    @IBAction func premiumAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileViewController
//        shopVC.modalPresentationStyle = .fullScreen
//        shopVC.delegate = self
        presentPanModal(vc)
//        present(vc, animated: true)
    }
    
    @IBAction func settingAction(_ sender: Any) {
        
        var vc = UIViewController()
        let story = UIStoryboard(name: "Settings", bundle:nil)
        vc = story.instantiateInitialViewController() as! SettingsViewController
        
        let navigation = UINavigationController(rootViewController: vc)
//        navigation.navigationBar.tintColor = UIColor(red: 0.286, green: 0.612, blue: 0.643, alpha: 1)
        navigation.navigationBar.isHidden = true
        
        
//        let settingVC = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! SettingsViewController
//        settingVC.delegate = self
//        let nc = UINavigationController(rootViewController: SettingsViewController())
        
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: true)
    }
    
}
// MARK: -
// MARK: - View Controllers Delegate

extension SecondScreenViewController: CleanerViewControllerDelegate, AdblockSettingsViewControllerDelegate, VpnDelegate {
    func vpnState(state: Bool) {
        vpnIsOn = state
        vpnButtonView.setTitle(!Vpn.vpnIsOn ? "OFF" : "ON", for: .normal)
        vpnButtonView.layer.backgroundColor = !Vpn.vpnIsOn ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor : UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        vpnButtonView.setTitleColor(!Vpn.vpnIsOn ? .white : .black, for: .normal)
//        configureMainImage()
        configureSecurityStatus()
    }
    
    func adblockState(state: Bool) {
        adblockIsOn = state
        adblockButtonView.setTitle(!state ? "OFF" : "ON", for: .normal)
        adblockButtonView.layer.backgroundColor = !state ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor : UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        adblockButtonView.setTitleColor(!state ? .white : .black, for: .normal)
//        configureMainImage()
        configureSecurityStatus()
    }
    
    func updateUI() {
        premiumButton.isHidden = true
    }
    
    func update(contactMainViewModel: [ContactMainViewModel], duplicatePhotosVerticalCellCollectionViewModel: [DuplicatePhotosVerticalCellCollectionViewModel], bigEventsCollectionViewModel: [BigEventsCollectionViewModel], screenshotsCollectionViewCellModel: [ScreenshotsCollectionViewCellModel]) {
        duplicateContacts = contactMainViewModel
        duplicatePhotosModel = duplicatePhotosVerticalCellCollectionViewModel
        duplicateEvents = bigEventsCollectionViewModel
        duplicateScreenshots = screenshotsCollectionViewCellModel
    }
    
}

// MARK: -
// MARK: - Configure

private extension SecondScreenViewController {
    
    func configure() {
//        configureProfileButton()
        configureShadow()
        configureSecurityStatus()
        configureProgressView()
        configureConstraint()
        configureLaunch()
//        checkPay()
        
    }
    
    func configureProfileButton() {
        let model = UserDefaultsManager().getProfile()
        premiumButton.layer.cornerRadius = premiumButton.bounds.height / 2
        premiumButton.layer.borderWidth = 2
        if model.isAdmin {
            premiumButton.layer.borderColor = UIColor.red.cgColor
        } else {
            premiumButton.layer.borderColor = AppPalette.backgroundMain2.cgColor
        }
        let simbol = model.login.first?.uppercased()
        premiumButton.setTitle(simbol, for: .normal)
        if !model.color.isEmpty {
            premiumButton.backgroundColor = AppPalette.color(fromHex: model.color)
            premiumButton.setTitleColor(textColorForBackground(AppPalette.color(fromHex: model.color)), for: .normal)
        }
    }
    
    func configureRequest() {
        PHPhotoLibrary.requestAuthorization({ _ in
        })
        CNContactStore().requestAccess(for: .contacts) { _,_  in
        }
        
        if #available(iOS 17.0, *) {
            store.requestFullAccessToEvents { (granted, error) in
                
            }
        } else {
            store.requestAccess(to: .event) { (granted, error) in
               
            }
        }
    }
    
    func configureShadow() {
        typeViews.forEach { view in
            view.layer.shadowColor = UIColor.lightGray.cgColor
            view.layer.shadowOpacity = 1
            view.layer.shadowRadius = 6
            view.layer.shadowOffset = CGSize(width: 0, height: 4)
            view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
            view.layer.masksToBounds = false
        }
    }
    
    func checkPay() {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
            premiumButton.isHidden = false
        } else {
            premiumButton.isHidden = true
        }
    }
    
    func configureLaunch() {
        if UserDefaultsManager().getBoolValue(data: .onboarding) == true {
            print("not first launch")
        } else {
            print("First launch, setting NSUserDefault.")
            let onboardingVC = UIStoryboard(name: "FirstScreen", bundle: nil).instantiateInitialViewController() as! FirstScreenViewController
            onboardingVC.modalTransitionStyle = .crossDissolve
            onboardingVC.modalPresentationStyle = .fullScreen
            present(onboardingVC, animated: true)
        }
    }
    
    func configureButtonVpn() {
        vpnButtonView.setTitle(!Vpn.vpnIsOn ? "OFF" : "ON", for: .normal)
        vpnButtonView.layer.backgroundColor = !Vpn.vpnIsOn ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor : UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        vpnButtonView.setTitleColor(!Vpn.vpnIsOn ? .white : .black, for: .normal)
        //vpnIsOn = !vpnIsOn
    }
    
    func configureButtonAdblock() {
        adblockIsOn = UserDefaultsManager().getBoolValue(data: .adBlock)
        adblockButtonView.setTitle(!adblockIsOn ? "OFF" : "ON", for: .normal)
        adblockButtonView.layer.backgroundColor = !adblockIsOn ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor : UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        adblockButtonView.setTitleColor(!adblockIsOn ? .white : .black, for: .normal)
        //adblockIsOn = !adblockIsOn
    }
    
    func configureSecurityStatus() {
        let fullString = NSMutableAttributedString(string: "")
        let image1Attachment = NSTextAttachment()
        if vpnIsOn && adblockIsOn {
            image1Attachment.image = UIImage(named: "HighIndicator")
        } else if vpnIsOn || adblockIsOn {
            image1Attachment.image = UIImage(named: "MediumIndicator")
        } else {
            image1Attachment.image = UIImage(named: "LowIndicator")
        }
        image1Attachment.bounds = CGRect(x: 0, y: securityStatusLabel.frame.height / 6, width: securityStatusLabel.frame.height / 4, height: securityStatusLabel.frame.height / 4)
        
        let image1String = NSAttributedString(attachment: image1Attachment)
        fullString.append(image1String)
        if vpnIsOn && adblockIsOn {
            fullString.append(NSAttributedString(string: "  HIGH"))
        } else if vpnIsOn || adblockIsOn {
            fullString.append(NSAttributedString(string: "  MEDIUM"))
        } else {
            fullString.append(NSAttributedString(string: "  LOW"))
        }
        securityStatusLabel.attributedText = fullString
        securityStatusLabel.textColor = .white
        securityStatusLabel.font = UIFont(name: "Barlow-Bold", size: 14)
    }
    
    func configureProgressView() {
        let totalMemory = UIDevice.current.totalDiskSpaceInBytes
        let usedMemory = UIDevice.current.usedDiskSpaceInBytes
        let finalMemory = (usedMemory * 100) / totalMemory
        progressLabel.text = "\(finalMemory)%\nUSED"
        progressView.progress = Double(finalMemory) / 100.0
        progressView.trackFillColor = UIColor(red: 0.896, green: 0.716, blue: 0.254, alpha: 1)
        progressView.layer.cornerRadius = progressView.frame.width / 2
        progressView.trackBackgroundColor = UIColor(red: 0.312, green: 0.312, blue: 0.312, alpha: 1)
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 580 {
            stackViewHeightConstraint.constant = 300
            stackButtonHeightConstraint.constant = 160
            stackViewWidthConstraint.constant = 270
            diskSpaceLabelTopConstraint.constant = 7
            securityLabelToBottomConstraint.constant = 5
        }
        
        if UIScreen.main.bounds.size.height > 580 && UIScreen.main.bounds.size.height < 680 {
            stackViewHeightConstraint.constant = 370
        }
        
        if UIScreen.main.bounds.height > 1000 {
            shieldImageWidthConstraint.constant = 600
        }
    }
    
    func textColorForBackground(_ backgroundColor: UIColor) -> UIColor {
        // Получаем компоненты цвета фона
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Рассчитываем яркость цвета фона
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        // Определяем, какой текст будет лучше виден на этом фоне
        if brightness < 0.5 {
            return UIColor.white // Фон темный, используем белый текст
        } else {
            return UIColor.black // Фон светлый, используем черный текст
        }
    }
    
//    func configureMainImage() {
//        if vpnIsOn && adblockIsOn {
//            self.ShieldImage.image = UIImage(named: "HighSecurityImage")
//            messageImage.isHidden = true
//            messageLabel.isHidden = true
//        } else if vpnIsOn || adblockIsOn {
//             self.ShieldImage.image = UIImage(named: "MediumSecurityImage")
//             messageImage.isHidden = false
//             messageLabel.isHidden = false
//         } else {
//            self.ShieldImage.image = UIImage(named: "LowSecurityImage")
//            messageImage.isHidden = false
//            messageLabel.isHidden = false
//        }
//    }
}
