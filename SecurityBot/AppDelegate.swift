//
//  AppDelegate.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 4.10.22.
//

import UIKit
//import Adapty

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window:UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configure()
        return true
    }
}

// MARK: -
// MARK: - Configure

private extension AppDelegate {
    
    func configure() {
        configureRunViewController()
    }
    
    func configureRunViewController() {
        UserDefaultsManager().setBoolValue(value: true, data: .premium)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.overrideUserInterfaceStyle = .light
        let launch = UIStoryboard(name: "CustomLaunch", bundle: nil).instantiateInitialViewController() as! CustomLaunchViewController
        window?.rootViewController = launch
        window?.makeKeyAndVisible()
    }
}
