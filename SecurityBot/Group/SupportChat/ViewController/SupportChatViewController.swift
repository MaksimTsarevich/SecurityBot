//
//  SupportChatViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 20.03.24.
//

import UIKit
import Photos
//import Starscream

class SupportChatViewController: UIViewController, URLSessionDelegate {
    
    // - UI
    private let imageView = UIImageView()
    private let bottomView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton()
    private let tableView = UITableView()
    private let flipButton = UIButton()
    private let micButton = UIButton()
    private let closeButton = UIButton()
    
    private let replyView = UIView()
    private let replyUserLabel = UILabel()
    private let replyMessageLabel = UILabel()
    private let replyButton = UIButton()
    
    // - Data
    private var model = UserDefaultsManager().getProfile()
    var room = ProfileModel()
//    var room = ""
    lazy var webSocketTask = URLSession.shared.webSocketTask(with: URL(string: "ws://localhost:6969/ws?room=\(model.isAdmin ? room.login : model.login)")!)
    
//    let chatRoom = ChatRoom()
    var messages: [Message] = []
    var heightTable: CGFloat = 0
    var newHeightTable: CGFloat = 0
    var keyboardHeight: CGFloat = 0
    var photos = [PHAsset]()
    var mic = true
    var reply = false
    var replyUser = ""
    var replyMessage = ""
    
