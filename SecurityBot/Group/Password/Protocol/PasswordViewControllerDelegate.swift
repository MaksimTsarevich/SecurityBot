//
//  PasswordViewControllerDelegate.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 30.11.22.
//

import Foundation

protocol PasswordViewControllerDelegate: AnyObject {
    func lockStatus()
    func passwordEnable()
}
