//
//  BatteryExtensionViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 13.12.22.
//

import Foundation

protocol BatteryExtensionViewControllerDelegate: AnyObject {
    func lowPower(type: WebSites)
}
