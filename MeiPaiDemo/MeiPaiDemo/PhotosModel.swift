//
//  PhotosModel.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/9.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit
import Foundation
import Photos

struct PhotosModelNotification {
    static let photoUpdated = "photoUpdated"
}

class PhotosModel: NSObject {

    static let shareInstance = PhotosModel()

    var assetAry = [PHAsset]()
    
    private var imageAry = [UIImage]()
    private var avAssetAry = [AVAsset]()
    private var targetSize: CGSize!
    
    private override init() {
        super.init()
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    func getVideoAssetFromPhotoAppWithTargetSize(targetSize: CGSize) {
        self.targetSize = targetSize
        assetAry.removeAll()
        
        let smartAlbum = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumVideos, options: nil)
        let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(smartAlbum.firstObject as! PHAssetCollection , options: nil)
        
        for var i = 0; i < assetsFetchResult.count; i++ {
            let phAsset = assetsFetchResult.objectAtIndex(i) as! PHAsset
            assetAry += [phAsset]
        }
        
    }
    
    func getVideoImageByAsset(asset: PHAsset, complete: (UIImage) -> Void) {
        
        // 当targetSize = PHImageManagerMaximumSize，info中有视频的url，但是image为nil，targetSize为具体size时，有image，但是info中没有url
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode:.AspectFit, options: nil) { imageOpt, infoOpt in
            
            guard let image = imageOpt else { return }
            complete(image)
        }
    }
    
    func getVideoAssetByAsset(asset: PHAsset, complete: (AVAsset) -> Void) {
        
        PHImageManager.defaultManager().requestAVAssetForVideo(asset, options: nil) { avAssetOpt, avAudioMixOpt, infoOpt in
            
            guard let avAsset = avAssetOpt else { return }
            complete(avAsset)
        }

    }
    
    func postNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(PhotosModelNotification.photoUpdated, object: nil)
    }
    
}

extension PhotosModel: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(changeInstance: PHChange) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.getVideoAssetFromPhotoAppWithTargetSize(self.targetSize)
            self.postNotification()
        }
        
    }
    
}
