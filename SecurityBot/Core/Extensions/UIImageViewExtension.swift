//
//  UIImageViewExtension.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.11.22.
//

import UIKit
import Photos

extension UIImageView {
    
    func setImage(_ image: UIImage?, animated: Bool = true) {
        let duration = animated ? 0.6 : 0.0
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.image = image
        }, completion: nil)
    }
    
    func fetchImageAsset(_ asset: PHAsset?, targetSize size: CGSize, contentMode: PHImageContentMode = .aspectFill, options: PHImageRequestOptions? = nil, completionHandler: ((Bool) -> Void)?) {
        guard let asset = asset else {
            completionHandler?(false)
            return
        }
        
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            self.image = image
            completionHandler?(true)
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    
}
