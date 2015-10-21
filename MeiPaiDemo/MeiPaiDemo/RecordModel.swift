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
            
        }
        
        func mergeVideo() {
            
            guard outputFileUrlAry.count > 1 else {
                saveVideo(outputFileUrlAry.first!)
                return }
            
            let assertAry: [AVAsset?] = outputFileUrlAry.map({ return AVAsset(URL: $0) })
            
            let mixComposition = AVMutableComposition()
            var instructionAry = [AVMutableVideoCompositionLayerInstruction]()
            let mainInstruction = AVMutableVideoCompositionInstruction()
            
            // 正片的track
            let videoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            var videoTimeDuration = kCMTimeZero
            for var i = 0; i < assertAry.count; i++ {
                
                guard let assert = assertAry[i] else { continue }
                do {
                    try videoTrack.insertTimeRange(CMTimeRangeMake(CMTimeMake(1, 15), assert.duration),
                        ofTrack: assert.tracksWithMediaType(AVMediaTypeVideo).first!,
                        atTime: videoTimeDuration)
                } catch  {
                    continue
                }
                
                videoTimeDuration = CMTimeAdd(videoTimeDuration, assert.duration)
            }
            
            let instruction = videoCompositionInstructionForTrack(videoTrack, asset:assertAry.first!!)
            instruction.setOpacity(0, atTime: videoTimeDuration) //遮挡后面轨道的图像
            
            instructionAry += [instruction]
            
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTimeDuration)
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
                    
                    if exporter?.status == .Completed {
                        saveVideo(exporter!.outputURL!)
                    }
                }
            }
            
        }
        
        func saveVideo(url: NSURL) {
            ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(url) { (url: NSURL!, error: NSError?) in
                
                if let errorDescription = error?.description {
                    print("写入错误:\(errorDescription)")
                } else {
                    print("写入成功")
                }
                
                self.deleteTempVideo()
                completion()
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
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {

        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] 
        
        let scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height
        let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio,scaleToFitRatio)
        
        let rotation = CGAffineTransformRotate(scaleFactor, CGFloat(M_PI_2))
        let translation = CGAffineTransformTranslate(rotation,0, -assetTrack.naturalSize.height)
        
        instruction.setTransform(translation, atTime: kCMTimeZero)
        
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