    // - DataSource
    private var dataSource: TableDataSource!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNavBar()
        model = UserDefaultsManager().getProfile()
//        registration(user1Id: 3, user2Id: 2, password: "asd", message: "qwerty", {token,error in
//            print(error)
//        })
        getChats(id1: model.id, id2: model.isAdmin ? room.id : 1, completion: { [weak self] messages in
            guard let messages = messages else { return }
//            self?.updateMessages(messages)
            messages.forEach { message in
                DispatchQueue.main.async {
                    if let message = self?.checkMessage(message.message) {
                        self?.dataSource.insertNewMessageCell(message)
                    }
                }
            }
            self?.messages = messages
//            print(messages)
        })
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        configureNavBar()
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webSocketTask.cancel()
    }
    
    func receiveMessage() {
        webSocketTask.receive { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        if let message = sSelf.checkMessage(text) {
                            DispatchQueue.main.async {
                                sSelf.dataSource.insertNewMessageCell(message)
                            }
                        }
                    }
                case .string(let text):
                    if let message = sSelf.checkMessage(text) {
                        DispatchQueue.main.async {
                            sSelf.dataSource.insertNewMessageCell(message)
                        }
                    }
                @unknown default:
                    print("Unknown message type received")
                }
                sSelf.receiveMessage()
            case .failure(let error):
                print("Error receiving message: \(error)")
            }
        }
    }
    
    func sendMessageApi(_ message: String) {
        let data = URLSessionWebSocketTask.Message.string(message)
        webSocketTask.send(data) { [weak self] error in
            guard let sSelf = self else { return }
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                print("Message sent successfully")
            }
        }
    }
    
    func checkMessage(_ message: String) -> Message? {
        var mess = message
        if let range = mess.range(of: "User: ") {
            mess.removeSubrange(range)
        }
        let components = mess.components(separatedBy: ": ")
        if components.count == 2 {
            let name = components[0]
            let message = components[1]
            let messageSender: MessageSender = (self.model.login == name) ? .ourself : .someoneElse
            let model = Message(message: message, messageSender: messageSender, username: name)
            print("\(message) + \(name) + \(messageSender)")
            return model
        } else {
            print("Строка не содержит имя и сообщение в нужном формате.")
            return nil
        }
    }
    
    func getChats(id1: Int, id2: Int, completion: @escaping ([Message]?) -> Void) {
        let urlString = "http://localhost:6969/getchats"
        
        guard let url = URL(string: urlString) else {
//            completion?([])
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData: [String: Any] = ["user1id": id1, "user2id": id2]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            request.httpBody = jsonData
        } catch {
            print("Error converting data to JSON: \(error.localizedDescription)")
            completion(nil)
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: request) { [weak self] (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    return
                }
            }
            guard let data = data else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601 // Настраиваем формат даты, если в JSON используется ISO8601
                    
                    do {
                        let messages = try decoder.decode([Message].self, from: data)
                        completion(messages)
                    } catch {
                        print("Ошибка при декодировании JSON: \(error)")
                        completion(nil)
                    }
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    if let token = json["message"] as? String {
//                        
//                        print(token)
//                    } else if let error = json["error"] as? Int{
//                        completion(nil)
//                    }
//                } else {
//                    print("Unable to convert data to JSON.")
//                    completion(nil)
//                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}

private extension SupportChatViewController {
    
    func configure() {
        configureChat()
        configureBottomView()
        configureDataSource()
        subscribeToKeyboardNotification()
        addAction()
    }
    
    func configureNavBar() {
        if let nb = navigationController?.navigationBar {
            UIView.transition(with: nb, duration: 0.2, options: .transitionCrossDissolve, animations: {
                nb.isHidden = false
            })
        }
    }
    
    func configureChat() {
        model = UserDefaultsManager().getProfile()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.webSocketTask.resume()
            self?.receiveMessage()
            DispatchQueue.main.async {
//                self?.sendMessageApi("John: Hello, WebSocket!")
            }
        }
    }
    
    func configureBottomView() {
        
        view.backgroundColor = AppPalette.backgroundMain2
        
        bottomView.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.937, alpha: 1)
        bottomView.frame = CGRect(x: 0, y: Int(UIScreen.main.bounds.height) - 60, width: Int(UIScreen.main.bounds.width), height: 60)
        
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        
        tableView.frame = CGRect(x: 0, y: 91, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - bottomView.bounds.height)
        tableView.clipsToBounds = true
        
        view.addSubview(bottomView)
        
        replyView.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.937, alpha: 1)
        replyView.frame = CGRect(x: 0, y: bottomView.frame.minY - 50, width: UIScreen.main.bounds.width, height: 50)
        view.addSubview(replyView)
        
        replyUserLabel.text = "Reply to Maks Tsarevich"
        replyUserLabel.textColor = .systemBlue
        replyUserLabel.frame = CGRect(x: 45, y: 5, width: 200, height: 20)
        replyUserLabel.font = UIFont.systemFont(ofSize: 14)
        replyView.addSubview(replyUserLabel)
        
        replyView.isHidden = true
        
        replyMessageLabel.text = "dffdgdfgfdg"
        replyMessageLabel.textColor = .black
        replyMessageLabel.font = UIFont.systemFont(ofSize: 14)
        replyMessageLabel.frame = CGRect(x: 45, y: 25, width: 200, height: 20)
        replyView.addSubview(replyMessageLabel)
        
        replyButton.backgroundColor = .clear
        replyButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        replyButton.tintColor = .systemBlue
        replyButton.frame = CGRect(x: replyView.bounds.width - 30, y: (replyView.bounds.height / 2) - 10, width: 20, height: 20)
        replyView.addSubview(replyButton)
        
        tableView.alpha = 0
        heightTable = tableView.bounds.height
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.937, alpha: 1)
        
        view.frame = CGRect(x: 0, y: 5, width: UIScreen.main.bounds.width, height: 26)
        bottomView.addSubview(view)
        
        
        flipButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        flipButton.tintColor = UIColor(red: 0.553, green: 0.565, blue: 0.576, alpha: 1)
        view.addSubview(flipButton)
        flipButton.frame = CGRect(x: 5, y: 0, width: 26, height: 26)

        sendButton.backgroundColor = .systemBlue
        sendButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        sendButton.tintColor = .white
        view.addSubview(sendButton)
        sendButton.frame = CGRect(x: bottomView.bounds.width - 35, y: 0, width: 26, height: 26)
        sendButton.layer.cornerRadius = 13
        
        micButton.backgroundColor = .clear
        micButton.setImage(UIImage(systemName: "mic"), for: .normal)
        micButton.tintColor = .lightGray
        view.addSubview(micButton)
        micButton.frame = CGRect(x: bottomView.bounds.width - 35, y: -2, width: 26, height: 26)
        
        let textView = UIView()
        textView.backgroundColor = .white
        view.addSubview(textView)
        textView.frame = CGRect(x: Int(flipButton.bounds.width + 9), y: 0, width: Int(sendButton.frame.minX - (flipButton.bounds.width + 9) - 4), height: 26)
        textView.layer.cornerRadius = 13
        
        let smileButton = UIButton()
        smileButton.setImage(UIImage(systemName: "smiley"), for: .normal)
        smileButton.tintColor = UIColor(red: 0.553, green: 0.565, blue: 0.576, alpha: 1)
        textView.addSubview(smileButton)
        smileButton.frame = CGRect(x: Int(textView.bounds.maxX) - 25, y: 3, width: 20, height: 20)
        
        textView.addSubview(messageTextField)
        messageTextField.placeholder = "Message..."
        messageTextField.frame = CGRect(x: 5, y: 2, width: Int(smileButton.frame.minX) - 15, height: 20)
        messageTextField.font = UIFont.systemFont(ofSize: 14)
        messageTextField.delegate = self
        
        sendButton.alpha = 0
        sendButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
    
    func configureDataSource() {
        tableView.separatorStyle = .none
        dataSource = TableDataSource(tableView: tableView, messages: messages, delegate: self)
        tableView.clipsToBounds = true
    }
    
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addAction() {
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        flipButton.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
        micButton.addTarget(self, action: #selector(changeTypeLive), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(crossReply), for: .touchUpInside)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressButtonLongPressed(_:)))
        micButton.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // - Action
    @objc func dismissScreen() {
        dismiss(animated: true)
    }
    
    @objc func crossReply() {
        replyView.isHidden = true
        reply = false
        
        var cellHeights: CGFloat = 30
        for i in 0..<messages.count {
            if let height = messages[i].heightCell {
                cellHeights += height
            }
        }
        var newY = heightTable - cellHeights
        var height = cellHeights
        if keyboardHeight > 0 {
             newY = heightTable - cellHeights - keyboardHeight + 20
            if reply {
                newY -= replyView.bounds.height
            }
        }
        
        if height < heightTable - 91 {
            if height > bottomView.frame.minY - 91 {
                tableView.isScrollEnabled = true
                height = bottomView.frame.minY - 91
            }
            newHeightTable = height
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: newY < 91 ? 91 : newY, width: UIScreen.main.bounds.width, height: CGFloat(sSelf.reply ? height - sSelf.replyView.bounds.height : height))
            }
        } else {
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: 91, width: UIScreen.main.bounds.width, height: sSelf.reply ? sSelf.heightTable - 91 - sSelf.keyboardHeight + 20 - sSelf.replyView.bounds.height : sSelf.heightTable - 91 - sSelf.keyboardHeight + 20)
            }
            tableView.isScrollEnabled = true
        }
    }
    
    @objc func sendMessage() {
        if let text = messageTextField.text {
            if !text.isEmpty {
                var newText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if reply {
                    newText += "$user$\(replyUser)"
                    newText += "$message$\(replyMessage)$"
                }
                sendPostRequest(userid1: model.id, userid2: model.isAdmin ? room.id : 1, message: "\(model.login): \(newText)")
                sendMessageApi("\(model.login): \(newText)")
                messageTextField.text = ""
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.micButton.alpha = 1
                }
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.sendButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    self?.sendButton.alpha = 0
                }
            }
        }
        replyUser = ""
        replyMessage = ""
        replyView.isHidden = true
        reply = false
        var cellHeights: CGFloat = 30
        for i in 0..<messages.count {
            if let height = messages[i].heightCell {
                cellHeights += height
            }
        }
        var newY = heightTable - cellHeights
        var height = cellHeights
        if keyboardHeight > 0 {
             newY = heightTable - cellHeights - keyboardHeight + 20
            if reply {
                newY -= replyView.bounds.height
            }
        }
        
        if height < heightTable - 91 {
            if height > bottomView.frame.minY - 91 {
                tableView.isScrollEnabled = true
                height = bottomView.frame.minY - 91
            }
            newHeightTable = height
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: newY < 91 ? 91 : newY, width: UIScreen.main.bounds.width, height: CGFloat(sSelf.reply ? height - sSelf.replyView.bounds.height : height))
            }
        } else {
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: 91, width: UIScreen.main.bounds.width, height: sSelf.reply ? sSelf.heightTable - 91 - sSelf.keyboardHeight + 20 - sSelf.replyView.bounds.height : sSelf.heightTable - 91 - sSelf.keyboardHeight + 20)
            }
            tableView.isScrollEnabled = true
        }
    }
    
    @objc func longPressButtonLongPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                if mic {
                    print("Кнопка была длительно нажата mic")
                } else {
                    print("video")
                }
            }
        }
    
    @objc func changeTypeLive() {
        micButton.setImage(UIImage(systemName: mic ? "camera.metering.partial" : "mic"), for: .normal)
        mic = !mic
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.keyboardHeight = keyboardHeight
            bottomView.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - 20))
            var cellHeights: CGFloat = 30
            for i in 0..<messages.count {
                if let height = messages[i].heightCell {
                    cellHeights += height
                }
            }
            if cellHeights + keyboardHeight < (heightTable - 20) {
                var newY = heightTable - cellHeights - keyboardHeight + 20
                if reply {
                    newY -= replyView.bounds.height
                }
                let height = cellHeights
                UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                    guard let sSelf = self else { return }
                    sSelf.tableView.frame = CGRect(x: 0, y: newY, width: UIScreen.main.bounds.width, height: CGFloat(height))
                }
            } else {
                tableView.frame = CGRect(x: 0, y: 91, width: Int(UIScreen.main.bounds.width), height: Int(reply ? newHeightTable - replyView.bounds.height : newHeightTable))
            }
