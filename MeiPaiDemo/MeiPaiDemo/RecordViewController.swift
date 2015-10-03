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
    private var loadingBox: LoadingBox? = LoadingBox()
    
    private var model = RecordModel()
    
    private var canRecord: Bool = true
    
    // MARK: - Life Circle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        model.deleteTempVideo()
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
        recordVideoView.delegate = self
        view.addSubview(recordVideoView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // MARK: - Gesture
    func handleLongGesture(sender: UILongPressGestureRecognizer) {
        
        guard canRecord else { return }
        
        switch sender.state {
        case .Began:
            recordVideoView.startRecordingWithUrl(model.outputFileUrl)
        case .Ended:
            recordVideoView.stopRecording()
        default:
            return
        }
        
    }
    
}

extension RecordViewController: MPCaptureFileOutputRecordingDelegate {
    
    func mpCaptureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        
        model.addNewVideoFilePath()
    }
    
    func mpCaptureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!, canContinueRecord: Bool) {
        
        if canContinueRecord {
            UIAlertView(title: "提示", message: "是否要结束录制？", delegate: self, cancelButtonTitle: "No,继续取景", otherButtonTitles: "Yes,存入图库").show()
        } else {
             UIAlertView(title: "提示", message: "您最多只能录制30秒，是否要存入图库", delegate: self, cancelButtonTitle: "不要", otherButtonTitles: "要").show()
        }
        
    }
}

extension RecordViewController: UIAlertViewDelegate {
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        guard buttonIndex == 1 else { return }
        
        canRecord = false
        loadingBox?.showInView(view, withText: "处理视频中..")
        recordVideoView.resetRecordVideoUI()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){ [weak self] in
            
            self?.model.saveToCameraRoll {
                self?.canRecord = true
                self?.loadingBox?.hide()
            }
        }
        
    }
    
}
