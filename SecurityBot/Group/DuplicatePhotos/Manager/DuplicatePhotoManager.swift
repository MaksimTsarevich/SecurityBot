//
//  DuplicatePhotoManager.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.11.22.
//

import Foundation
import Photos
import CocoaImageHashing

class DuplicatePhotoManager {
    
    static let shared = DuplicatePhotoManager()
    
    enum Strictness {
        case similar
        case closeToIdentical
    }
    
    func searchDuplicatePhotos(assets: [PHAsset], strictness: Strictness) -> [[PHAsset]] {
        let rawTuples: [OSTuple<NSString, NSData>] = assets.enumerated().map { (index, asset) -> OSTuple<NSString, NSData> in
            let imageData = asset.thumbnailSync?.pngData()
            return OSTuple<NSString, NSData>.init(first: "\(index)" as NSString, andSecond: imageData as NSData?)
        }
        let toCheckTuples = rawTuples.filter({ $0.second != nil })
        
        let providerId = OSImageHashingProviderIdForHashingQuality(.medium)
        let provider = OSImageHashingProviderFromImageHashingProviderId(providerId);
        let defaultHashDistanceTreshold = provider.hashDistanceSimilarityThreshold()
        let hashDistanceTreshold: Int64
        switch strictness {
        case .similar:
            hashDistanceTreshold = defaultHashDistanceTreshold
        case .closeToIdentical:
            hashDistanceTreshold = 1
        }
        
        let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(withProvider: providerId, withHashDistanceThreshold: hashDistanceTreshold, forImages: toCheckTuples)
        var duplicateGroups = [[PHAsset]]()
        var assetToGroupIndex = [PHAsset: Int]()
        for pair in similarImageIdsAsTuples {
            let assetIndex1 = Int(pair.first! as String)!
            let assetIndex2 = Int(pair.second! as String)!
            let asset1 = assets[assetIndex1]
            let asset2 = assets[assetIndex2]
            let groupIndex1 = assetToGroupIndex[asset1]
            let groupIndex2 = assetToGroupIndex[asset2]
            if groupIndex1 == nil && groupIndex2 == nil {
                duplicateGroups.append([asset1, asset2])
                let groupIndex = duplicateGroups.count - 1
                assetToGroupIndex[asset1] = groupIndex
                assetToGroupIndex[asset2] = groupIndex
            } else if groupIndex1 == nil && groupIndex2 != nil {
                duplicateGroups[groupIndex2!].append(asset1)
                assetToGroupIndex[asset1] = groupIndex2!
            } else if groupIndex1 != nil && groupIndex2 == nil {
                duplicateGroups[groupIndex1!].append(asset2)
                assetToGroupIndex[asset2] = groupIndex1!
            }
        }
        return duplicateGroups
    }
}