//            tableView.scrollToRow(at: IndexPath(row: dataSource.getMessagesLast(), section: 0), at: .bottom, animated: true)
        } else {
            print("dissmis")
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        bottomView.transform = .identity
        print("dissmis")
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc func showPicker() {

    }
}

// MARK: -
// MARK: - Delegate

extension SupportChatViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = messageTextField.text else {
            return true
        }
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if updatedText.isEmpty {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.micButton.alpha = 1
            }
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.sendButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self?.sendButton.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.micButton.alpha = 0
            }
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.sendButton.transform = .identity
                self?.sendButton.alpha = 1
            }
        }
        return true
    }
}

// MARK: -
// MARK: - Delegate

extension SupportChatViewController: TableDataSourceDelegate {
    func resendMessageFrame(_ rect: CGRect, message: Message) {
//        let vc = UIStoryboard(name: "Resend", bundle: nil).instantiateInitialViewController() as! ResendViewController
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overCurrentContext
//        vc.messageView.frame = rect
//        vc.message = message
//        vc.delegate = self
//        present(vc, animated: true)
    }
    
    func updateMessages(_ messages: [Message]) {
        self.messages = messages
        var cellHeights: CGFloat = 30
        for i in 0..<messages.count {
            if let height = messages[i].heightCell {
                cellHeights += height
            }
        }
        var newY = heightTable - cellHeights
        var height = cellHeights
        if keyboardHeight > 0 {
             newY = heightTable - cellHeights - keyboardHeight + 20
            if reply {
                newY -= replyView.bounds.height
            }
        }
        
        if height < heightTable - 91 {
            if height > bottomView.frame.minY - 91 {
                tableView.isScrollEnabled = true
                height = bottomView.frame.minY - 91
            }
            newHeightTable = height
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: newY < 91 ? 91 : newY, width: UIScreen.main.bounds.width, height: CGFloat(sSelf.reply ? height - sSelf.replyView.bounds.height : height))
            }
        } else {
            UIView.transition(with: tableView, duration: 0.3) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.tableView.frame = CGRect(x: 0, y: 91, width: UIScreen.main.bounds.width, height: sSelf.reply ? sSelf.heightTable - 91 - sSelf.keyboardHeight + 20 - sSelf.replyView.bounds.height : sSelf.heightTable - 91 - sSelf.keyboardHeight + 20)//20
            }
            tableView.isScrollEnabled = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.alpha = 1
        }
    }

    func sendPostRequest(userid1: Int, userid2: Int, message: String) {
        // Создаем URL запроса
        guard let url = URL(string: "http://localhost:6969/addchat") else {
            print("Invalid URL")
            return
        }
        
        // Создаем данные для отправки
//        let jsonData = try? JSONSerialization.data(withJSONObject: [
//            "user1": [
//                "user1id": userid1,
//                "login": "user1@example.com"
//            ],
//            "user2": [
//                "user1id": userid2,
//                "login": "user2@example.com"
//            ],
//            "message": "\(message)"
//        ])
        
        // Подготавливаем URLRequest
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData: [String: Any] = ["user1id": userid1, "user2id": userid2, "message": "\(message)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            request.httpBody = jsonData
        } catch {
            print("Error converting data to JSON: \(error.localizedDescription)")
//            completion(nil)
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: request) { [weak self] (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    return
                }
            }
            guard let data = data else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601 // Настраиваем формат даты, если в JSON используется ISO8601
                    
                    do {
                        let messages = try decoder.decode([Message].self, from: data)
//                        completion(messages)
                    } catch {
                        print("Ошибка при декодировании JSON: \(error)")
//                        completion(nil)
                    }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
//                completion(nil)
            }
        }.resume()
        
