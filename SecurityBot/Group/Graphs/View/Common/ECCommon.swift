//
//  ECCommon.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.03.24.
//

import Foundation
import UIKit


func ECLog<T>(_ message : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    
    #if DEBUG
        
        let fileName = (file as NSString).lastPathComponent
        print("\(fileName):\(lineNum)   \t-->\(message)");
        
    #endif
}

let  ECScreenW =  UIScreen.main.bounds.size.width
let  ECScreenH =  UIScreen.main.bounds.size.height

extension UIColor {
    //返回随机颜色
    class var randomColor: UIColor {
        get {
            let red = CGFloat(arc4random() % 256) / 255.0
            let green = CGFloat(arc4random() % 256) / 255.0
            let blue = CGFloat(arc4random() % 256) / 255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
