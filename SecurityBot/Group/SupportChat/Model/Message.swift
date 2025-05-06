//
//  Message.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 25.03.24.
//

import Foundation
import Photos
import UIKit

struct Message: Codable {
    var message: String
    let senderUsername: String?
    let messageSender: MessageSender?
    var heightCell: CGFloat?
    var pathImage: String? // Используется для декодирования пути к изображению из JSON
    
    var image: UIImage? {
        if let pathImage = pathImage, let url = URL(string: pathImage), let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
    
    var replyName: String?
    var replyMessage: String?
    
    init(message: String, messageSender: MessageSender, username: String, pathImage: String? = nil) {
        self.messageSender = messageSender
        self.senderUsername = username
        self.pathImage = pathImage
        
        if message.contains("file@") {
            self.message = ""
            let newPath = message.replacingOccurrences(of: "@", with: ":")
            self.pathImage = newPath
        } else {
            self.message = message.withoutWhitespace()
        }
        
        let result = findWordsInString(inputString: message)
        replyName = result.user
        replyMessage = result.message
        
        if let replyName = replyName, let replyMessage = replyMessage {
            self.message = self.message.replacingOccurrences(of: "$user$\(replyName)$message$\(replyMessage)$", with: "")
        }
    }
    
    func findWordsInString(inputString: String) -> (user: String?, message: String?) {
        let pattern = "\\$user\\$(.*?)\\$message\\$(.*?)\\$"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: inputString, options: [], range: NSRange(location: 0, length: inputString.utf16.count))
            
            if let match = matches.first {
                let userRange = Range(match.range(at: 1), in: inputString)
                let messageRange = Range(match.range(at: 2), in: inputString)
                
                let user = userRange.map { String(inputString[$0]) }
                let message = messageRange.map { String(inputString[$0]) }
                
                return (user, message)
            }
        } catch {
            print("Error creating regex: \(error)")
        }
        
        return (nil, nil)
    }
}

enum MessageSender: String, Codable {
    case ourself
    case someoneElse
}

extension String {
    func withoutWhitespace() -> String {
        return self.replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\0", with: "")
    }
}


//struct Message {
//    var message: String
//    let senderUsername: String
//    let messageSender: MessageSender
//    var heightCell: CGFloat?
//    var image: UIImage?
//    var pathImage: String?
//    
//    var replyName: String?
//    var replyMessage: String?
//    
//    init(message: String, messageSender: MessageSender, username: String, image: UIImage?) {
//        self.messageSender = messageSender
//        self.senderUsername = username
//        self.image = image
//        if message.contains("file@") {
//            self.message = ""
//            let newPath = message.replacingOccurrences(of: "@", with: ":")
//            if let imageURL = URL(string: newPath), let imageData = try? Data(contentsOf: imageURL) {
//                if let image = UIImage(data: imageData) {
//                    self.image = image
//                } else {
//                    print("Не удалось создать изображение из данных")
//                }
//            } else {
//                print("Неверный путь к изображению")
//            }
//        } else {
//            self.message = message.withoutWhitespace()
//        }
//        let result = findWordsInString(inputString: message)
//        replyName = result.user ?? nil
//        replyMessage = result.message ?? nil
//        if let replyName = replyName, let replyMessage = replyMessage {
//            self.message = self.message.replacingOccurrences(of: "$user$\(replyName)$message$\(replyMessage)$", with: "")
//        }
//    }
//    
//    
//    func findWordsInString(inputString: String) -> (user: String?, message: String?) {
//        let pattern = "\\$user\\$(.*?)\\$message\\$(.*?)\\$"
//        
//        do {
//            let regex = try NSRegularExpression(pattern: pattern, options: [])
//            let matches = regex.matches(in: inputString, options: [], range: NSRange(location: 0, length: inputString.utf16.count))
//            
//            if let match = matches.first {
//                let userRange = Range(match.range(at: 1), in: inputString)
//                let messageRange = Range(match.range(at: 2), in: inputString)
//                
//                let user = userRange.map { String(inputString[$0]) }
//                let message = messageRange.map { String(inputString[$0]) }
//                
//                return (user, message)
//            }
//        } catch {
//            print("Error creating regex: \(error)")
//        }
//        
//        return (nil, nil)
//    }
//    
//    
//    
//}
//
//enum MessageSender {
//  case ourself
//  case someoneElse
//}
//
//extension String {
//  func withoutWhitespace() -> String {
//    return self.replacingOccurrences(of: "\n", with: "")
//      .replacingOccurrences(of: "\r", with: "")
//      .replacingOccurrences(of: "\0", with: "")
//  }
//}
