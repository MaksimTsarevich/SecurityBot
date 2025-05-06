//
//  VpnSettingsViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.10.22.
//

import UIKit
import NetworkExtension
import Lottie
import Kingfisher

class VpnSettinsViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var VpnView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var loadingView: CPLoadingView!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryFlagImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var leftBackgroundImage: UIImageView!
    @IBOutlet weak var rightBackgroundImage: UIImageView!
    
    // - Constraint
    @IBOutlet weak var buttonToSafeareaConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTobuttonConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewToCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabelToBottom: NSLayoutConstraint!
    
    
    // - Delegate
    weak var delegate: VpnDelegate?
    
    // - Data
    private let vpnService = VPNService()
    private var locations = [LocationModel]()
    private var currentLocation = LocationModel()
    private var timeInterval: TimeInterval = 0
    private var timer = Timer()
    
    // - Manager
    private let locationManager = GetLocation()
    private let userDefaultsManager = UserDefaultsManager()
    
    // - Test
    private var test = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play()
        vpnStatusChanged(vpnService.status)
    }
    
    // - Action
    @IBAction func backButtonAction(_ sender: Any) {
//        navigationController?.popToRootViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func setCountryButtonAction(_ sender: Any) {
        let countryListVC = UIStoryboard(name: "CountryList", bundle: nil).instantiateInitialViewController() as! CountryListViewController
        //countryListVC.delegateUpdate = self
        countryListVC.currentLocation = currentLocation
        countryListVC.locations = locations
        countryListVC.delegate = self
        present(countryListVC, animated: true)
    }
    
    @IBAction func speedTestButtonAction(_ sender: Any) {
        let speedTestVC = UIStoryboard(name: "SpeedTest", bundle: nil).instantiateInitialViewController() as! SpeedTestViewController
        navigationController?.pushViewController(speedTestVC, animated: true)
    }
    
    @IBAction func connectAction(_ sender: Any) {
        test += 1
        if test % 3 == 1 {
            vpnStatusChanged(.connecting)
        } else if test % 3 == 2 {
            vpnStatusChanged(.connected)
        } else {
            vpnStatusChanged(.disconnected)
        }
        userDefaultsManager.setAllowedVPN(isAllowed: true)
        //vpnManaging()
    }
}

// MARK: -
// MARK: - Delegate

extension VpnSettinsViewController: CountryCollectionDataSourceDelegate, VpnSettinsViewControllerDelegate {
    func update(location: LocationModel) {
        currentLocation = location
    }
    
    func set(location: LocationModel) {
        vpnService.disconnect()
        countryLabel.text = location.country
        guard let url = URL(string: location.flag) else { return }
        countryFlagImage.kf.setImage(with: url)
        userDefaultsManager.setLocation(location)
        currentLocation = location
        //getCurrentLocation()
    }
}

// - MARK: -
// - MARK: - Configure

private extension VpnSettinsViewController {
    
    func configure() {
        configureVpnView()
        configureConstraint()
        subscribeToVPNNotification()
        getLocation()
        configureAnimation()
        configureButton()
        configureLabel()
    }
    
    func setLocation() {
        countryLabel.text = currentLocation.country
        guard let url = URL(string: currentLocation.flag) else { return }
        countryFlagImage.kf.setImage(with: url)
    }
    
    func vpnManaging() {
        if vpnService.status == .connected {
            vpnService.disconnect()
            return
        }
        vpnStatusChanged(vpnService.status)
        vpnService.disconnect { [unowned self] in
            self.vpnService.connect(serverAddress: currentLocation.ip, sharedSecret: currentLocation.key)
        }
    }
    
