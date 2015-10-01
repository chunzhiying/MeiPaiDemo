//
//  RecordVideoView.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/1.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit
import AVFoundation

class RecordVideoView: UIView {
    
    private var captureSession: AVCaptureSession?
    private var captureOutput: AVCaptureMovieFileOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var tipsView: UILabel!
    private var progress: UISlider!
    private var timer: NSTimer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initView()
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
            progress.maximumValue = 30
            
            progress.value = 15
            
            addSubview(progress)
        }
        
        func setTimer() {
            timer = HWWeakTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timeOut", userInfo: nil, repeats: true)
        }
        
        setAVFoundation()
        setTipsView()
        setProgress()
        
    }
    
    func timeOut() {
        
    }
    
    func uinitTimer() {
        
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
    
    func startRecordingWithDelegate(delegate: AVCaptureFileOutputRecordingDelegate, outputFileUrl: NSURL) {
        captureOutput.startRecordingToOutputFileURL(outputFileUrl, recordingDelegate: delegate)
        showTipsView()
    }
    
    func stopRecording() {
        captureOutput.stopRecording()
        hideTipsView()
    }
    
}
