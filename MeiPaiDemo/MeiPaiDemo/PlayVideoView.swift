//
//  PlayVideoView.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/11.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit
import AVFoundation

class PlayVideoView: UIView {

    private var playerItem: AVPlayerItem!
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, asset: AVAsset) {
        self.init(frame: frame)
        playVideoByAsset(asset)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        playerItem.removeObserver(self, forKeyPath: "status")
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }
    
    func playVideoByAsset(asset: AVAsset) {
        
        playerItem = AVPlayerItem(asset: asset)
        playerItem.addObserver(self, forKeyPath: "status", options: .New, context: nil)
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .New, context: nil)
        
        (layer as! AVPlayerLayer).player = AVPlayer(playerItem: playerItem)
        
    }
}

extension PlayVideoView {
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        let playerItem = object as! AVPlayerItem
        
        if keyPath == "status" {
            guard playerItem.status == .ReadyToPlay else { return }
            (layer as! AVPlayerLayer).player?.play()
        }
        
        else if keyPath == "loadedTimeRanges" {
            
        }
        
    }
}