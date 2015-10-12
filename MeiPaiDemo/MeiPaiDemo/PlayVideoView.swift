//
//  PlayVideoView.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/11.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol PlayVideoGestureDelegate {
    optional func onVideoToPause()
    optional func onVideoToPlay()
}

class PlayVideoView: UIView {

    weak var delegate: PlayVideoGestureDelegate?
    
    private var playerItem: AVPlayerItem!
    private var playImg: UIImageView!
    
    private var asset: AVAsset!
    
    private var player: AVPlayer {
        return (self.layer as! AVPlayerLayer).player!
    }
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, asset: AVAsset) {
        self.init(frame: frame)
        
        playVideoByAsset(asset)
        initView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        playerItem.removeObserver(self, forKeyPath: "status")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Custom Method
    func playVideoByAsset(asset: AVAsset) {
        
        self.asset = asset
        
        playerItem = AVPlayerItem(asset: asset)
        playerItem.addObserver(self, forKeyPath: "status", options: .New, context: nil)
        
        (layer as! AVPlayerLayer).player = AVPlayer(playerItem: playerItem)
        
    }
    
    func pause() {
        player.pause()
        playImg.hidden = false
    }
    
    func play() {
        player.play()
        playImg.hidden = true
    }
    
    func initView() {
        
        func initNotification() {
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "onToBackGound", name: UIApplicationDidEnterBackgroundNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "onVideoPlayToEnd", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
            
        }
        
        func initGesture() {
            
            let tapGesture = UITapGestureRecognizer(target: self, action: "onTapVideo")
            self.addGestureRecognizer(tapGesture)
            
            playImg = UIImageView(frame: CGRectMake((self.bounds.width - 80) / 2, (self.bounds.height - 80) / 2, 80, 80))
            playImg.image = UIImage(named: "live_play")
            playImg.hidden = true
            self.addSubview(playImg)
        }
        
        initNotification()
        initGesture()
        
    }
    
}

extension PlayVideoView {
    
    func onToBackGound() {
        guard player.rate > 0 else { return }
        player.pause()
    }
    
    func onVideoPlayToEnd() {
        playerItem.removeObserver(self, forKeyPath: "status")
        playVideoByAsset(asset)
    }
    
    func onTapVideo() {
        
        if playImg.hidden {
            pause()
            delegate?.onVideoToPause?()
            
        } else {
            play()
            delegate?.onVideoToPlay?()
           
        }
    }
    
}

extension PlayVideoView {
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        let playerItem = object as! AVPlayerItem
        
        if keyPath == "status" {
            guard playerItem.status == .ReadyToPlay else { return }
            (layer as! AVPlayerLayer).player?.play()
        }
        
    }
}

