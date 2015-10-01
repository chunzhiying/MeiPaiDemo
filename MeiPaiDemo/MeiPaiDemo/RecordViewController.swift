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
    
    private var captureSession: AVCaptureSession?
    private var captureOutput: AVCaptureMovieFileOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private let outputFilePath: String = NSTemporaryDirectory().stringByAppendingString("myMovie.mov")
    private var outputFileUrl: NSURL {
        return NSURL.fileURLWithPath(self.outputFilePath)
    }
    
    // MARK: - Life Circle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession?.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        captureSession?.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.layer.cornerRadius = recordButton.bounds.size.width / 2
        recordButton.layer.masksToBounds = true
        
        let longTap = UILongPressGestureRecognizer(target: self, action: "handleLongGesture:")
        recordButton.addGestureRecognizer(longTap)
        
        setupAVFoundation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    // MARK: -  Custom Method
    func setupAVFoundation() {
        
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
        previewLayer!.bounds = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height * 3 / 4)
        previewLayer!.position = CGPointMake(self.view.bounds.width / 2, self.view.bounds.height * 3 / 4 / 2)
        
        view.layer.addSublayer(previewLayer!)
        
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
            let fileUrl = NSURL.fileURLWithPath(outputFilePath)
            captureOutput.startRecordingToOutputFileURL(fileUrl, recordingDelegate: self)
        case .Ended:
            captureOutput.stopRecording()
        default:
            return
        }
        
    }
    
}

extension RecordViewController: AVCaptureFileOutputRecordingDelegate {
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {

    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        saveToCameraRoll()
    }
}
