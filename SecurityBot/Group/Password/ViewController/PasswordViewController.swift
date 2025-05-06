//
//  PasswordViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 20.10.22.
//

import UIKit
import LocalAuthentication

class PasswordViewController: UIViewController {
    
    // - UI
    @IBOutlet var securityView: [UIView]!
    @IBOutlet weak var securityImage: UIImageView!
    @IBOutlet weak var securityLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var biometricsButton: UIButton!
    @IBOutlet weak var biometricsView: UIView!
    
    // - Constraint
    @IBOutlet weak var stackViewToButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonToSafeareaConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    
    
    // - Data
    private var passwordIsCreate = false
    var type: passwordType = .create
    private var password: [String] = []
    private var password2: [String] = []//[1,1,1,1]
    var confirm = false
    
    // - Delegate
    weak var delegate: PasswordViewControllerDelegate?
    
    // - Blur
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
        passwordIsCreate = UserDefaultsManager().getBoolValue(data: .passcodeCreate)
        setupView()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - Action
    @IBAction func pinAction(_ sender: UIButton) {
        enteredPassword(sender: sender)
        securyPassword(isRemove: false)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        if password.isEmpty == false{
            password.removeLast()
            print(password)
        }
        securyPassword(isRemove: true)
    }
    
    
    @IBAction func identificationAction(_ sender: Any) {
        biometricsAuthentication()
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func setupView() {
        // 6. add blur view and send it to back
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
    }
    
}

// MARK: -
// MARK: - Configure

private extension PasswordViewController {
    
    func configure() {
        configurePasswordType()
        configureSecureId()
        configureConstraint()
        configureLabel()
        configureBiometricsAuth()
    }
    
    func configurePasswordType() {
        password2 = UserDefaultsManager().getArray(data: .passcode)
        if !passwordIsCreate {
            biometricsView.isHidden = true
            biometricsButton.isHidden = true
            lockImage.isHidden = true
            titleLabel.text = "CREATE NEW\nPASSCODE"
        } else {
            biometricsView.isHidden = false
            biometricsButton.isHidden = false
            lockImage.isHidden = false
            titleLabel.text = "ENTER PASSCODE"
        }
    }
    
    func configureSecureId() {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            let bottomPadding = window?.safeAreaInsets.bottom
            if bottomPadding == 0 {
                securityImage.image = UIImage(named: "TouchIdImage")
                securityLabel.text = "TOUCH ID"
            } else {
                securityImage.image = UIImage(named: "FaceIdImage")
                securityLabel.text = "FACE ID"
            }
        } else {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            if bottomPadding == 0 {
                securityImage.image = UIImage(named: "TouchIdImage")
                securityLabel.text = "TOUCH ID"
            } else {
                securityImage.image = UIImage(named: "FaceIdImage")
                securityLabel.text = "FACE ID"
            }
        }
    }
    
    func enteredPassword(sender: UIButton){
        switch sender.tag{
        case 0:
            if password.count < 4{
                password.append("0")
                print(password)
            }
        case 1:
            if password.count < 4{
                password.append("1")
                print(password)
            }
        case 2:
            if password.count < 4{
                password.append("2")
                print(password)
            }
        case 3:
            if password.count < 4{
                password.append("3")
                print(password)
            }
        case 4:
            if password.count < 4{
                password.append("4")
                print(password)
            }
        case 5:
            if password.count < 4{
                password.append("5")
                print(password)
            }
        case 6:
            if password.count < 4{
                password.append("6")
                print(password)
            }
        case 7:
            if password.count < 4{
                password.append("7")
                print(password)
            }
        case 8:
            if password.count < 4{
                password.append("8")
                print(password)
            }
        case 9:
            if password.count < 4{
                password.append("9")
                print(password)
            }
        default:
            print("ssss")
        }
        if passwordIsCreate {
            if !confirm{
                configureEnterPasscode()
            } else {
                configureEnterConfirmPasscode()
            }
        } else {
            switch type {
            case .create:
                configureCreatePasscode()
            case .confirm:
                configureConfirmPasscode()
            }
        }
    }
    
    func configureCreatePasscode() {
        if password.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.type = .confirm
                self.password2 = self.password
                self.password = []
                self.securityView.forEach{ view in
                    view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
                }
                self.titleLabel.text = "CONFIRM PASSCODE"
                //self.type = .confirm
            }
        }
    }
    
    func configureConfirmPasscode() {
        if password.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.password == self.password2 {
                    UserDefaultsManager().setBoolValue(value: true, data: .passcodeCreate)
                    UserDefaultsManager().setArray(value: self.password2, data: .passcode)
                    SecretFolder.lock = true
                    self.delegate?.lockStatus()
                    self.delegate?.passwordEnable()
                    self.dismiss(animated: true)
                } else {
                    SecretFolder.lock = false
                    self.password = []
                    self.securityView.forEach{ view in
                        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
                    }
                }
            }
        }
    }
    
    func configureEnterPasscode() {
        //password2 = UserDefaultsManager().getArray(data: .passcode)
        if password.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.password == self.password2 {
                    SecretFolder.lock = false
                    self.delegate?.lockStatus()
                    self.dismiss(animated: true)
                } else {
                    SecretFolder.lock = false
                    self.password = []
                    self.securityView.forEach{ view in
                        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
                    }
                }
            }
        }
    }
    
    func configureEnterConfirmPasscode() {
        //password2 = UserDefaultsManager().getArray(data: .passcode)
        if password.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.password == self.password2 {
                    //SecretFolder.lock = false
                    self.delegate?.lockStatus()
                    self.dismiss(animated: true)
                } else {
                    //SecretFolder.lock = false
                    self.password = []
                    self.securityView.forEach{ view in
                        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
                    }
                }
            }
        }
    }
    
    func securyPassword(isRemove: Bool){
        UIView.animate(withDuration: 0.2, animations: {
            if isRemove == false {
                self.securityView[self.password.count - 1].backgroundColor = .white
            } else {
                self.securityView[self.password.count].backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
            }
        })
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
                        SecretFolder.lock = false
                        self.delegate?.lockStatus()
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
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 580 {
            stackViewToTopConstraint.constant = 60
            stackViewToButtonConstraint.constant = 10
            buttonToSafeareaConstraint.constant = 5
        }
        
        if UIScreen.main.bounds.size.height > 1000 {
            stackViewToTopConstraint.constant = UIScreen.main.bounds.size.height / 4
            stackViewToButtonConstraint.constant = UIScreen.main.bounds.size.height / 5
        } else {
            buttonWidth.constant = UIScreen.main.bounds.width - 50
            stackViewWidthConstraint.constant = UIScreen.main.bounds.width - 50
        }
    }
    
    func configureLabel() {
        titleLabel.addCharacterSpacing(kernValue: 1.21)
    }
    
    func configureBiometricsAuth() {
        let biometricsEnable = UserDefaultsManager().getBoolValue(data: .biometricsEnable)
        if biometricsEnable {
            biometricsAuthentication()
        }
    }
}

enum passwordType {
    case create
    case confirm
}
