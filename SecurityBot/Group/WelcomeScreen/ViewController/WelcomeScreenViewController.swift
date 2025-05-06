//
//  WelcomeScreenViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 26.02.24.
//

import UIKit
import Lottie

class WelcomeScreenViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var welcomeView: LottieAnimationView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        welcomeView.animation = LottieAnimation.named("Animation_welc")
        welcomeView.loopMode = .playOnce
        welcomeView.play()
    }
    
    // - Action
    @IBAction func registrationAction(_ sender: UIButton) {
        showAuth(tag: sender.tag)
    }
    
}

// MARK: -
// MARK: - Configure

private extension WelcomeScreenViewController {
    
    func showAuth(tag: Int) {
        let vc = UIStoryboard(name: "Sing", bundle: nil).instantiateInitialViewController() as! SingViewController
        vc.isRegistration = tag == 0
        navigationController?.pushViewController(vc, animated: true)
    }
}
