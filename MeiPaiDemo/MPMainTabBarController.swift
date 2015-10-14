//
//  MPMainTabBarViewController.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/9/29.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit

class MPMainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
}

extension MPMainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let animation = CATransition()
        animation.duration = 0.3
        animation.type = kCATransitionFade
        self.view.layer.addAnimation(animation, forKey: nil)
    }
    
}
