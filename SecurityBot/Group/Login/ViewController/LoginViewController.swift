//
//  LoginViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 12.02.24.
//

import UIKit

class LoginViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    
    // - Data
    var data: [DataModel] = [DataModel]()
    var token: String?
    
    // - DataSource
    private var dataSource: LoginCollectionViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getLocation(completion: { data in
            if let data = data {
                self.data = data
                DispatchQueue.main.async {
                    self.dataSource.update(data: data)
                }
            }
        })
    }
}

extension LoginViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
}

// MARK: -
// MARK: - Configure

private extension LoginViewController {
    
    func configure() {
        configureDataSource()
    }
    
    func configureDataSource() {
        dataSource = LoginCollectionViewDataSource(collectionView: collectionView, data: data)
    }
    
    func getLocation(completion: @escaping (_ locations: [DataModel]?) -> Void) {
        let urlString = "http://localhost:6969/get"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            guard let data = data else {
                if let error = error {
                    DispatchQueue.main.async {
                        self.showAlertController(title: "error", message: "invalid token", handler: nil)
                    }
                    print("Error: \(error.localizedDescription)")
                }
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode([DataModel].self, from: data)
                completion(decodedData)
            } catch {
                DispatchQueue.main.async {
                    self.showAlertController(title: "error", message: "invalid token", handler: nil)
                }
                print("Decoding error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    func showAlertController(title: String?, message: String?, handler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(ac, animated: true, completion: nil)
    }
}
