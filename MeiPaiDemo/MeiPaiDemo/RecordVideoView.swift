//
//  RecordVideoView.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/1.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit
import AVFoundation

enum RecordMode: Int {
    case Normal
    case RealTimeFilter
}

protocol MPCaptureFileOutputRecordingDelegate: NSObjectProtocol {
    func mpCaptureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!)
    
    func mpCaptureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!, canContinueRecord: Bool)
}

protocol RecordVideoUIDelegate: NSObjectProtocol {
    func dismissViewController()
}

class RecordVideoView: UIView {
    
    weak var fileOutputRecordingdDelegate: MPCaptureFileOutputRecordingDelegate?
    weak var recordVideoDelegate: RecordVideoUIDelegate?
    
    var recordMode: RecordMode = .Normal
    
    private var captureSession: AVCaptureSession?
    private var videoCaptureInput: AVCaptureDeviceInput?
    private var audioCaptureInput: AVCaptureDeviceInput?
    
    private var captureMovieFileOutput: AVCaptureMovieFileOutput?
    private var captureVideoDataOutput: AVCaptureVideoDataOutput?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var filterPreviewView: RealTimeFilterView?
    private var filter: CIFilter?
    
    private var tipsView: UILabel!
    private var progress: UISlider!
    private var timer: NSTimer?
    
    private var toolView: UIView!
    private var cameraChange: UIButton!
    private var torchSwitch: UISwitch!
    
    private let maxVideoLength: Float = 10
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
        
        func setTipsView() {
            tipsView = UILabel(frame: CGRectMake((bounds.width - 100) / 2, bounds.height - 45, 100, 30))
            tipsView.backgroundColor = UIColor.blackColor()
            tipsView.alpha = 0
            
            tipsView.layer.cornerRadius = 0.5
            tipsView.layer.masksToBounds = true
            
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
        
        func setToolView() {
            toolView = UIView(frame: CGRectMake(0, 0, self.bounds.width, 44 + 20))
            toolView.backgroundColor = UIColor.blackColor()
            toolView.alpha = 0.8
            
            cameraChange = UIButton(frame: CGRectMake(self.bounds.width - 20 - 30, 6 + 20, 30, 30))
            cameraChange.setImage(UIImage(named: "changeCamera"), forState: .Normal)
            cameraChange.addTarget(self, action: "changeCamera", forControlEvents: .TouchDown)
            
            torchSwitch = UISwitch(frame: CGRectMake(cameraChange.frame.origin.x - 20 - 50, 6 + 20, 50, 30))
            torchSwitch.onTintColor = UIColor(red: 255/255, green: 102/255, blue: 102/255, alpha: 1)
            torchSwitch.addTarget(self, action: "changeTorchMode:", forControlEvents: .ValueChanged)
            
            let backButton = UIButton(frame: CGRectMake(10, 6 + 10, 51, 51))
            backButton.setImage(UIImage(named: "back"), forState: .Normal)
            backButton.addTarget(self, action: "clickBack", forControlEvents: .TouchDown)
            
            toolView.addSubview(cameraChange)
            toolView.addSubview(torchSwitch)
            toolView.addSubview(backButton)
            self.addSubview(toolView)
        }
        
        setAVFoundation()
        setTipsView()
        setProgress()
        setToolView()
        
    }
    
    func setAVFoundation() {
        captureSession = AVCaptureSession()
        captureSession?.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
        // input
        do {
            videoCaptureInput = try AVCaptureDeviceInput(device: videoDevice) // video
        } catch _ {
            videoCaptureInput = nil
        }
        
        do {
            audioCaptureInput = try AVCaptureDeviceInput(device: audioDevice) // audio
        } catch _ {
            audioCaptureInput = nil
        }
        
        // add input
        guard let videoInput = videoCaptureInput, let audioInput = audioCaptureInput else {
            previewLayer = nil
            captureSession = nil
            return
        }
        captureSession!.addInput(videoInput)
        captureSession!.addInput(audioInput)
        
        if recordMode == .Normal {
        
            captureMovieFileOutput = AVCaptureMovieFileOutput()
            captureSession!.addOutput(captureMovieFileOutput)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer!.bounds = bounds
            previewLayer!.position = CGPointMake(bounds.size.width / 2, bounds.size.height / 2)
            
            layer.insertSublayer(previewLayer!, atIndex: 0)
            
        } else if recordMode == .RealTimeFilter {
            
            captureVideoDataOutput = AVCaptureVideoDataOutput()
            captureVideoDataOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey : Int(kCVPixelFormatType_32BGRA)]
            captureVideoDataOutput?.alwaysDiscardsLateVideoFrames = true
            captureVideoDataOutput?.setSampleBufferDelegate(self, queue: dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL))
            captureSession!.addOutput(captureVideoDataOutput)
            
