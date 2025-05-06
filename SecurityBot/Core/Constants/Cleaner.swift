//
//  Cleaner.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 26.11.22.
//

import Foundation

enum Cleaner {
    static var photo = false
    static var screenshot = false
    static var event = false
    static var contact = false
}

struct SecretFolder {
    static var lock = true
}

struct Email {
    static var email = "botvpnandcleaner.help@gmail.com"
}

struct Adblock {
    static var adblockIsOn = false
}

struct Vpn {
    static var vpnIsOn = false
}

struct Setting {
    static var guideisPresent = false
}
