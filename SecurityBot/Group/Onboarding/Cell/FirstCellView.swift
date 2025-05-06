//
//  FirstCellView.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 4.10.22.
//

import Foundation
import UIKit
import Lottie


class FirstCellView: UICollectionViewCell{
    
    // - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView!
        
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//    }
//    
    override func prepareForReuse() {
        super.prepareForReuse()
        animationView.stop()
    }
    
    func set(screen: FirstScreenAnimationModel) {
        titleLabel.text = screen.title
        animationView.animation = LottieAnimation.named(screen.animation)
        animationView.loopMode = .playOnce
//        animationView.play()
    }
    
    func configureObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        animationView.play()
    }
}
