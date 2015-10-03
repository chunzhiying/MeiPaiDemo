//
//  RecordVideoView.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/1.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit
import AVFoundation

protocol MPCaptureFileOutputRecordingDelegate: NSObjectProtocol {
    func mpCaptureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!)
    
    func mpCaptureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!, canContinueRecord: Bool)
}

class RecordVideoView: UIView {
    
    weak var delegate: MPCaptureFileOutputRecordingDelegate?
    
    private var captureSession: AVCaptureSession?
    private var captureOutput: AVCaptureMovieFileOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var tipsView: UILabel!
    private var progress: UISlider!
    private var timer: NSTimer?
    
    private let maxVideoLength: Float = 30
    private var timerCount: Float  = 0 {
        didSet {
            progress.value = timerCount
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initView()
    }
    
    deinit {
        deinitTimer()
    }
    
    // MARK: -  Custom Method
    func initView() {
        
        func setAVFoundation() {
            captureSession = AVCaptureSession()
            let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            
            // input
            let videoDeviceInput: AVCaptureDeviceInput?
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice) // video
            } catch _ {
                videoDeviceInput = nil
            }
            
            let audioDeviceInput: AVCaptureDeviceInput?
            do {
                audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice) // audio
            } catch _ {
                audioDeviceInput = nil
            }
            
            // add input
            guard let videoInput = videoDeviceInput, let audioInput = audioDeviceInput else {
                previewLayer = nil
                captureSession = nil
                return
            }
            captureSession!.addInput(videoInput)
            captureSession!.addInput(audioInput)
            
            // output
            captureOutput = AVCaptureMovieFileOutput()
            
            // add output
            captureSession!.addOutput(captureOutput)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer!.bounds = bounds
            previewLayer!.position = CGPointMake(bounds.size.width / 2, bounds.size.height / 2)
            
            layer.addSublayer(previewLayer!)
        }
        
        func setTipsView() {
            tipsView = UILabel(frame: CGRectMake((bounds.width - 100) / 2, bounds.height - 45, 100, 30))
            tipsView.backgroundColor = UIColor.blackColor()
            tipsView.alpha = 0
            
            tipsView.font = UIFont.systemFontOfSize(13)
            tipsView.textColor = UIColor.whiteColor()
            tipsView.textAlignment = .Center
            
            addSubview(tipsView)
        }
        
        func setProgress() {
            progress = UISlider(frame: CGRectMake(0, bounds.height - 3, bounds.width, 3))
            progress.enabled = false
            
            progress.minimumValue = 0
            progress.maximumValue = Float(maxVideoLength)
            
            addSubview(progress)
        }
        
        
        setAVFoundation()
        setTipsView()
        setProgress()
        
    }
    
    
    // MARK: - Timer
    func setTimer() {
        timer = HWWeakTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "timeOut", userInfo: nil, repeats: true)
    }
    
    func timeOut() {
        guard timerCount < maxVideoLength else {
            timerCount = 0
            stopRecording()
            return
        }
        
        timerCount += 0.5
    }
    
    func deinitTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func showTipsView() {
        
        tipsView.text = "正在录制.."
        
        UIView.animateWithDuration(0.2, animations: {[weak self] in
            self?.tipsView.alpha = 0.7
            })
        
    }
    
    func hideTipsView() {
     
        tipsView.text = "录制完成!"
        
        dispatch_after(2, dispatch_get_main_queue()) {
            
            UIView.animateWithDuration(0.2, animations: { [weak self] in
                self?.tipsView.alpha = 0
                })
        }
        
    }
    
    // MARK: - Public Method
    func startRunning() {
        captureSession?.startRunning()
    }
    
    func stopRunning() {
        captureSession?.stopRunning()
    }
    
    func startRecordingWithUrl(outputFileUrl: NSURL) {
        captureOutput.startRecordingToOutputFileURL(outputFileUrl, recordingDelegate: self)
        showTipsView()
        setTimer()
    }
    
    func stopRecording() {
        captureOutput.stopRecording()
        hideTipsView()
        deinitTimer()
    }
    
    func resetRecordVideoUI() {
        timerCount = 0
    }
}


extension RecordVideoView: AVCaptureFileOutputRecordingDelegate {
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        delegate?.mpCaptureOutput(captureOutput, didStartRecordingToOutputFileAtURL: fileURL, fromConnections: connections)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        delegate?.mpCaptureOutput(captureOutput, didFinishRecordingToOutputFileAtURL: outputFileURL, fromConnections: connections, error: error, canContinueRecord: timerCount < maxVideoLength && timerCount > 0)
    }

    
}
