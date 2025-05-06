//
//  AdblockSettingsViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.10.22.
//

import Foundation
import UIKit

class AdblockSettingsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // - UI
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var propertyLabel: UILabel!
    @IBOutlet weak var activeImage: UIImageView!
    @IBOutlet var switchViews: [UIView]!
    @IBOutlet weak var switchView: UIView!
    @IBOutlet weak var pointSwitchView: UIView!
    @IBOutlet weak var onLabel: UILabel!
    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var switchAdsView: UIView!
    @IBOutlet weak var switchTrackingScriptsView: UIView!
    @IBOutlet weak var switchSocialButtonsView: UIView!
    @IBOutlet weak var pointAdsView: UIView!
    @IBOutlet weak var pointScriptsView: UIView!
    @IBOutlet weak var pointSocialView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // - Constraint
    @IBOutlet weak var switchToSafeareaConstraint: NSLayoutConstraint!
    @IBOutlet weak var switchToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundViewWidthConstraint: NSLayoutConstraint!
    
    // - Delegate
    weak var delegate: AdblockSettingsViewControllerDelegate?
    
    // - Data
    private var isOn: Bool = false
    private var blockAds: Bool = false
    private var stopScripts: Bool = false
    private var blockButtons: Bool = false
    
    // Constraints
    @IBOutlet weak var pointSwitchContraint: NSLayoutConstraint!
    @IBOutlet weak var pointAdsConstraint: NSLayoutConstraint!
    @IBOutlet weak var pointScriptsConstraint: NSLayoutConstraint!
    @IBOutlet weak var pointSocialConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // - Action
    @IBAction func BackToAdblockAction(_ sender: Any) {
//        navigationController?.popToRootViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    @IBAction func guideAction(_ sender: Any) {
        let guideVC = UIStoryboard(name: "Guide", bundle: nil).instantiateInitialViewController() as! GuideViewController
        Setting.guideisPresent = false
        navigationController?.pushViewController(guideVC, animated: true)
    }
    
    
    
    // - Animate
    @objc func someAction() {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
//            let shopVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            shopVC.modalPresentationStyle = .fullScreen
//            shopVC.delegate = delegateUpdate
//            present(shopVC, animated: true)
        } else {
            UIView.animate(withDuration: 0.6) {
                self.pointSwitchContraint.constant = self.isOn ? 8 : (self.switchView.frame.width - 48)
                self.view.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: 0.3) {
                if !self.isOn {
                    self.onLabel.alpha = 0
                } else {
                    self.offLabel.alpha = 0
                }
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    if !self.isOn {
                        self.onLabel.alpha = 1
                    } else {
                        self.offLabel.alpha = 1
                    }
                }
            }
            UIView.animate(withDuration: 0.6, delay: 0, animations: {
                self.switchView.backgroundColor = self.isOn ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.25) : UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.25)
                self.pointSwitchView.backgroundColor = self.isOn ? UIColor(red: 1, green: 1, blue: 1, alpha: 1) : UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 1)
                self.switchView.layer.shadowColor = self.isOn ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).cgColor : UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.3).cgColor
                self.propertyLabel.isHidden = self.isOn ? false : true
                self.activeImage.image =  UIImage(named: self.isOn ? "ErrorIcon" : "SuccessfulIcon")
                self.activeLabel.text = self.isOn ? "ADBLOCK IS NOT ACTIVATED" : "ADBLOCK ACTIVATED"
                self.isOn = !self.isOn
            })
            UserDefaultsManager().setBoolValue(value: self.isOn, data: .adBlock)
            delegate?.adblockState(state: self.isOn)
        }
    }
    
    
    @objc func someAdsSwitch() {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
//            let shopVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            shopVC.modalPresentationStyle = .fullScreen
//            shopVC.delegate = delegateUpdate
//            present(shopVC, animated: true)
        } else {
            //blockAds = UserDefaultsManager().getBoolValue(data: .blockAds)
            UIView.animate(withDuration: 0.2){
                self.pointAdsConstraint.constant = self.blockAds ? 5 : (self.switchAdsView.frame.width - 23)
                self.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                
                self.pointAdsView.backgroundColor = self.blockAds ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
                self.blockAds = !self.blockAds
            })
            UserDefaultsManager().setBoolValue(value: blockAds, data: .blockAds)
        }
    }
    
    @objc func someSocialSwitch() {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
//            let shopVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            shopVC.modalPresentationStyle = .fullScreen
//            shopVC.delegate = delegateUpdate
//            present(shopVC, animated: true)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                UIView.animate(withDuration: 0.3){
                    self.pointSocialConstraint.constant = self.blockButtons ? 5 : (self.switchAdsView.frame.width - 23)
                    self.view.layoutIfNeeded()
                }
                self.pointSocialView.backgroundColor = self.blockButtons ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
                self.blockButtons = !self.blockButtons
            })
            UserDefaultsManager().setBoolValue(value: blockButtons, data: .blockSocialButtons)
        }
    }
    
    @objc func someScriptsSwitch() {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
//            let shopVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            shopVC.modalPresentationStyle = .fullScreen
//            shopVC.delegate = delegateUpdate
//            present(shopVC, animated: true)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                UIView.animate(withDuration: 0.3) {
                    self.pointScriptsConstraint.constant = self.stopScripts ? 5 : (self.switchAdsView.frame.width - 23)
                    self.view.layoutIfNeeded()
                }
                self.pointScriptsView.backgroundColor = self.stopScripts ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
                self.stopScripts = !self.stopScripts
            })
            UserDefaultsManager().setBoolValue(value: stopScripts, data: .blockTrackers)
        }
    }
}


