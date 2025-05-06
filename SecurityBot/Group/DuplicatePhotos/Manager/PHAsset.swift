//
//  PHAsset.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.11.22.
//

import UIKit
import Photos

extension PHAsset {
    
    var thumbnailSync: UIImage? {
        var result: UIImage?
        let targetSize = CGSize(width: 300, height: 300)
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: self, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
            result = image
        }
        return result
    }
    
}
