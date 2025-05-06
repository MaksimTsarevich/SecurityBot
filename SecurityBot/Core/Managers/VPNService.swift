import UIKit
import NetworkExtension
import KeychainSwift

class VPNService {
    
    // - Typealias
    private typealias DisconnectCompletionBlock = () -> Void
    
    // - Data
    var status: NEVPNStatus {
        return NEVPNManager.shared().connection.status
    }
    
    // - Completions
    private var disconnectCompletionBlocks = [DisconnectCompletionBlock?]()
        
    init() {
        configure()
    }
}

// MARK: -
// MARK: - Connect / Disconnect

extension VPNService {
    
    func connect(serverAddress: String, sharedSecret: String) {
        let manager = NEVPNManager.shared()
        let keychain = KeychainSwift()
        
        keychain.set(sharedSecret, forKey: "shr")
                
        manager.loadFromPreferences { (error) in
            guard error == nil else {
                print(error as Any)
                return
            }
            
            let serverURL = serverAddress
            let protocolConfiguration = NEVPNProtocolIKEv2()
            protocolConfiguration.serverAddress = serverURL
            protocolConfiguration.localIdentifier = UUID().uuidString
            protocolConfiguration.authenticationMethod = .sharedSecret
            protocolConfiguration.disconnectOnSleep = false
            protocolConfiguration.remoteIdentifier = serverURL
            protocolConfiguration.useExtendedAuthentication = false
            protocolConfiguration.serverCertificateIssuerCommonName = serverURL
            protocolConfiguration.sharedSecretReference = keychain.getData("shr", asReference: true)
            
            var rules = [NEOnDemandRule]()
            let connectRule = NEOnDemandRuleConnect()
            connectRule.interfaceTypeMatch = .any
            rules.append(connectRule)
            
            let isOnDemandEnabled = false
            
            manager.onDemandRules = rules
            manager.isOnDemandEnabled = isOnDemandEnabled
            manager.protocolConfiguration = protocolConfiguration
            manager.localizedDescription = "S"
            manager.isEnabled = true
            
            manager.saveToPreferences() { (error) in
                guard error == nil else {
                    print(error as Any)
                    return
                }
                manager.loadFromPreferences { (error) in
                    guard error == nil else {
                        print(error as Any)
                        return
                    }
                    do {
                        try manager.connection.startVPNTunnel()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func disconnect(completion: (() -> Void)? = nil) {
        if status == .disconnected || status == .invalid {
            completion?()
            return
        }
        disconnectCompletionBlocks.append(completion)
        NEVPNManager.shared().connection.stopVPNTunnel()
    }
    
}

// MARK: -
// MARK: - Configure

private extension VPNService {

    func configure() {
        subscribeToNotifications()
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: nil , queue: .main) { [weak self] notification in
            guard let sSelf = self else { return }
            sSelf.invokeDisconnectCallbacks()
        }
    }
    
    func invokeDisconnectCallbacks() {
        if status == .disconnected {
            disconnectCompletionBlocks.forEach { $0?() }
            disconnectCompletionBlocks = []
        }
    }
}