//        // Отправляем запрос
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            // Проверяем наличие ошибки
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            
//            // Проверяем успешный ли ответ
//            guard let httpResponse = response as? HTTPURLResponse,
//                  (200...299).contains(httpResponse.statusCode) else {
//                print("Invalid response")
//                return
//            }
//            
//            // Проверяем наличие данных
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//            
//            if let responseData = String(data: data, encoding: .utf8) {
//                print("Response data: \(responseData)")
//            }
//        }
//        
//        // Запускаем запрос
//        task.resume()
    }
    
//    func getChats(id1: Int, id2: Int, completion: @escaping ([Message]?) -> Void) {
//        let urlString = "http://localhost:6969/getchats"
//        
//        guard let url = URL(string: urlString) else {
////            completion?([])
//            completion(nil)
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let requestData: [String: Any] = ["user1id": id1, "user2id": id2, "message": "\(message)"]
//        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
//            request.httpBody = jsonData
//        } catch {
//            print("Error converting data to JSON: \(error.localizedDescription)")
//            completion(nil)
//        }
//        
//        let configuration = URLSessionConfiguration.ephemeral
//        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
//        
//        session.dataTask(with: request) { [weak self] (data, response, error) in
//            if let httpResponse = response as? HTTPURLResponse {
//                print("Status code: \(httpResponse.statusCode)")
//                if httpResponse.statusCode != 200 {
//                    return
//                }
//            }
//            guard let data = data else {
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                }
//                return
//            }
//            
//            do {
//                
//                let decoder = JSONDecoder()
//                    decoder.dateDecodingStrategy = .iso8601 // Настраиваем формат даты, если в JSON используется ISO8601
//                    
//                    do {
//                        let messages = try decoder.decode([Message].self, from: data)
//                        completion(messages)
//                    } catch {
//                        print("Ошибка при декодировании JSON: \(error)")
//                        completion(nil)
//                    }
//            } catch {
//                print("Error parsing JSON: \(error.localizedDescription)")
//                completion(nil)
//            }
//        }.resume()
//    }
}
