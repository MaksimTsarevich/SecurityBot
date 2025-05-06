//
//  AccessViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 20.10.22.
//

import UIKit

class AccessViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accessImage: UIImageView!
    @IBOutlet weak var subtitle1Label: UILabel!
    @IBOutlet weak var subtitle2Label: UILabel!
    
    
    // - Constraint
    @IBOutlet weak var imageToTopViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    
    // - Data
    var type: AccessList = .gallery
    
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
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl)
            } else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
    func setupView() {
        // 6. add blur view and send it to back
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
    }
    
    
}

// MARK: -
// MARK: - Configure

private extension AccessViewController {
    
    func configure() {
        configureConstraint()
        configureType()
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 580 {
            imageToTopViewConstraint.constant = 50
        }
        
        if UIScreen.main.bounds.size.height < 670 {
            imageToTopViewConstraint.constant = 100
        }
        
        if UIScreen.main.bounds.size.height < 1000 {
            viewWidthConstraint.constant = UIScreen.main.bounds.width - 50
        }
    }
    
    func configureType() {
        titleLabel.text = type.rawValue
        subtitle1Label.text = type.subTitle1
        subtitle2Label.text = type.subTitle2
        accessImage.image = type.icon
    }
}

