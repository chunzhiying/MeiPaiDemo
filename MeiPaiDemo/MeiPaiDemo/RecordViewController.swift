//
//  RecordViewController.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/9/29.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class RecordViewController: UIViewController {

    @IBOutlet weak var recordButton: UIView!
    
    private var recordVideoView: RecordVideoView!
    
    private let outputFilePath: String = NSTemporaryDirectory().stringByAppendingString("myMovie.mov")
    private var outputFileUrl: NSURL {
        return NSURL.fileURLWithPath(self.outputFilePath)
    }
    
    // MARK: - Life Circle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        recordVideoView.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        recordVideoView.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.layer.cornerRadius = recordButton.bounds.size.width / 2
        recordButton.layer.masksToBounds = true
        
        let longTap = UILongPressGestureRecognizer(target: self, action: "handleLongGesture:")
        recordButton.addGestureRecognizer(longTap)
        
        recordVideoView = RecordVideoView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height * 3 / 4))
        view.addSubview(recordVideoView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func saveToCameraRoll() {
        ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(outputFileUrl, completionBlock: { (url: NSURL!, error: NSError?) in
            
            if let errorDescription = error?.description {
                print("写入错误:\(errorDescription)")
            } else {
                print("写入成功")
            }
            
        })
    }
    
    // MARK: - Gesture
    func handleLongGesture(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .Began:
            recordVideoView.startRecordingWithDelegate(self, outputFileUrl: outputFileUrl)
        case .Ended:
            recordVideoView.stopRecording()
        default:
            return
        }
        
    }
    
}

extension RecordViewController: AVCaptureFileOutputRecordingDelegate {
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {

    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        UIAlertView(title: "提示", message: "是否要存入图库？", delegate: self, cancelButtonTitle: "不要", otherButtonTitles: "要").show()
        
    }
}

extension RecordViewController: UIAlertViewDelegate {
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        guard buttonIndex == 1 else { return }
        
        saveToCameraRoll()
    }
    
}
