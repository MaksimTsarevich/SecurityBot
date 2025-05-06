//
//  AdblockViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 9.10.22.
//

import Foundation
import UIKit


class AdblockViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitle1Label: UILabel!
    @IBOutlet weak var subtitle2Label: UILabel!
    
    // - Constraint
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonToStackConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonToSafeareaConstraint: NSLayoutConstraint!
    
    // - Delegate
    weak var delegate: AdblockSettingsViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - Action
    
    @IBAction func BackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ContinueButtonAction(_ sender: Any) {
//        let shopVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//        shopVC.modalPresentationStyle = .fullScreen
//        shopVC.delegate = self
//        present(shopVC, animated: true)
    }
    
    @IBAction func skipAction(_ sender: Any) {
        let adBlockSettingsVC = UIStoryboard(name: "AdblockSettings", bundle: nil).instantiateInitialViewController() as! AdblockSettingsViewController
        adBlockSettingsVC.delegate = delegate
//        adBlockSettingsVC.delegateUpdate = delegateUpdate
        navigationController?.pushViewController(adBlockSettingsVC, animated: true)
    }
    
    
}

// MARK: -
// MARK: - Delagate
//
//extension AdblockViewController: FirstShoppingBasketViewControllerDelegate {
//    func updateUI() {
//        let adBlockSettingsVC = UIStoryboard(name: "AdblockSettings", bundle: nil).instantiateInitialViewController() as! AdblockSettingsViewController
//        adBlockSettingsVC.delegate = delegate
//        navigationController?.pushViewController(adBlockSettingsVC, animated: true)
//        delegateUpdate?.updateUI()
//    }
//}

// MARK: -
// MARK: - Configure

private extension AdblockViewController {
    
    func configure() {
        configureConstraint()
        configureButton()
        configureLabel()
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 580 {
            buttonToSafeareaConstraint.constant = 10
            buttonToStackConstraint.constant = 20
            firstStackHeightConstraint.constant = 100
            secondStackHeightConstraint.constant = 100
            stackViewWidthConstraint.constant = 300
        }
        
        if UIScreen.main.bounds.size.height < 670 {
            buttonToSafeareaConstraint.constant = 10
            buttonToStackConstraint.constant = 20
        }
        
        if UIScreen.main.bounds.size.height > 1000 {
            //backgroundImage.contentMode = .scaleAspectFill
        }
    }
    
    func configureButton() {
        //continueButton.layer.
        continueButton.layer.shadowColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.3).cgColor
        continueButton.layer.shadowOpacity = 1
        continueButton.layer.shadowRadius = 30
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        continueButton.layer.shadowPath = UIBezierPath(rect: continueButton.bounds).cgPath
        continueButton.layer.masksToBounds = false
    }
    
    func configureLabel() {
        titleLabel.addCharacterSpacing(kernValue: 1.21)
        subtitle1Label.addCharacterSpacing(kernValue: 0.98)
        subtitle2Label.addCharacterSpacing(kernValue: 0.98)
    }
}

