//
//  SpeedTestViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.10.22.
//

import Foundation
import UIKit
import NDT7


class SpeedTestViewController: UIViewController {
    // - UI
    @IBOutlet weak var BackgroundView: UIView!
    @IBOutlet weak var speedTestProgressView: CProgressDownloadView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedUnitLabel: UILabel!
    @IBOutlet weak var downloadSpeedLabel: UILabel!
    @IBOutlet weak var uploadSpeedLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var loadingView: CPLoadingView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // - Constraint
    @IBOutlet weak var buttonToSafeareaConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressViewToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressViewToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressViewToRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressViewToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressViewToLeftConstraint: NSLayoutConstraint!
    
    
    // - Data
    var stop: Bool = false
    var downloadTestRunning: Bool = false
    var uploadTestRunning: Bool = false
    var enableAppData = true
    var downloadSpeed: Double?
    var uploadSpeed: Double?
    var ndt7Test: NDT7Test?
    private var test: SpeedTest = .begin
    var value = 0.0
    var generalSpeed = 0
    var speed = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - Action
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startSpeedAction(_ sender: Any) {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
//            let premiumVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//            premiumVC.modalPresentationStyle = .fullScreen
//            present(premiumVC, animated: true)
        } else {
            switch test {
            case .begin:
                loadingView.isHidden = false
                loadingView.startLoading()
                speedLabel.isHidden = true
                speedUnitLabel.isHidden = true
                stop = false
                speedTestProgressView.trackColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 0.3)
                speedTestProgressView.progressLayer.isHidden = false
                speedTestProgressView.backgroundLayer.shadowOpacity = 0
                startTest()
                configureStop()
                test = .stop
                //            configureAnimateBeginSpeed()
                print("start")
            case .stop:
                speedTestProgressView.trackColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 0.3)
                speedTestProgressView.progressLayer.isHidden = true
                speedTestProgressView.animationDuration = 0
                speedTestProgressView.setProgress(0, animated: false)
                stopTest()
                stop = true
                view.layer.removeAllAnimations()
                cancelTest()
                speedTestView()
                configureStart()
                test = .again
                print("stop")
            case .again:
                configureStop()
                stop = false
                speedTestProgressView.trackColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 0.3)
                speedTestProgressView.progressLayer.isHidden = false
                speedTestProgressView.backgroundLayer.shadowOpacity = 0
                startTest()
                test = .stop
            }
        }
    }
    
    func startTest() {
        clearData()
        let settings = NDT7Settings()
        ndt7Test = NDT7Test(settings: settings)
        ndt7Test?.delegate = self
        statusUpdate(downloadTestRunning: true, uploadTestRunning: false)
        ndt7Test?.startTest(download: true, upload: false) { (error) in
            //strongSelf.cancelTest()
            guard let error = error else { return }
            print(error)
        }
    }
    
    func cancelTest() {
        ndt7Test?.cancel()
        print("cancel")
    }
    
    func clearData() {
        downloadSpeedLabel.text = "0.0 MB/S"
        uploadSpeedLabel.text = "0.0 MB/S"
    }
    
    func statusUpdate(downloadTestRunning: Bool?, uploadTestRunning: Bool?) {
        if let downloadTestRunning = downloadTestRunning {
            self.downloadTestRunning = downloadTestRunning
        }
        if let uploadTestRunning = uploadTestRunning {
            self.uploadTestRunning = uploadTestRunning
        }
        if self.downloadTestRunning == false && self.uploadTestRunning == false {
            print("run")
        } else {
            print("cancel")
        }
    }
}

// - MARK: -
// - MARK: - Configure

private extension SpeedTestViewController {
    func configure () {
        configureProgressView()
        configureConstraint()
        speedTestView()
        stopTest()
        configureAnimateStopSpeed()
        configureLabel()
    }
    
