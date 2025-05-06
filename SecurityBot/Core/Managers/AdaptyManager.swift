//
//  AdaptyManager.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 7.12.22.
//

import Foundation
//import Adapty

class AdaptyManager{
    
    static let shared = AdaptyManager()
    
    // - Data
    private var permission = "premium"
    //private var singleSubscribeId = "com.VpnSafety.singleWeekly"
    var subscribeId = ["com.VpnSafety.weekly","com.VpnSafety.monthly","com.VpnSafety.annualy"]
    
    
    func setBoolSubscribeValue(value: Bool) {
        UserDefaultsManager().setBoolValue(value: value, data: .premium)
    }
    
    func getPurchaseInfo() {
//        Adapty.getProfile { result in
//            switch result {
//            case .success(let profile):
//                let isActive = profile.accessLevels["premium"]?.isActive ?? false
//                self.setBoolSubscribeValue(value: isActive)
//            case .failure(_):
//                print("error")
//            }
//        }
    }
}