// - MARK: -
// - MARK: - Configure
private extension AdblockSettingsViewController {
    func configure() {
        configureBackgroundView()
        configureSwitchTap()
        configureSmallSwitch()
        configureSwipeSwitch()
        configureConstraint()
        configureSwitch()
        configureBlockAds()
        configureSocial()
        configureScript()
        configureAdblock()
        configureLabel()
    }
    
    func configureBackgroundView() {
        backgroundView.layer.cornerRadius = 17
        backgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    func configureSwitchTap() {
        isOn = UserDefaultsManager().getBoolValue(data: .adBlock)
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.someAction))
        switchView.addGestureRecognizer(tapView)
        switchView.isUserInteractionEnabled = true
        self.offLabel.alpha = 0
    }
    
    func configureSwipeSwitch() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeFunc(gesture:)))
        swipeRight.direction = .right
        self.switchView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeFunc(gesture:)))
        swipeLeft.direction = .left
        self.switchView.addGestureRecognizer(swipeLeft)
    }
    
    func configureSmallSwitch() {
        blockAds = UserDefaultsManager().getBoolValue(data: .blockAds)
        let tapAdsView = UITapGestureRecognizer(target: self, action: #selector(self.someAdsSwitch))
        switchAdsView.addGestureRecognizer(tapAdsView)
        switchAdsView.isUserInteractionEnabled = true
        
        blockButtons = UserDefaultsManager().getBoolValue(data: .blockSocialButtons)
        let tapSocialView = UITapGestureRecognizer(target: self, action: #selector(self.someSocialSwitch))
        switchSocialButtonsView.addGestureRecognizer(tapSocialView)
        switchSocialButtonsView.isUserInteractionEnabled = true
        
        stopScripts = UserDefaultsManager().getBoolValue(data: .blockTrackers)
        let tapScriptsView = UITapGestureRecognizer(target: self, action: #selector(self.someScriptsSwitch))
        switchTrackingScriptsView.addGestureRecognizer(tapScriptsView)
        switchTrackingScriptsView.isUserInteractionEnabled = true
    }
    
    @objc func swipeFunc(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            print("right")
            someAction()
        } else if gesture.direction == .left {
            someAction()
        }
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 580 {
            switchToSafeareaConstraint.constant = 10
            switchToViewConstraint.constant = 10
            viewWidthConstraint.constant = 300
            labelBottomConstraint.constant = 5
            labelTopConstraint.constant = 5
            activeLabelTopConstraint.constant = 5
            viewHeightConstraint.constant = 267
            //backgroundViewWidthConstraint.constant = UIScreen.main.bounds.width
        }
        
        if UIScreen.main.bounds.size.height < 670 {
            switchToSafeareaConstraint.constant = 10
            switchToViewConstraint.constant = 10
            //backgroundViewWidthConstraint.constant = UIScreen.main.bounds.width
        }
        
        if UIScreen.main.bounds.size.height > 1000 {
            labelBottomConstraint.constant = 200
            if UIScreen.main.bounds.size.height > 1150 {
                labelBottomConstraint.constant = 300
            }
            //backButton.setImage(UIImage(named: "BackIcon"), for: .normal)
        }
    }
    
    func configureSwitch() {
        switchView.layer.shadowColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).cgColor
        switchView.layer.shadowOpacity = 1
        switchView.layer.shadowRadius = 20
        switchView.layer.shadowOffset = CGSize(width: 0, height: 0)
        switchView.layer.shadowPath = UIBezierPath(rect: switchView.bounds).cgPath
        switchView.layer.masksToBounds = false
    }
    
    func configureBlockAds() {
        blockAds = UserDefaultsManager().getBoolValue(data: .blockAds)
        self.pointAdsConstraint.constant = !blockAds ? 5 : (self.switchAdsView.frame.width - 23)
        self.pointAdsView.backgroundColor = !blockAds ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
    }
    
    func configureSocial() {
        blockButtons = UserDefaultsManager().getBoolValue(data: .blockSocialButtons)
        self.pointSocialConstraint.constant = !blockButtons ? 5 : (self.switchAdsView.frame.width - 23)
        self.pointSocialView.backgroundColor = !blockButtons ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
    }
    
    func configureScript() {
        stopScripts = UserDefaultsManager().getBoolValue(data: .blockTrackers)
        self.pointScriptsConstraint.constant = !stopScripts ? 5 : (self.switchAdsView.frame.width - 23)
        self.pointScriptsView.backgroundColor = !stopScripts ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
    }
    
    func configureAdblock() {
        isOn = UserDefaultsManager().getBoolValue(data: .adBlock)
        self.pointSwitchContraint.constant = !isOn ? 8 : (self.switchView.frame.width - 48)
        if isOn {
            onLabel.alpha = 0
            offLabel.alpha = 1
        } else {
            onLabel.alpha = 1
            offLabel.alpha = 0
        }
        //Adblock.adblockIsOn = !isOn ? false : true
        self.switchView.backgroundColor = !isOn ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.25) : UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.25)
        self.pointSwitchView.backgroundColor = !isOn ? UIColor(red: 1, green: 1, blue: 1, alpha: 1) : UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 1)
        self.switchView.layer.shadowColor = !isOn ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).cgColor : UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.3).cgColor
        self.propertyLabel.isHidden = !isOn ? false : true
        self.activeImage.image =  UIImage(named: !isOn ? "ErrorIcon" : "SuccessfulIcon")
        self.activeLabel.text = !isOn ? "ADBLOCK IS NOT ACTIVATED" : "ADBLOCK ACTIVATED"
    }
    
    func configureLabel() {
        titleLabel.addCharacterSpacing(kernValue: 1.21)
    }
}

