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
    @IBOutlet weak var photoImage: UIImageView!
    
    private var bigPhotoImage: UIImageView?
    private var blackBackground: UIView!
    
    private var recordVideoView: RecordVideoView!
    private var filterScrollView: FilterScrollView!
    private var loadingBox: LoadingBox? = LoadingBox()
    
    private var model = RecordModel()
    private var filterIndex = 0
    private var filters = [ CIFilter(name: "Normal"),
                            CIFilter(name: "CIPhotoEffectInstant"),
                            CIFilter(name: "CIPhotoEffectTransfer"),
                            CIFilter(name: "CIPhotoEffectProcess")]
    
    private var canRecord: Bool = true
    
    // MARK: - Life Circle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        model.deleteTempVideo()
        recordVideoView.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        recordVideoView.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        initView()
        navigationController?.navigationBar.hidden = true
    }
    
    func initView() {
        
        func initRecordButton() {
            
            recordButton.layer.cornerRadius = recordButton.bounds.size.width / 2
            recordButton.layer.masksToBounds = true
            
            let centerLayer = CALayer()
            centerLayer.frame = CGRectMake(5, 5, recordButton.frame.size.width - 10, recordButton.frame.size.height - 10)
            centerLayer.backgroundColor = CommonColor.mainColor.CGColor
            centerLayer.cornerRadius = centerLayer.frame.size.width / 2
            centerLayer.masksToBounds = true
            recordButton.layer.addSublayer(centerLayer)
            
            let longTap = UILongPressGestureRecognizer(target: self, action: "handleLongGesture:")
            recordButton.addGestureRecognizer(longTap)
            
            let tap = UITapGestureRecognizer(target: self, action: "handleRecordTap:")
            recordButton.addGestureRecognizer(tap)

        }
        
        func initRecordVideoView() {
            recordVideoView = RecordVideoView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height * 3 / 4))
            recordVideoView.recordVideoDelegate = self
            view.addSubview(recordVideoView)

        }
        
        func initPhotoImage() {
            let tap = UITapGestureRecognizer(target: self, action: "handlePhotoTap:")
            photoImage.userInteractionEnabled = true
            photoImage.addGestureRecognizer(tap)
            
            blackBackground = UIView(frame: view.frame)
            blackBackground.backgroundColor = UIColor.blackColor()
            blackBackground.alpha = 0
            view.addSubview(blackBackground)
        }
        
        func initFilterScrollView() {
            
            filterScrollView = FilterScrollView(frame: CGRectMake(0, recordVideoView.frame.origin.y + recordVideoView.frame.size.height + 10 , view.frame.width, 30), filters: filters)
            view.addSubview(filterScrollView)
            
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
            leftSwipe.direction = .Left
            
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
            rightSwipe.direction = .Right
        
            recordVideoView.addGestureRecognizer(leftSwipe)
            recordVideoView.addGestureRecognizer(rightSwipe)
        }
        
        
        initRecordButton()
        initRecordVideoView()
        initFilterScrollView()
        initPhotoImage()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Gesture
    func handleLongGesture(sender: UILongPressGestureRecognizer) {
        
        guard canRecord else { return }
        
        switch sender.state {
        case .Began:
            recordVideoView.startRecordingOnUrl(model.outputFileUrl)
            model.addNewVideoFilePath()
        case .Ended:
            recordVideoView.stopRecording()
        default:
            return
        }
        
    }
    
    func handleRecordTap(sender: UITapGestureRecognizer) {
        
        guard let photo = recordVideoView.takePhoto() else { return }
        photoImage.image = photo
        
    }
    
    func handlePhotoTap(sender: UITapGestureRecognizer) {
        
        if sender.view == photoImage {
        
            bigPhotoImage = UIImageView(frame: photoImage.frame)
            bigPhotoImage?.image = photoImage.image
            view.addSubview(bigPhotoImage!)
            
            let tap = UITapGestureRecognizer(target: self, action: "handlePhotoTap:")
            bigPhotoImage?.userInteractionEnabled = true
            bigPhotoImage?.addGestureRecognizer(tap)
            
            UIView.animateWithDuration(0.5) {
                self.bigPhotoImage?.frame = UIScreen.mainScreen().bounds
                self.bigPhotoImage?.transform = CGAffineTransformMakeScale(0.9, 0.9)
                self.blackBackground.alpha = 0.7
            }
            photoImage.userInteractionEnabled = false
            
        } else if sender.view == bigPhotoImage {
            
            UIView.animateWithDuration(0.5, animations: {
                self.bigPhotoImage?.frame = self.photoImage.frame
                self.bigPhotoImage?.transform = CGAffineTransformMakeScale(1, 1)
                self.blackBackground.alpha = 0
                
                }, completion: { finish in
                    self.bigPhotoImage?.removeFromSuperview()
                    self.photoImage.userInteractionEnabled = true
            })
            
        }
        
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        
        guard (sender.direction == UISwipeGestureRecognizerDirection.Left) || (sender.direction == UISwipeGestureRecognizerDirection.Right) else { return }
        
        let oldFilterIndex = filterIndex
        
        if sender.direction == .Left {
            filterIndex++
        } else if sender.direction == .Right {
            filterIndex--
        }
        
        if filterIndex == filters.count {
            filterIndex = filters.count - 1
        } else if filterIndex == -1 {
            filterIndex = 0
        }
        
        let filter = filters[filterIndex % filters.count]
        recordVideoView.changeRecordFilter(filter)
        filterScrollView.changeFIlterFromOldIndex(oldFilterIndex, toNewIndex: filterIndex)
        
    }
    
    // MARK: - Alert Handle
    func handleAlertController() {
        canRecord = false
        loadingBox?.showInView(view, withText: "处理视频中..")
        
//        recordVideoView.resetRecordVideoUIAndHandleEndingImageByUrl(model.outputFileUrl)
//        model.addNewVideoFilePath()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
            
            self?.model.saveToCameraRoll {
                self?.canRecord = true
                self?.loadingBox?.hide()
            }
        }

    }
    
}

extension RecordViewController: RecordVideoUIDelegate {
    
    func dismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didFinishRecordWithCanContinue(canContinue: Bool) {
        
        if canContinue {

            let alertController = UIAlertController(title: "提示", message: "是否要结束录制", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "No,继续取景", style: .Cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "Yes,存入图库", style: .Default) { [weak self] _ in
                self?.handleAlertController()
            }

            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)

        } else {

            let alertController = UIAlertController(title: "提示", message: "您最多只能录制10秒！", preferredStyle: .Alert)
            let confirmAction = UIAlertAction(title: "确定", style: .Default) { [weak self] _ in
                self?.handleAlertController()
            }
            
            alertController.addAction(confirmAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }

    }
}

