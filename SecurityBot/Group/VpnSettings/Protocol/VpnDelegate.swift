//
//  VpnDelegate.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 15.12.22.
//

import Foundation

protocol VpnDelegate: AnyObject {
    func vpnState(state: Bool)
}
