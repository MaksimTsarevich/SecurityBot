//
//  ChatsCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 29.03.24.
//

import UIKit

class ChatsCollectionViewCell: UICollectionViewCell {
 
    // - UI
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameDiscriptionLabel: UILabel!
    
    func setupCell(_ model: ProfileModel) {
        nameLabel.text = model.login
        nameDiscriptionLabel.text = model.login.first?.uppercased()
        if !model.color.isEmpty {
            nameView.backgroundColor = AppPalette.color(fromHex: model.color)
            nameDiscriptionLabel.textColor = textColorForBackground(AppPalette.color(fromHex: model.color))
        }
    }
    
    func textColorForBackground(_ backgroundColor: UIColor) -> UIColor {
        // Получаем компоненты цвета фона
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Рассчитываем яркость цвета фона
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        // Определяем, какой текст будет лучше виден на этом фоне
        if brightness < 0.5 {
            return UIColor.white // Фон темный, используем белый текст
        } else {
            return UIColor.black // Фон светлый, используем черный текст
        }
    }
}
