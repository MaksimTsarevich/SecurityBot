//
//  identificationViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 21.10.22.
//

import UIKit
import LocalAuthentication

class IdentificationViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var securityImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    // - Constraint
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    
    // - Delegate
    weak var delegate: IdentificationViewControllerDelegate?
    
    
    lazy var blurredView: UIView = {
        // 1. create container view
        let containerView = UIView()
        // 2. create custom blur view
        let blurEffect = UIBlurEffect(style: .light)
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.2)
        customBlurEffectView.frame = self.view.bounds
        // 3. create semi-transparent black view
        let dimmedView = UIView()
        dimmedView.backgroundColor = .black.withAlphaComponent(0.6)
        dimmedView.frame = self.view.bounds
        
        // 4. add both as subviews
        containerView.addSubview(customBlurEffectView)
        containerView.addSubview(dimmedView)
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configure()
        checkSecurity()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupView() {
        // 6. add blur view and send it to back
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        biometricsAuthentication()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

// MARK: -
// MARK: - Configure

private extension IdentificationViewController {
    
    func configure() {
        configureConstraint()
        configureLabel()
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.height < 1000 {
            viewWidthConstraint.constant = UIScreen.main.bounds.width - 50
        }
    }
    
    func checkSecurity() {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            let bottomPadding = window?.safeAreaInsets.bottom
            if bottomPadding == 0 {
                securityImage.image = UIImage(named: "TouchIDLogoImage")
                subTitleLabel.text = "Use Touch ID for quick access\nto your secret folder"
                subTitleLabel.addCharacterSpacing(kernValue: 0.5)
            } else {
                securityImage.image = UIImage(named: "FaceIDLogoImage")
                subTitleLabel.text = "Use Face ID for quick access\nto your secret folder"
                subTitleLabel.addCharacterSpacing(kernValue: 0.5)
            }
        } else {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            if bottomPadding == 0 {
                securityImage.image = UIImage(named: "TouchIDLogoImage")
            } else {
                securityImage.image = UIImage(named: "FaceIDLogoImage")
            }
        }
    }
    
    func configureLabel() {
        titleLabel.addCharacterSpacing(kernValue: 0.5)
        //subTitleLabel.addCharacterSpacing(kernValue: 0.5)
    }
    
    func biometricsAuthentication() {
        let context = LAContext()
        var error: NSError?
        let reason = "FACE ID"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason ){success, error in
                DispatchQueue.main.async {
                    guard success,error == nil else{
                        print("failed")
                        //self.showAlert(title: "Error", message: "repeate")
                        return
                    }
                    print("successful")
                    DispatchQueue.main.async {
                        UserDefaultsManager().setBoolValue(value: true, data: .faceIdAccess)
                        self.delegate?.updateId()
                        self.dismiss(animated: true)
                    }
                    
                }
            }
        } else {
            if let error {
                showAlert(title: "Нет доступа", message: "\(error.localizedDescription)")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Back", style: .cancel)
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
}

