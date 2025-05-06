//
//  ViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 29.03.24.
//

import UIKit
//import SVProgressHUD

class ViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // - Data
    private var name = "User1"
    private var mass = [ProfileModel]()
    private var id = ""
    private var timer: Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideHeaderAfterDelay()
        configureNavBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
}

// MARK: -
// MARK: - Configure

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mass.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatsCollectionViewCell", for: indexPath) as! ChatsCollectionViewCell
        cell.setupCell(mass[indexPath.item])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "SupportChat", bundle: nil).instantiateInitialViewController() as! SupportChatViewController
        vc.room = mass[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: -
// MARK: - Configure

private extension ViewController {
    
    func configure() {
        configureCollectioView()
        configureLoadChats()
    }
    private func hideHeaderAfterDelay() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] timer in
            self?.configureLoadChats()
        }
    }
    
    func configureLoadChats() {
        activityIndicator.startAnimating()
//        SVProgressHUD.show(withStatus: "Load chats..")
        DispatchQueue.global().async {
            self.fetchAvailableRooms { rooms in
                guard let rooms = rooms else { return }
                self.mass = rooms
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
//                    SVProgressHUD.dismiss()
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    func configureCollectioView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configureNavBar() {
        if let nb = navigationController?.navigationBar {
            UIView.transition(with: nb, duration: 0.2, options: .transitionCrossDissolve, animations: {
                nb.isHidden = false
            })
        }
    }
    

    func fetchAvailableRooms(completion: @escaping ([ProfileModel]?) -> Void) {
        // URL сервера WebSocket
        guard let roomsUrl = URL(string: "http://localhost:6969/rooms") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        // Создание сессии
        let session = URLSession.shared

        // Создание запроса
        let task = session.dataTask(with: roomsUrl) { (data, response, error) in
            // Проверка на наличие ошибки
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            // Проверка на успешный ответ
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                completion(nil)
                return
            }

            // Проверка наличия данных
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            // Обработка данных (список комнат)
            do {
                let decoder = JSONDecoder()
                let models = try decoder.decode([ProfileModel].self, from: data)
                completion(models)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }

        // Запуск запроса
        task.resume()
    }
}