    func subscribeToVPNNotification() {
        NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange,object: nil, queue: .main) { [weak self] notification in
            guard let vpnConnection = notification.object as? NEVPNConnection else { return }
            let status = vpnConnection.status
            self?.vpnStatusChanged(status)
        }
    }
    
    func vpnStatusChanged( _ status: NEVPNStatus) {
        switch status {
        case .invalid, .disconnecting, .disconnected:
            Vpn.vpnIsOn = false
            timer.invalidate()
            timeLabel.text = "0s"
            statusImage.image = UIImage(named: "ShieldVpnLogo")
            statusLabel.text = "vpn disconnected".uppercased()
            statusLabel.addCharacterSpacing(kernValue: 0.98)
            timeView.isHidden = true
            loadingView.isHidden = true
            animationView.isHidden = true
            connectButton.setTitle("ENABLE VPN", for: .normal)
            connectButton.setTitleColor(.black, for: .normal)
            connectButton.backgroundColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 1)
            leftBackgroundImage.image = UIImage(named: "LeftGroupImage")
            rightBackgroundImage.image = UIImage(named: "RightGroupImage")
            connectButton.layer.shadowOpacity = 1
            delegate?.vpnState(state: false)
            //            connectButton.isUserInteractionEnabled = true
        case .connecting, .reasserting:
            statusImage.image = UIImage(named: "ConnectingShieldImage")
            statusLabel.text = "vpn connecting".uppercased()
            statusLabel.addCharacterSpacing(kernValue: 0.98)
            timeView.isHidden = true
            loadingView.isHidden = false
            loadingView.startLoading()
            animationView.isHidden = true
            leftBackgroundImage.image = UIImage(named: "LeftGroupImage")
            rightBackgroundImage.image = UIImage(named: "RightGroupImage")
            connectButton.layer.shadowOpacity = 1
            //            connectButton.isUserInteractionEnabled = false
        case .connected:
            UserDefaults.standard.set(Date(), forKey: "dataStartConnect")
            statusImage.image = UIImage(named: "ConnectShieldImage")
            statusLabel.text = "vpn connected".uppercased()
            statusLabel.addCharacterSpacing(kernValue: 0.98)
            let date = UserDefaults.standard.object(forKey: "dataStartConnect") as! Date
            let date2 = Date()
            timeInterval = date2.timeIntervalSince(date)
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
                timeInterval += 1
                if timeInterval < 60 {
                    timeLabel.text = "\(Int(timeInterval)) s"
                } else {
                    timeLabel.text = "\(Int(timeInterval / 60))m \(Int(timeInterval) % 60)s"
                }
            }
            Vpn.vpnIsOn = true
            timeView.isHidden = false
            loadingView.isHidden = true
            //print(timeInterval)
            animationView.isHidden = false
            connectButton.setTitle("DISABLE VPN", for: .normal)
            connectButton.setTitleColor(.white, for: .normal)
            connectButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            leftBackgroundImage.image = UIImage(named: "LeftConnectImage")
            rightBackgroundImage.image = UIImage(named: "RightConnectImage")
            connectButton.layer.shadowOpacity = 0
            delegate?.vpnState(state: true)
            //            connectButton.isUserInteractionEnabled = true
        @unknown default: break
        }
    }
    
    func getLocation() {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.locationManager.getLocation { [weak self] (locations) in
                if let locations = locations {
                    self?.locations = locations
                    self?.getCurrentLocation()
                }
            }
        }
    }
    
    func getCurrentLocation() {
        if !locations.isEmpty {
            if let free = locations.first(where: { $0.free == true }) {
                currentLocation = free
                DispatchQueue.main.async { [weak self] in
                    self?.setLocation()
                }
            } else {
                currentLocation = locations[0]
            }
            UserDefaultsManager.shared.setLocation(currentLocation)
            currentLocation = UserDefaultsManager.shared.getLocation()
        }
    }
    
    func configureVpnView() {
        VpnView?.clipsToBounds = true
        VpnView?.layer.cornerRadius = 17
        VpnView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 580 {
            buttonToSafeareaConstraint.constant = 5
            buttonToViewConstraint.constant = 10
            //labelConstraint.constant = 30
            buttonTobuttonConstraint.constant = 10
        }
        
        if UIScreen.main.bounds.size.height < 670 {
            buttonToSafeareaConstraint.constant = 5
            labelConstraint.constant = 39
            viewToCenterConstraint.constant = -50
            timeLabelToBottom.constant = 5
        }
    }
    
    func configureAnimation() {
        animationView.loopMode = .loop
        animationView.play()
    }
    
    func configureButton() {
        connectButton.layer.shadowColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.3).cgColor
        connectButton.layer.shadowOpacity = 1
        connectButton.layer.shadowRadius = 20
        connectButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        connectButton.layer.shadowPath = UIBezierPath(rect: connectButton.bounds).cgPath
        connectButton.layer.masksToBounds = false
    }
    
    func configureLabel() {
        statusLabel.addCharacterSpacing(kernValue: 0.98)
    }
}

