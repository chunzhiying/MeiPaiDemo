//
//  VideoCell.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/9.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit

class VideoCell: UICollectionViewCell {
    
    var image: UIImage? { didSet {
            imageView.image = image
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