            filterPreviewView = RealTimeFilterView(frame: bounds)
            insertSubview(filterPreviewView!, atIndex: 0)
            
        }
        
        captureSession?.commitConfiguration()
    }

    // MARK: - IBAction
    func clickBack() {
        recordVideoDelegate?.dismissViewController()
    }
    
    func changeCamera() {
        
        func getCameraDeviceByPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
            let cameras = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
            for camera in cameras {
                if camera.position == position {
                    return camera
                }
            }
            return nil
        }
        
        guard let currentVideoDevice = videoCaptureInput?.device else { return }
        
        let currentDevicePosition: AVCaptureDevicePosition = currentVideoDevice.position
        let changeToPosition: AVCaptureDevicePosition = currentDevicePosition == .Front ? .Back : .Front
        guard let changeToDevice = getCameraDeviceByPosition(changeToPosition) else { return }
        
        let changeToDeviceInput: AVCaptureDeviceInput
        do {
            changeToDeviceInput = try AVCaptureDeviceInput(device: changeToDevice) // video
        } catch _ {
           return
        }
        
        captureSession?.beginConfiguration()
        captureSession?.removeInput(videoCaptureInput)
        captureSession?.addInput(changeToDeviceInput)
        captureSession?.commitConfiguration()
        
        videoCaptureInput = changeToDeviceInput
        
    }
    
    func changeTorchMode(sender: UISwitch) {
        let open = sender.on
        
        lockVideoDeviceToChangeProperty { device in
            guard device.hasTorch && device.torchAvailable else { return }
            let torchMode: AVCaptureTorchMode = open ? .On : .Off
            device.torchMode = torchMode
        }
        
    }
    
    func lockVideoDeviceToChangeProperty(locked: (AVCaptureDevice) -> Void) {
        
        guard let videoDevice = videoCaptureInput?.device else { return }
        do {
            try videoDevice.lockForConfiguration()
            locked(videoDevice)
            videoDevice.unlockForConfiguration()
            
        } catch {
            return
        }
        
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
    
    // MARK: - Loading Method
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
        torchSwitch.setOn(false, animated: false)
    }
    
    func startRecordingWithUrl(outputFileUrl: NSURL) {
        captureMovieFileOutput?.startRecordingToOutputFileURL(outputFileUrl, recordingDelegate: self)
        showTipsView()
        setTimer()
    }
    
    func stopRecording() {
        captureMovieFileOutput?.stopRecording()
        hideTipsView()
        deinitTimer()
    }
    
    func resetRecordVideoUI() {
        timerCount = 0
    }
    
    func changeRecordMode(mode: RecordMode, filter: CIFilter?) {
        
        self.filter = filter
        self.recordMode = mode
        
        stopRunning()
        previewLayer?.removeFromSuperlayer()
        filterPreviewView?.removeFromSuperview()
        setAVFoundation()
        startRunning()
        
    }
}


extension RecordVideoView: AVCaptureFileOutputRecordingDelegate {
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        fileOutputRecordingdDelegate?.mpCaptureOutput(captureOutput, didStartRecordingToOutputFileAtURL: fileURL, fromConnections: connections)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        fileOutputRecordingdDelegate?.mpCaptureOutput(captureOutput, didFinishRecordingToOutputFileAtURL: outputFileURL, fromConnections: connections, error: error, canContinueRecord: timerCount < maxVideoLength && timerCount > 0)
    }

}

extension RecordVideoView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        var image = CIImage(CVPixelBuffer: imageBuffer)
        
        let transfrom = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        image = image.imageByApplyingTransform(transfrom)
        
        filterPreviewView?.bindDrawable()
        if let filter = self.filter {
            filter.setValue(image, forKey: kCIInputImageKey)
            guard let ouputImage = filter.outputImage else { return }
            image = ouputImage
        }
        
        filterPreviewView?.image = image
    }
    
}
