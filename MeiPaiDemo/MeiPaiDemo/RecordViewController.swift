//
//  RecordViewController.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/9/29.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {

    @IBOutlet weak var recordButton: UIView!
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
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
        
        setupAVFoundation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    // MARK: -  Custom Method
    func setupAVFoundation() {
        
        captureSession = AVCaptureSession()
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let deviceInput: AVCaptureDeviceInput?
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
        } catch _ {
            deviceInput = nil
        }
       
        guard let input = deviceInput else {
            previewLayer = nil
            captureSession = nil
            return
        }
        captureSession!.addInput(input)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer!.bounds = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height * 3 / 4)
        previewLayer!.position = CGPointMake(self.view.bounds.width / 2, self.view.bounds.height * 3 / 4 / 2)
        
        view.layer .addSublayer(previewLayer!)
        
        
        
    }
    
}
