//
//  UserDefaultsManager.swift
//  Vpyat
//
//  Created by Kirill Hobyan on 25.08.22.
//

import UIKit

enum DataType: String {
    case onboarding
    case premium
    case tutorial
    case adBlock
    case blockAds
    case stopTrackingScripts
    case blockSocialButtons
    case blockTrackers
    case blockMining
    case passcode
    case passcodeCreate
    case pin
    case countOfSavedImages
    case lastSavedImage
    case countOfSavedContacts
    case lastSavedContact
    case location
    case accessGallery
    case accessContacts
    case accessEvents
    case accessAll
    case faceIdAccess
    case passwordEnable
    case biometricsEnable
    
    case token
    case login
    case profile
}

class UserDefaultsManager {

    static let shared = UserDefaultsManager()
    
    private let userDefaults = UserDefaults(suiteName: "group.fivev.cache")
    


    func setBoolValue(value: Bool, data: DataType) {
        userDefaults?.set(value, forKey: data.rawValue)
    }
    
    func getBoolValue(data: DataType) -> Bool {
        return userDefaults?.bool(forKey: data.rawValue) ?? false
    }
    
    func setArray(value: [String], data: DataType) {
        userDefaults?.set(value, forKey: data.rawValue)
    }
    
    func getArray(data: DataType) -> [String] {
        return userDefaults?.stringArray(forKey: data.rawValue) ?? [String]()
    }
    
    func setIntValue(value: Int, data: DataType) {
        userDefaults?.set(value, forKey: data.rawValue)
    }
    
    func getIntValue(data: DataType) -> Int {
        return userDefaults?.integer(forKey: data.rawValue) ?? 0
    }
    
    func setStringValue(value: String, data: DataType) {
        userDefaults?.set(value, forKey: data.rawValue)
    }
    
    func getStringValue(data: DataType) -> String {
        return userDefaults?.string(forKey: data.rawValue) ?? ""
    }
    
    func setAllowedVPN(isAllowed: Bool) {
        userDefaults?.setValue(isAllowed, forKey: "vpnIsAllowed")
    }
    
    func getAllowedVPN() -> Bool {
        return userDefaults!.bool(forKey: "vpnIsAllowed")
    }
    
    func setDictionary(dictionary: [String: Any], data: DataType) {
        userDefaults?.set(dictionary, forKey: data.rawValue)
    }
    
    func getDictionary(data: DataType) -> [String: Any] {
        return userDefaults?.dictionary(forKey: data.rawValue) ?? [:]
    }
    
    func setLocation(_ location: LocationModel) {
        var dictionary = [String: Any]()
        dictionary["free"] = location.free
        dictionary["flag"] = location.flag
        dictionary["ip"] = location.ip
        dictionary["key"] = location.key
        dictionary["country"] = location.country
        setDictionary(dictionary: dictionary, data: .location)
    }
    
    func getLocation() -> LocationModel {
        let location = LocationModel()
        let dictionary = getDictionary(data: .location)
        location.free = dictionary["free"] as? Bool ?? false
        location.flag = dictionary["flag"] as? String ?? ""
        location.ip = dictionary["ip"] as? String ?? ""
        location.key = dictionary["key"] as? String ?? ""
        location.country = dictionary["country"] as? String ?? ""
        return location
    }
    
    func setProfile(_ profile: ProfileModel) {
        var dictionary = [String: Any]()
        dictionary["id"] = profile.id
        dictionary["isAdmin"] = profile.isAdmin
        dictionary["name"] = profile.name
        dictionary["login"] = profile.login
        dictionary["color"] = profile.color
        setDictionary(dictionary: dictionary, data: .profile)
    }
    
    func getProfile() -> ProfileModel {
        let profile = ProfileModel()
        let dictionary = getDictionary(data: .profile)
        profile.id = dictionary["id"] as? Int ?? 0
        profile.isAdmin = dictionary["isAdmin"] as? Bool ?? false
        profile.name = dictionary["name"] as? String ?? ""
        profile.login = dictionary["login"] as? String ?? ""
        profile.color = dictionary["color"] as? String ?? ""
        return profile
    }
}
