//
//  RateUsViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 21.10.22.
//

import UIKit
import StoreKit

class RateUsViewController: UIViewController {
    
    // - UI
    @IBOutlet var starView: [UIButton]!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    // - Constraint
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    
    
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
        setupView()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - Action
    @IBAction func starRateAction(_ sender: UIButton) {
        configureStar(sender: sender)
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        dismiss(animated: true)
        SKStoreReviewController.requestReview()
    }
    
    
}

// MARK: -
// MARK: - Configure

private extension RateUsViewController {
    
    func setupView() {
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
    }
    
    func configureStar(sender: UIButton) {
        starView.forEach { button in
            UIView.transition(with: button, duration: 0.3, options: .transitionCrossDissolve) {
                button.setImage(UIImage(named: "StarNotActive"), for: .normal)
            }
            
        }
        for i in 0...sender.tag {
            UIView.transition(with: starView[i], duration: 0.3, options: .transitionCrossDissolve) { [weak self] in
                self?.starView[i].setImage(UIImage(named: "StarActive"), for: .normal)
            }
        }
    }
    
    func configure() {
        configureConstraint()
        configureButton()
        configureLabel()
    }
    
    func configureConstraint() {
        
        if UIScreen.main.bounds.height < 1000 {
            viewWidthConstraint.constant = UIScreen.main.bounds.width - 50
        }
    }
    
    func configureButton() {
        sendButton.layer.shadowColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.3).cgColor
        sendButton.layer.shadowOpacity = 1
        sendButton.layer.shadowRadius = 20
        sendButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        sendButton.layer.shadowPath = UIBezierPath(rect: sendButton.bounds).cgPath
        sendButton.layer.masksToBounds = false
    }
    
    func configureLabel() {
        titleLabel.addCharacterSpacing(kernValue: 0.5)
    }
}


