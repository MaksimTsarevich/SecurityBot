//
//  SingViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 13.02.24.
//

import UIKit

class SingViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    // - Data
    var isRegistration = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // - Action
    @IBAction func loginAction(_ sender: Any) {
        goButton.isHidden = true
        activityView.startAnimating()
        if isRegistration {
            if let name = nameTextField.text, let login = loginTextField.text, let password = passwordTextField.text {
                registration(name: name, login: login, password: password, color: randomHex()) { token, error   in
                    if let token = token {
                        UserDefaultsManager().setStringValue(value: name, data: .login)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.activityView.stopAnimating()
                            UserDefaultsManager().setStringValue(value: token, data: .token)
                            let vc = UIStoryboard(name: "SecondScreen", bundle: nil).instantiateInitialViewController() as! SecondScreenViewController
//                            vc.token = token
                            self.navigationController?.navigationBar.isHidden = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else  {
                        if let httpError = error as? HTTPStatusCode {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.activityView.stopAnimating()
                                self.showAlertController(title: "\(httpError.description)", message: "\(httpError.local)", handler: {_ in
                                    self.goButton.isHidden = false
                                })
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.activityView.stopAnimating()
                                self.showAlertController(title: "\(HTTPStatusCode.some.description)", message: "\(HTTPStatusCode.some.local)", handler: {_ in
                                    self.goButton.isHidden = false
                                })
                            }
                        }
                        
                    }
                }
            }
        } else {
            if let login = loginTextField.text, let password = passwordTextField.text {
                getToken(login: login, password: password) { token, error  in
                    if let token = token {
                        DispatchQueue.main.async {
                            UserDefaultsManager().setStringValue(value: token, data: .token)
                            let vc = UIStoryboard(name: "SecondScreen", bundle: nil).instantiateInitialViewController() as! SecondScreenViewController
//                            vc.token = token
                            self.navigationController?.navigationBar.isHidden = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else  {
                        if let httpError = error as? HTTPStatusCode {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.activityView.stopAnimating()
                                self.showAlertController(title: "\(httpError.description)", message: "\(httpError.local)", handler: {_ in
                                    self.goButton.isHidden = false
                                })
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.activityView.stopAnimating()
                                self.showAlertController(title: "\(HTTPStatusCode.some.description)", message: "\(HTTPStatusCode.some.local)", handler: {_ in
                                    self.goButton.isHidden = false
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func registrationAction(_ sender: Any) {
        isRegistration = true
        titleLabel.text = "Registration".uppercased()
    }
    
    func showAlertController(title: String?, message: String?, handler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(ac, animated: true, completion: nil)
    }
    
    func randomHex() -> String {
        let letters = "0123456789ABCDEF"
        var randomHex = ""
        for _ in 0..<6 {
            let randomIndex = Int.random(in: 0..<letters.count)
            let character = letters[letters.index(letters.startIndex, offsetBy: randomIndex)]
            randomHex.append(character)
        }
        return randomHex
    }
}

extension SingViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
}

// MARK: -
// MARK: - Delegate

extension SingViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newName = nameTextField.text ?? ""
        var newLogin = loginTextField.text ?? ""
        var newPassword = passwordTextField.text ?? ""
        if textField == nameTextField {
            newName.replaceSubrange(Range(range, in: newName)!, with: string)
        } else if textField == loginTextField {
            newLogin.replaceSubrange(Range(range, in: newLogin)!, with: string)
        } else if textField == passwordTextField {
            newPassword.replaceSubrange(Range(range, in: newPassword)!, with: string)
        }
        if isRegistration {
            if !newName.isEmpty && !newLogin.isEmpty && !newPassword.isEmpty {
                goButton.isHidden = false
            } else {
                goButton.isHidden = true
            }
        } else {
            if !newLogin.isEmpty && !newPassword.isEmpty {
                goButton.isHidden = false
            } else {
                goButton.isHidden = true
            }
        }
        return true
    }
}

// MARK: -
// MARK: - Configure

private extension SingViewController {
    
    func configure() {
        configureType()
        configureTextField()
    }
    
    func configureType() {
        titleLabel.text = isRegistration ? "registration".uppercased() : "login".uppercased()
        nameTextField.isHidden = !isRegistration
    }
    
    func configureTextField() {
        nameTextField.delegate = self
        loginTextField.delegate = self
        passwordTextField.delegate = self
    }
}

// MARK: -
// MARK: - Func

private extension SingViewController {
    
    func registration(name: String, login: String, password: String, color: String, _ completion: @escaping (_ token: String?, _ error: Error?) -> Void) {
        let urlString = "http://localhost:6969/add"
        
        guard let url = URL(string: urlString) else {
            completion(nil, HTTPStatusCode(rawValue: 0))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData: [String: Any] = ["name": name, "login": login, "password": password, "color": color]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            request.httpBody = jsonData
        } catch {
            print("Error converting data to JSON: \(error.localizedDescription)")
            completion(nil, error)
            return
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: request) { [weak self] (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    completion(nil, HTTPStatusCode(rawValue: httpResponse.statusCode))
                    return
                }
            }
            guard let data = data else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                completion(nil, error)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let token = json["token"] as? String {
                        self?.getModel(token: token) { model, error in
                            guard let model = model else { return }
                            UserDefaultsManager().setProfile(model)
                        }
                        completion(token, nil)
                    } else if let error = json["error"] as? Int{
                        completion(nil, HTTPStatusCode(rawValue: error))
                    }
                } else {
                    print("Unable to convert data to JSON.")
                    completion(nil, error)
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
    
    
    func getToken(login: String, password: String, _ completion: @escaping (_ token: String?, _ error: Error?) -> Void) {
        let urlString = "http://localhost:6969/login"
        
        guard let url = URL(string: urlString) else {
            completion(nil, HTTPStatusCode(rawValue: 0))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestData: [String: Any] = ["login": login, "password": password]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            request.httpBody = jsonData
        } catch {
            print("Error converting data to JSON: \(error.localizedDescription)")
            completion(nil, error)
            return
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: request) { [weak self] (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    completion(nil, HTTPStatusCode(rawValue: httpResponse.statusCode))
                    return
                }
            }
            guard let data = data else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                completion(nil, error)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let token = json["token"] as? String {
                        self?.getModel(token: token) { model, error in
                            guard let model = model else { return }
                            UserDefaultsManager().setProfile(model)
                        }
                        completion(token, nil)
                    } else if let error = json["error"] as? Int{
                        completion(nil, HTTPStatusCode(rawValue: error))
                    }
                } else {
                    print("Unable to convert data to JSON.")
                    completion(nil, error)
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
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

enum HTTPStatusCode: Int, Error, CaseIterable {
    case some = 0
    case notUser = 1
    case userFound = 2
    case ok = 200
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case internalServerError = 500
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case tooManyRequests = 429
    
    var description: String {
        switch self {
        case .ok:
            return "OK"
        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Unauthorized"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not Found"
        case .internalServerError:
            return "Internal Server Error"
        case .badGateway:
            return "Bad Gateway"
        case .serviceUnavailable:
            return "Service Unavailable"
        case .gatewayTimeout:
            return "Gateway Timeout"
        case .tooManyRequests:
            return "Too Many Requests"
        case .notUser:
            return "Not Found User"
        case .some:
            return "Opps"
        case .userFound:
            return "Opps"
        }
    }
    
    var local: String {
        switch self {
        case .ok:
            return ""
        case .badRequest:
            return ""
        case .unauthorized:
            return ""
        case .forbidden:
            return ""
        case .notFound:
            return ""
        case .internalServerError:
            return ""
        case .badGateway:
            return ""
        case .serviceUnavailable:
            return ""
        case .gatewayTimeout:
            return ""
        case .tooManyRequests:
            return ""
        case .notUser:
            return "The user is not registered"
        case .some:
            return "Something wrong"
        case .userFound:
            return "Such a user already exists"
        }
    }
}
