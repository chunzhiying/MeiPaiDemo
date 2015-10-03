//
//  RecordModel.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/3.
//  Copyright © 2015年 YY. All rights reserved.
//

import Foundation
import AVFoundation
import AssetsLibrary

struct RecordModel {

    // MARK: - Property
    private var outputFilePath: String {
        return NSTemporaryDirectory().stringByAppendingString("myMovie\(self.outputFilePathAry.count).mov")
    }
    var outputFileUrl: NSURL {
        return NSURL.fileURLWithPath(self.outputFilePath)
    }
    
    private var outputFilePathAry = [String]()
    private var outputFileUrlAry: [NSURL] {
        
        return outputFilePathAry.map({
            return NSURL.fileURLWithPath($0)
        })
    }
    
    private var finalUrl = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingString("myMovieFinal.mov"))
    
    
    // MARK: - Private Handel Video
    mutating func saveToCameraRoll(completion: () -> Void) {
        
        func mergeVideo() {
            let ary = outputFileUrlAry
            let assertAry = ary.map({ return AVAsset(URL: $0) })
            
            let mixComposition = AVMutableComposition()
            let videoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            var videoTimeDuration = kCMTimeZero
            for var i = 0; i < assertAry.count; i++ {
                let assert = assertAry[i]
                
                do {
                    try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, assert.duration),
                        ofTrack: assert.tracksWithMediaType(AVMediaTypeVideo).first!,
                        atTime: videoTimeDuration)
                } catch  {
                    continue
                }
                
                videoTimeDuration = CMTimeAdd(videoTimeDuration, assert.duration)
                
            }
            
            let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
            exporter?.outputURL = finalUrl
            exporter?.outputFileType = AVFileTypeQuickTimeMovie;
            exporter?.shouldOptimizeForNetworkUse = true;
            
            exporter?.exportAsynchronouslyWithCompletionHandler(){
                dispatch_async(dispatch_get_main_queue()){
                    saveVideo(exporter!)
                }
            }
            
        }
        
        func saveVideo(session: AVAssetExportSession) {
            if session.status == .Completed {
                ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(session.outputURL, completionBlock: { (url: NSURL!, error: NSError?) in
                    
                    if let errorDescription = error?.description {
                        print("写入错误:\(errorDescription)")
                    } else {
                        print("写入成功")
                    }
                    self.deleteTempVideo()
                    completion()
                })
                
            }
        }
        
        
        mergeVideo()
    }
    
    mutating func deleteTempVideo() {
        
        let fileManager = NSFileManager.defaultManager()
        for path in outputFilePathAry {
            do {
                try fileManager.removeItemAtPath(path)
            } catch {
                continue
            }
        }
        
        do {
            try fileManager.removeItemAtPath((finalUrl.path)!)
        } catch {}
        
        outputFilePathAry.removeAll()
        
    }
    
    // MARK: - Public Method
    mutating func addNewVideoFilePath() {
        outputFilePathAry += [outputFilePath]
    }

}
