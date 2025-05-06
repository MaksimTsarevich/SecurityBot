//
//  AdblockSettingsViewControllerDelegate.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 15.12.22.
//

import Foundation

protocol AdblockSettingsViewControllerDelegate: AnyObject {
    func adblockState(state: Bool)
}
