//
//  SettingsViewControllerDeleagte.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 8.12.22.
//

import Foundation

protocol SettingsViewControllerDelegate: AnyObject {
    func termsShow()
    func privacyShow()
    func rateUsShow()
    func supportShow()
    func showIdentification()
    func showGuide()
    func chatsShow()
    func showRequestId(idVC: IdentificationViewController)
    func showShop()
    func showPassword(passVC: PasswordViewController)
    func updateCollection()
}
