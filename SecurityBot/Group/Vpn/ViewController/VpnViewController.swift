//
//  VpnViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.10.22.
//

import Foundation
import UIKit

class VpnViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var subtitle1Label: UILabel!
    @IBOutlet weak var subtitle2Label: UILabel!
    
    // - Constraint
    @IBOutlet weak var buttonToSafeareaConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonToStackConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    
    // - Delegate
    weak var delegate: VpnDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - Action
    @IBAction func BackButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueButtonAction(_ sender: Any) {
//        let shopVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//        shopVC.modalPresentationStyle = .fullScreen
//        shopVC.delegate = self
//        present(shopVC, animated: true)
    }
    
    @IBAction func skipAction(_ sender: Any) {
        let vpnSettingVC = UIStoryboard(name: "VpnSettings", bundle: nil).instantiateInitialViewController() as! VpnSettinsViewController
        vpnSettingVC.delegate = delegate
        navigationController?.pushViewController(vpnSettingVC, animated: true)
    }
}


//// MARK: -
//// MARK: - Delegate
//
//extension VpnViewController: FirstShoppingBasketViewControllerDelegate {
//    func updateUI() {
//        let vpnSettingVC = UIStoryboard(name: "VpnSettings", bundle: nil).instantiateInitialViewController() as! VpnSettinsViewController
//        vpnSettingVC.delegate = delegate
//        navigationController?.pushViewController(vpnSettingVC, animated: true)
//    }
//}
// MARK: -
// MARK: - Configure

private extension VpnViewController {
    
    func configure() {
        configureConstraint()
        configureButton()
        configureLabel()
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 580 {
            buttonToSafeareaConstraint.constant = 10
            buttonToStackConstraint.constant = 20
            firstViewHeightConstraint.constant = 100
            secondViewHeightConstraint.constant = 100
            stackViewWidthConstraint.constant = 300
        }
        
        if UIScreen.main.bounds.size.height < 670 {
            buttonToSafeareaConstraint.constant = 10
            buttonToStackConstraint.constant = 20
        }
    }
    
    func configureButton() {
        continueButton.layer.shadowColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 0.3).cgColor
        continueButton.layer.shadowOpacity = 1
        continueButton.layer.shadowRadius = 20
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        continueButton.layer.shadowPath = UIBezierPath(rect: continueButton.bounds).cgPath
        continueButton.layer.masksToBounds = false
    }
    
    func configureLabel() {
        subtitle1Label.addCharacterSpacing(kernValue: 0.98)
        subtitle2Label.addCharacterSpacing(kernValue: 0.98)
    }
}

