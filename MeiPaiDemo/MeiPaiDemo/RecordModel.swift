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
        
        func createEndingVideo() {
            guard outputFileUrlAry.count > 0 else { return }
            
            let endAsset = AVAsset(URL: outputFileUrlAry.last!)
            
            let mixComposition = AVMutableComposition()
            var instructionAry = [AVMutableVideoCompositionLayerInstruction]()
            let mainInstruction = AVMutableVideoCompositionInstruction()
            
            let endTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try endTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,endAsset.duration),
                    ofTrack: endAsset.tracksWithMediaType(AVMediaTypeVideo).first!,
                    atTime: kCMTimeZero)
            } catch  {
                return
            }
            
            let endInstruction = videoCompositionInstructionForTrack(endTrack, asset: endAsset)

            instructionAry += [endInstruction]
            
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, endAsset.duration)
            mainInstruction.layerInstructions = instructionAry
            
            // 处理特效
            let mainComposition = AVMutableVideoComposition()
            mainComposition.frameDuration = CMTimeMake(1, 30)
            mainComposition.instructions = [mainInstruction]
            mainComposition.renderSize = UIScreen.mainScreen().bounds.size
            
            applyVideoEffectsToComposition(mainComposition, rect: UIScreen.mainScreen().bounds)
            
            let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
            exporter?.outputURL = outputFileUrl
            exporter?.outputFileType = AVFileTypeQuickTimeMovie;
            exporter?.shouldOptimizeForNetworkUse = true;
            exporter?.videoComposition = mainComposition
            
            
            exporter?.exportAsynchronouslyWithCompletionHandler() {
                dispatch_async(dispatch_get_main_queue()) {
                    self.outputFilePathAry += [self.outputFilePath]
                    mergeVideo()
                }
            }
        }
        
        func mergeVideo() {
            
            let assertAry = outputFileUrlAry.map({ return AVAsset(URL: $0) })
            let endAsset = AVAsset(URL: outputFileUrlAry.last!)
            
            let mixComposition = AVMutableComposition()
            var instructionAry = [AVMutableVideoCompositionLayerInstruction]()
            let mainInstruction = AVMutableVideoCompositionInstruction()
            
            // 正片的track
            let videoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            var videoTimeDuration = kCMTimeZero
            for var i = 0; i < assertAry.count - 1; i++ {
                
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
            
            let instruction = videoCompositionInstructionForTrack(videoTrack, asset:assertAry.first!)
            instruction.setOpacity(0, atTime: videoTimeDuration) //遮挡后面轨道的图像
            
            // 片尾的track
            let endTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try endTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, endAsset.duration),
                    ofTrack: endAsset.tracksWithMediaType(AVMediaTypeVideo).first!,
                    atTime: videoTimeDuration)
            } catch  {
                return
            }
            let endInstruction = videoCompositionInstructionForTrack(endTrack, asset: endAsset)
            
            instructionAry += [instruction]
            instructionAry += [endInstruction]
            
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(videoTimeDuration, endAsset.duration))
            mainInstruction.layerInstructions = instructionAry

            // 处理特效
            let mainComposition = AVMutableVideoComposition()
            mainComposition.frameDuration = CMTimeMake(1, 30)
            mainComposition.instructions = [mainInstruction]
            mainComposition.renderSize = UIScreen.mainScreen().bounds.size
            
            let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
            exporter?.outputURL = finalUrl
            exporter?.outputFileType = AVFileTypeQuickTimeMovie;
            exporter?.shouldOptimizeForNetworkUse = true;
            exporter?.videoComposition = mainComposition
            
            
            exporter?.exportAsynchronouslyWithCompletionHandler() {
                dispatch_async(dispatch_get_main_queue()) {
                    
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
        
        // 先制作片尾(为了可以自定义动画在上面) -> 正片为一个track、片尾为另一个track
        createEndingVideo()
    
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
        
        if assetInfo.isPortrait { // 竖屏拍摄

            scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor),
                atTime: kCMTimeZero)
            
        } else {

//            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
//            var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.width / 2))
//            if assetInfo.orientation == .Down {
//                let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
//                let windowBounds = UIScreen.mainScreen().bounds
//                let yFix = assetTrack.naturalSize.height + windowBounds.height
//                let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
//                concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
//            }
//            instruction.setTransform(concat, atTime: kCMTimeZero)
        }
        
        return instruction
    }
    
    func applyVideoEffectsToComposition(composition: AVMutableVideoComposition, rect: CGRect) {
        
        let videoLayer = CALayer()
        let parentLayer = CALayer()
        let maskLayer = CALayer()
        let textLayer = CATextLayer()
        
        maskLayer.frame = rect
        videoLayer.frame = rect
        parentLayer.frame = rect
        textLayer.string = "chun.."
        textLayer.position = CGPointMake(rect.size.width / 2, rect.size.height / 2)
        
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(maskLayer)
        parentLayer.addSublayer(textLayer)
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
        
        let contentImage = CIImage(CGImage: (UIImage(named: "Baby-Lufy")?.CGImage)!)
        maskLayer.contents = contentImage
        
        // filter
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(contentImage, forKey: kCIInputImageKey)
        filter?.setValue(2, forKey: "inputRadius")
        
        guard let filterCIImage = filter?.outputImage else { return }
        let filterImage = context.createCGImage(filterCIImage, fromRect: filterCIImage.extent)
        
        // animation
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 1
        
        maskLayer.addAnimation(transition, forKey: nil)
        maskLayer.contents = filterImage
        
    }
    
    // MARK: - Public Method
    func addNewVideoFilePath() {
        outputFilePathAry += [outputFilePath]
    }

}