    func speedTestView() {
        speedTestProgressView.trackColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 0.3)
        speedTestProgressView.circleColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 1)
    }
    
    func configureProgressView() {
        BackgroundView.layer.cornerRadius = BackgroundView.frame.height / 2
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 580 {
            buttonToSafeareaConstraint.constant = 10
            buttonToViewConstraint.constant = 10
            progressViewToViewConstraint.constant = 10
            BackgroundView.layer.cornerRadius = backgroundHeightConstraint.constant / 2
        }
        
        if UIScreen.main.bounds.size.height < 670 {
            progressViewToViewConstraint.constant = 20
            BackgroundView.layer.cornerRadius = backgroundHeightConstraint.constant / 2
        }
    }
    
    func configureAnimateBeginSpeed(duration: Float) {
        loadingView.isHidden = true
        speedLabel.isHidden = false
        speedUnitLabel.isHidden = false
        speedTestProgressView.animationDuration = CGFloat(duration)
        speedTestProgressView.setProgress(1, animated: true, completion: {
            self.ndt7Test?.cancel()
            self.configureAnimateStopSpeed()
            self.speedTestProgressView.progressLayer.isHidden = true
            //self.speedTestProgressView.trackColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 1)
            //self.configureAgain()
            self.speedTestProgressView.progress = 0
            //self.test = .begin
            if !self.stop {
                self.ndt7Test?.startTest(download: false, upload: true) { [weak self] (error) in
                    if let error = error {
                        print("Errooooooor \(error)")
                    }
                    DispatchQueue.main.async {
                        self?.statusUpdate(downloadTestRunning: false, uploadTestRunning: false)
                    }
                }
            } else {
                self.stopTest()
            }
        })
    }
    
    func configureAnimateBeginSpeedUpload(duration: Float) {
        speedTestProgressView.animationDuration = CGFloat(duration)
        speedTestProgressView.setProgress(1, animated: true, completion: {
            self.ndt7Test?.cancel()
            self.configureAnimateStopSpeed()
            self.speedTestProgressView.progressLayer.isHidden = true
            if !self.stop {
                self.speedTestProgressView.trackColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 1)
                self.speedTestProgressView.backgroundLayer.shadowOpacity = 1
                self.configureAgain()
                self.test = .begin
            }
            self.speedTestProgressView.progress = 0
            self.stopTest()
        })
    }
    
    func configureStart() {
        speedTestProgressView.progress = 0
        scanButton.setTitle("START", for: .normal)
        scanButton.backgroundColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 1)
        scanButton.setTitleColor(.black, for: .normal)
        speedTestProgressView.circleColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 1)
    }
    
    func configureStop() {
        scanButton.setTitle("STOP", for: .normal)
        scanButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        speedTestProgressView.circleColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 1)
        scanButton.setTitleColor(.white, for: .normal)
        //speedUnitLabel.isHidden = false
        speedLabel.text = "0"
    }
    
    func configureAgain() {
        scanButton.setTitle("START AGAIN", for: .normal)
        scanButton.backgroundColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 1)
        scanButton.setTitleColor(.black, for: .normal)
        speedLabel.text = "DONE"
        speedUnitLabel.isHidden = true
    }
    
    func configureAnimateStopSpeed() {
        speedTestProgressView.animationDuration = 0
        speedTestProgressView.setProgress(0, animated: false)
    }
    
    func stopTest() {
        speedTestProgressView.progressLayer.isHidden = true
        speedTestProgressView.progress = 0
        speedTestProgressView.animationDuration = 0
        speedTestProgressView.setProgress(0, animated: false)
        cancelTest()
        ndt7Test?.startTest(download: false, upload: false) { [weak self] (error) in
            print(error as Any)
            self?.cancelTest()
        }
    }
    
    func decimalArray(from firstInt: Double, to secondInt: Double) -> [Double] {
        var firstInt = firstInt
        var array: [Double] = []
        if firstInt == secondInt {
            array.insert(firstInt, at: 0)
        } else if firstInt > secondInt {
            let decimals = (firstInt - secondInt) / 10
            while firstInt >= secondInt {
                array.append(firstInt.rounded(toPlaces: 1))
                firstInt -= decimals
            }
        } else if secondInt > firstInt {
            let decimals = (secondInt - firstInt) / 10
            while secondInt >= firstInt {
                array.append(firstInt.rounded(toPlaces: 1))
                firstInt += decimals
            }
        }
        return array
    }
}

// MARK: -
// MARK: - Delegate

extension SpeedTestViewController: NDT7TestInteraction {
    
    func test(kind: NDT7TestConstants.Kind, running: Bool) {
        switch kind {
        case .download:
            downloadTestRunning = running
            configureAnimateBeginSpeed(duration: 10)
        case .upload:
            if !stop {
            uploadTestRunning = running
            speedTestProgressView.progressLayer.isHidden = false
            configureAnimateStopSpeed()
            configureStop()
            configureAnimateBeginSpeedUpload(duration: 10)
            } else {
                stopTest()
            }
            speedTestProgressView.trackColor = UIColor(red: 1, green: 0.149, blue: 0.506, alpha: 0.3)
        }
    }
    
    func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
        if origin == .client,
           enableAppData,
           let elapsedTime = measurement.appInfo?.elapsedTime,
           let numBytes = measurement.appInfo?.numBytes,
           elapsedTime >= 1000000 {
            let seconds = elapsedTime / 1000000
            let mbit = numBytes / 125000
            let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
            switch kind {
            case .download:
                downloadSpeed = rounded
                DispatchQueue.main.async { [weak self] in
                    self?.downloadSpeedLabel.text = "\(rounded) MB/S"
                    self?.speedLabel.text = "\(rounded)"
                    //print(elapsedTime)
                }
            case .upload:
                uploadSpeed = rounded
                DispatchQueue.main.async { [weak self] in
                    self?.uploadSpeedLabel.text = "\(rounded) MB/S"
                    self?.speedLabel.text = "\(rounded)"
                    //print(mbit)
                }
            }
        } else if origin == .server,
                  let elapsedTime = measurement.tcpInfo?.elapsedTime,
                  elapsedTime >= 1000000 {
            let seconds = elapsedTime / 1000000
            switch kind {
            case .download:
                if let numBytes = measurement.tcpInfo?.bytesSent {
                    let mbit = numBytes / 125000
                    let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
                    downloadSpeed = rounded
                    DispatchQueue.main.async { [weak self] in
                        self?.downloadSpeedLabel.text = "\(rounded) MB/S"
                        self?.speedLabel.text = "\(rounded)"
                        self?.speed.append(rounded)
                    }
                }
            case .upload:
                if let numBytes = measurement.tcpInfo?.bytesReceived {
                    let mbit = numBytes / 125000
                    let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
                    uploadSpeed = rounded
                    DispatchQueue.main.async { [weak self] in
                        self?.uploadSpeedLabel.text = "\(rounded) MB/S"
                        self?.speedLabel.text = "\(rounded)"
                    }
                }
            }
        }
    }
    
    func error(kind: NDT7TestConstants.Kind, error: NSError) {
        cancelTest()
    }
    
    func errorAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            strongSelf.present(alert, animated: true)
        }
    }
    
    func configureLabel() {
        titleLabel.addCharacterSpacing(kernValue: 1.21)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


enum SpeedTest {
    case begin
    case stop
    case again
}
