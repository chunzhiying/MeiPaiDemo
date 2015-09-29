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

    private var captureSession: AVCaptureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setupAVFoundation() {
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let deviceInput: AVCaptureDeviceInput?
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
        } catch _ {
            deviceInput = nil
        }
       
        guard let input = deviceInput else { return }
        captureSession.addInput(input)
        
        

    }
    
}
