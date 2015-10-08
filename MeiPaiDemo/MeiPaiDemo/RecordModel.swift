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

class RecordModel {

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
    func saveToCameraRoll(completion: () -> Void) {
        
        func mergeVideo() {
            let ary = outputFileUrlAry
            let assertAry = ary.map({ return AVAsset(URL: $0) })
            
            let mixComposition = AVMutableComposition()
            var instructionAry = [AVMutableVideoCompositionLayerInstruction]()
            let mainInstruction = AVMutableVideoCompositionInstruction()
            
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
            
            // 处理方向，只是用一个video track，把assert都插入到这个track, 通过第一个assert来作为代表判断方向
            let instruction = videoCompositionInstructionForTrack(videoTrack, asset: assertAry.first!)
            instruction.setOpacity(0, atTime: videoTimeDuration)
            instructionAry += [instruction]
            
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTimeDuration)
            mainInstruction.layerInstructions = instructionAry

            // 处理特效
            let mainComposition = AVMutableVideoComposition()
            mainComposition.frameDuration = CMTimeMake(1, 30)
            mainComposition.instructions = [mainInstruction]
            mainComposition.renderSize = UIScreen.mainScreen().bounds.size
            
            applyVideoEffectsToComposition(mainComposition, rect: UIScreen.mainScreen().bounds)
            
            let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
            exporter?.outputURL = finalUrl
            exporter?.outputFileType = AVFileTypeQuickTimeMovie;
            exporter?.shouldOptimizeForNetworkUse = true;
            exporter?.videoComposition = mainComposition
            
            exporter?.exportAsynchronouslyWithCompletionHandler(){
                dispatch_async(dispatch_get_main_queue()){
                    saveVideo(exporter!)
                }
            }
            
        }
        
        func saveVideo(session: AVAssetExportSession) {
            if session.status == .Completed {
                ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(session.outputURL) { (url: NSURL!, error: NSError?) in
                    
                    if let errorDescription = error?.description {
                        print("写入错误:\(errorDescription)")
                    } else {
                        print("写入成功")
                    }
                    self.deleteTempVideo()
                    completion()
                }
                
            }
        }
        
        
        mergeVideo()
    }
    
    func deleteTempVideo() {
        
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
    
    // MARK: - Tool
    // Handle Video Orientation
    func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.Up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .Right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .Left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .Up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .Down
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {

        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] 
        

        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        var scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.width
        
        if assetInfo.isPortrait {

            scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor),
                atTime: kCMTimeZero)
            
        } else {

            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.width / 2))
            if assetInfo.orientation == .Down {
                let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
                let windowBounds = UIScreen.mainScreen().bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
                concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
            }
            instruction.setTransform(concat, atTime: kCMTimeZero)
        }
        
        return instruction
    }
    
    func applyVideoEffectsToComposition(composition: AVMutableVideoComposition, rect: CGRect) {
        
    }
    
    // MARK: - Public Method
    func addNewVideoFilePath() {
        outputFilePathAry += [outputFilePath]
    }

}
