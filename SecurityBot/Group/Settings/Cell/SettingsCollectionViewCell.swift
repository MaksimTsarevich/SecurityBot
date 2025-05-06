//
//  SettingsCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 21.10.22.
//

import UIKit

class SettingsCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var spacingView: UIView!
    @IBOutlet weak var nextImage: UIImageView!
    @IBOutlet weak var switchSelectView: UIView!
    @IBOutlet weak var switchView: UIView!
    
    // - Constraint
    @IBOutlet weak var switchConstraint: NSLayoutConstraint!
    
    // - Delegate
    weak var delegate: SettingsViewControllerDelegate?
    
    // - Data
    private var selectPassword = false
    private var selectFaceId = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: -
// MARK: - Set

extension SettingsCollectionViewCell {
    
    func set(items: SettingsItem) {
        titleLabel.text = items.rawValue
        itemImage.image = items.icon
        
        if items == .passcode {
            nextImage.isHidden = true
            switchView.isHidden = false
            switchPasswordAction()
            configurePasswordEnable()
        } else if items == .faceId {
            configureBiometricsEnable()
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.first
                let bottomPadding = window?.safeAreaInsets.bottom
                if bottomPadding == 0 {
                    titleLabel.text = "Use Touch ID"
                    itemImage.image = UIImage(named: "TouchIdItem")
                } else {
                    titleLabel.text = items.rawValue
                    itemImage.image = items.icon
                }
            } else {
                let window = UIApplication.shared.keyWindow
                let bottomPadding = window?.safeAreaInsets.bottom
                if bottomPadding == 0 {
                    titleLabel.text = "Use Touch ID"
                    itemImage.image = UIImage(named: "TouchIdItem")
                } else {
                    titleLabel.text = items.rawValue
                    itemImage.image = items.icon
                }
            }
            nextImage.isHidden = true
            switchView.isHidden = false
            switchFaceIdAction()
        }
    }
    
    @objc func somePasswordAction() {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
            delegate?.showShop()
        } else {
            let passwordIsCreate = UserDefaultsManager().getBoolValue(data: .passcodeCreate)
            if !passwordIsCreate {
                let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateInitialViewController() as! PasswordViewController
                passwordVC.modalPresentationStyle = .overCurrentContext
                passwordVC.delegate = self
                delegate?.showPassword(passVC: passwordVC)
            } else {
                if selectPassword {
                    let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateInitialViewController() as! PasswordViewController
                    passwordVC.modalPresentationStyle = .overCurrentContext
                    passwordVC.delegate = self
                    delegate?.showPassword(passVC: passwordVC)
                    
                } else {
                    UIView.animate(withDuration: 0.2){
                        self.switchConstraint.constant = self.selectPassword ? 5 : (self.switchView.frame.width - 23)
                    }
                    UIView.animate(withDuration: 0.3, delay: 0, animations: {
                        
                        self.switchSelectView.backgroundColor = self.selectPassword ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
                        self.selectPassword = !self.selectPassword
                    })
                    UserDefaultsManager().setBoolValue(value: selectPassword, data: .passwordEnable)
                }
            }
        }
    }
    
    @objc func someFaceIdAction() {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
            delegate?.showShop()
        } else {
            let faceId = UserDefaultsManager().getBoolValue(data: .faceIdAccess)
            let selectPassword = UserDefaultsManager().getBoolValue(data: .passwordEnable)
            if selectPassword {
                if !faceId {
                    let idVC = UIStoryboard(name: "Identification", bundle: nil).instantiateInitialViewController() as! IdentificationViewController
                    idVC.modalPresentationStyle = .overCurrentContext
                    idVC.modalTransitionStyle = .crossDissolve
                    idVC.delegate = self
                    delegate?.showRequestId(idVC: idVC)
                } else {
                    UIView.animate(withDuration: 0.2){
                        self.switchConstraint.constant = self.selectFaceId ? 5 : (self.switchView.frame.width - 23)
                    }
                    UIView.animate(withDuration: 0.3, delay: 0, animations: {
                        
                        self.switchSelectView.backgroundColor = self.selectFaceId ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
                        self.selectFaceId = !self.selectFaceId
                    })
                    UserDefaultsManager().setBoolValue(value: selectFaceId, data: .biometricsEnable)
                }
            }
        }
    }
    
    func switchPasswordAction() {
        selectPassword = UserDefaultsManager().getBoolValue(data: .passwordEnable)
        let tapPasswordView = UITapGestureRecognizer(target: self, action: #selector(self.somePasswordAction))
        switchView.addGestureRecognizer(tapPasswordView)
        switchView.isUserInteractionEnabled = true
    }
    
    func switchFaceIdAction() {
        selectFaceId = UserDefaultsManager().getBoolValue(data: .biometricsEnable)
        let tapFaceIdView = UITapGestureRecognizer(target: self, action: #selector(self.someFaceIdAction))
        switchView.addGestureRecognizer(tapFaceIdView)
        switchView.isUserInteractionEnabled = true
    }
    
    func offFaceId() {
        UIView.animate(withDuration: 0.2){
            self.switchConstraint.constant = 5
        }
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.switchSelectView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.65)
        })
    }
}

// MARK: -
// MARK: - Delegate

extension SettingsCollectionViewCell: IdentificationViewControllerDelegate, PasswordViewControllerDelegate {
    func passwordEnable() {
        UIView.animate(withDuration: 0.2){
            self.switchConstraint.constant = self.selectPassword ? 5 : (self.switchView.frame.width - 23)
        }
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.switchSelectView.backgroundColor = self.selectPassword ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
            self.selectPassword = true
        })
    }
    
    func lockStatus() {
        UIView.animate(withDuration: 0.2){
            self.switchConstraint.constant = 5
        }
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.switchSelectView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.65)
            self.selectPassword = false
        })
        UserDefaultsManager().setBoolValue(value: selectPassword, data: .passwordEnable)
        
        UserDefaultsManager().setBoolValue(value: false, data: .biometricsEnable)
        
        delegate?.updateCollection()
        
    }
    
    func updateId() {
        someFaceIdAction()
    }
}

// MARK: -
// MARK: - Configure

extension SettingsCollectionViewCell {
    
    func configurePasswordEnable() {
        selectPassword = UserDefaultsManager().getBoolValue(data: .passwordEnable)
        self.switchConstraint.constant = !selectPassword ? 5 : (self.switchView.frame.width - 23)
        self.switchSelectView.backgroundColor = !selectPassword ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
    }
    
    func configureBiometricsEnable() {
        selectFaceId = UserDefaultsManager().getBoolValue(data: .biometricsEnable)
        self.switchConstraint.constant = !selectFaceId ? 5 : (self.switchView.frame.width - 23)
        self.switchSelectView.backgroundColor = !selectFaceId ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.65) : UIColor(red: 0.101, green: 0.896, blue: 0.514, alpha: 1)
    }
    
    func configureDisableBiometrics() {
        UIView.animate(withDuration: 0.2){
            self.switchConstraint.constant = 5
        }
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.switchSelectView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.65)
            self.selectFaceId = false
        })
    }
}
