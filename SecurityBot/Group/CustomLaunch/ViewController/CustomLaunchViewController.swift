//
//  CustomLaunchViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 1.03.24.
//

import UIKit
import Lottie

final class CustomLaunchViewController: UIViewController, URLSessionDelegate {
    
    // - UI
    @IBOutlet weak private var loadingView: LottieAnimationView!
    
    // - 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

// MARK: -
// MARK: - Configure

private extension CustomLaunchViewController {
    
    func configure() {
        configureAnimate()
        configureLoadData()
        configureProfile()
    }
    
    func configureAnimate() {
        loadingView.loopMode = .loop
        loadingView.play()
    }
    
    func configureLoadData() {
        let token = UserDefaultsManager().getStringValue(data: .token)
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.validateToken(token: token) { [weak self] isValid, error in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.changeRootViewController(isValid)
                    //                    self?.changeRootVC()
                }
            }
        }
    }
    
    func configureProfile() {
        let token = UserDefaultsManager().getStringValue(data: .token)
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.getModel(token: token) { model, error in
                guard let model = model else { return }
                UserDefaultsManager().setProfile(model)
            }
        }
    }
    
    func changeRootViewController(_ valid: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        var vc = UIViewController()
        if !valid {
            let story = UIStoryboard(name: "WelcomeScreen", bundle:nil)
            vc = story.instantiateInitialViewController() as! WelcomeScreenViewController
        } else {
            let story = UIStoryboard(name: "SecondScreen", bundle:nil)
            vc = story.instantiateInitialViewController() as! SecondScreenViewController
        }
        let navigation = UINavigationController(rootViewController: vc)
        navigation.navigationBar.tintColor = UIColor(red: 0.286, green: 0.612, blue: 0.643, alpha: 1)
        navigation.navigationBar.isHidden = !valid
        window?.rootViewController = navigation
        UIView.transition(with: window ?? UIWindow(), duration: 0.3, options: .transitionCrossDissolve) {
            window?.makeKeyAndVisible()
        }
    }
}

extension CustomLaunchViewController {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
}

// MARK: -
// MARK: - Configure

private extension CustomLaunchViewController {
    
    func validateToken(token: String, completion: @escaping (Bool, Error?) -> Void) {
        
        guard let url = URL(string: "http://localhost:6969/validateToken") else {
            completion(false, HTTPStatusCode(rawValue: 0))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(false, HTTPStatusCode(rawValue: 0))
                return
            }
            guard let data = data else {
                completion(false, HTTPStatusCode(rawValue: 0))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonObject = json as? [String: Any] {
                    if let isAllow = jsonObject["request"] as? Bool {
                        completion(isAllow, HTTPStatusCode(rawValue: 0))
                    } else {
                        completion(false, HTTPStatusCode(rawValue: 0))
                    }
                } else {
                    completion(false, HTTPStatusCode(rawValue: 0))
                }
            } catch {
                completion(false, HTTPStatusCode(rawValue: 0))
            }
        }
        task.resume()
    }
    
    func getModel(token: String, completion: @escaping (_ locations: ProfileModel?, Error?) -> Void) {
        guard let url = URL(string: "http://localhost:6969/get") else {
            completion(nil, HTTPStatusCode(rawValue: 0))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(nil, HTTPStatusCode(rawValue: 0))
                return
            }
            guard let data = data else {
                completion(nil, HTTPStatusCode(rawValue: 0))
                return
            }
            do {
                let decoder = JSONDecoder()
                let profile = try decoder.decode(ProfileModel.self, from: data)
                completion(profile, nil)
            } catch {
                completion(nil, HTTPStatusCode(rawValue: 0))
            }
        }
        task.resume()
    }
}
