//
//  HomeModel.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/9.
//  Copyright © 2015年 YY. All rights reserved.
//

import Foundation
import Photos

class HomeModel {

    var assetAry = [PHAsset]()
    
    func getVideoFromPhotoApp() {
        
        let smartAlbum = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumVideos, options: nil)
        let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(smartAlbum.firstObject as! PHAssetCollection , options: nil)
        
        for var i = 0; i < assetsFetchResult.count; i++ {
            assetAry += [assetsFetchResult.objectAtIndex(i) as! PHAsset]
        }
        
        
    }
    
}
