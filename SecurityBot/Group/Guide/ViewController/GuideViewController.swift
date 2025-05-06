//
//  GuideViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.10.22.
//

import Foundation
import UIKit
import Lottie

class GuideViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var title4Label: UILabel!
    
    // - Constraint
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - Action
    @IBAction func backAction(_ sender: Any) {
        if !Setting.guideisPresent {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
        
    }
}

// MARK: -
// MARK: - Configure

private extension GuideViewController {
    
    func configure() {
        configureAnimate()
        configureConstraint()
        configureLabel()
    }
    
    func configureAnimate() {
        animationView.loopMode = .loop
        animationView.play()
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 580 {
            //stackViewTopConstraint.constant = 70
            firstViewHeightConstraint.constant = 105
            secondViewHeightConstraint.constant = 105
            thirdViewHeightConstraint.constant = 105
            fourViewHeightConstraint.constant = 105
            stackViewHeightConstraint.constant = 270
        }
        
        if UIScreen.main.bounds.size.height < 1000 {
            stackViewTopConstraint.constant = 70
        }
    }
    
    func configureLabel() {
        title1Label.addCharacterSpacing(kernValue: 1.5)
        title2Label.addCharacterSpacing(kernValue: 1.5)
        title3Label.addCharacterSpacing(kernValue: 1.5)
        title4Label.addCharacterSpacing(kernValue: 1.5)
    }
}

