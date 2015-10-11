//
//  PlayViewController.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/11.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController {
    
    var asset: AVAsset!
    private var videoView: PlayVideoView!
    
    class func toPlayViewControllerWithAsset(asset: AVAsset) -> PlayViewController {
        
        let playVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlayViewController") as! PlayViewController
        playVC.asset = asset
        
        return playVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoView = PlayVideoView(frame: UIScreen.mainScreen().bounds, asset: asset)
        view.addSubview(videoView)
    }
    
}
