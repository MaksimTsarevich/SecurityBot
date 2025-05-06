//
//  SettingsModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 21.10.22.
//

import Foundation
import UIKit

enum SettingsItem: String, CaseIterable {
    case tutorial = "AdBlock Tutorial"
    case support = "Support"
    case chats = "Chats"
//    case subscription = "Roots"
    case passcode = "Use Passcode"
    case faceId = "Use Face ID"
    case termsOfUse = "Terms of use"
    case policy = "Privacy Policy"
    case rateUs = "Rate Us"
    
    var icon: UIImage? {
        switch self{
        case .tutorial:
            return UIImage(named: "TutorialItem")
        case .support:
            return UIImage(named: "SupportItem")
//        case .subscription:
//            return UIImage(named: "SubscriptionItem")
        case .passcode:
            return UIImage(named: "PasscodeItem")
        case .faceId:
            return UIImage(named: "FaceIdItem")
        case .termsOfUse:
            return UIImage(named: "TermsItem")
        case .policy:
            return UIImage(named: "PrivacyItem")
        case .rateUs:
            return UIImage(named: "RateItem")
        case .chats:
            return UIImage(named: "ChatsItem")
        }
    }
}
