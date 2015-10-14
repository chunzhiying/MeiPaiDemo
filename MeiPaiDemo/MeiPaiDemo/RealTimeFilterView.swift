//
//  RealTimeFilterView.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/14.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit
import GLKit

class RealTimeFilterView: GLKView {

    var image: CIImage? {
        didSet {
            display()
        }
    }
    
    let ciContext: CIContext
    
    override convenience init(frame: CGRect) {
        let eaglContext = EAGLContext(API: .OpenGLES2)
        self.init(frame: frame, context: eaglContext)
    }
    
    override init(frame: CGRect, context: EAGLContext) {
        ciContext = CIContext(EAGLContext: context)
        super.init(frame: frame, context: context)
        
        // 不让view自己刷新
        enableSetNeedsDisplay = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        guard let image = self.image else { return }
                
        let scale = self.window?.screen.scale ?? 1.0
        let destRect = CGRectApplyAffineTransform(bounds, CGAffineTransformMakeScale(scale, scale))
        ciContext.drawImage(image, inRect: destRect, fromRect: image.extent)
    }
    
}
