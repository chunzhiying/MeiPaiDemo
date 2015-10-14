//
//  ViewController.swift
//  swiftTest
//
//  Created by 陈智颖 on 15/10/14.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var image = CIImage(CGImage: (UIImage(named: "Baby-Lufy")?.CGImage)!)
        let transfrom = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
        image = image.imageByApplyingTransform(transfrom)
        
        let filter = CIFilter(name: "CIPhotoEffectInstant")
        filter?.setValue(image, forKey: kCIInputImageKey)
        
        let context = CIContext(options: nil)
        
        let layer = CALayer()
        layer.frame = CGRectMake(0, 0, 100, 100)
        layer.contents = context.createCGImage((filter?.outputImage)!, fromRect: (filter?.outputImage?.extent)!)
//        layer.contents = UIImage(named: "Baby-Lufy")?.CGImage
        
        view.layer.addSublayer(layer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

