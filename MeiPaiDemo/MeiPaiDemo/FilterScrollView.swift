//
//  FilterScrollView.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/10/17.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit

class FilterScrollView: UIView {

    private var scrollView: UIScrollView!
    private var filterLabels = [UILabel]()
    
    private var filters = [CIFilter?]()
    private let maxCountInScreen = 3
    
    // MARK: - Life Cycle
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, filters: [CIFilter?]) {
        self.init(frame: frame)
        
        self.filters = filters
        initView()
    }

    func initView() {
        
        func initScrollView() {
            scrollView = UIScrollView(frame: CGRectMake(frame.origin.x + frame.size.width / CGFloat(maxCountInScreen) , 0, frame.size.width / CGFloat(maxCountInScreen), frame.size.height))
            scrollView.scrollEnabled = false
            scrollView.clipsToBounds = false
        }
        
        func changeFilterToLabel() {
            guard filters.count > 0 else { return }
            var count = 0
            filterLabels = filters.map { filter -> UILabel in
                let label = UILabel(frame: CGRectMake(scrollView.frame.width * CGFloat(count++) , 0, scrollView.frame.width, scrollView.frame.height))
                label.text = filter == nil ?  "Normal" : (filter!.name as NSString).substringFromIndex(13)
                label.textColor = UIColor.grayColor()
                label.font = UIFont.systemFontOfSize(13)
                label.textAlignment = .Center
                scrollView.addSubview(label)
                return label
            }
            
            filterLabels[0].textColor = CommonColor.mainColor
            filterLabels[0].font = UIFont.systemFontOfSize(15)
        }
        
        initScrollView()
        changeFilterToLabel()
        scrollView.contentSize = CGSizeMake(CGFloat(filterLabels.count) * scrollView.frame.width, scrollView.frame.height)
        addSubview(scrollView)
        
    }
    
    // MARK: - Public
    func changeFIlterFromOldIndex(oldIndex: Int, toNewIndex: Int) {
        
        filterLabels[oldIndex].textColor = UIColor.grayColor()
        filterLabels[oldIndex].font = UIFont.systemFontOfSize(13)
        
        filterLabels[toNewIndex].textColor = CommonColor.mainColor
        filterLabels[toNewIndex].font = UIFont.systemFontOfSize(15)
        
        scrollView.setContentOffset(CGPointMake(CGFloat(toNewIndex) * scrollView.frame.width, 0), animated: true)
        
    }
    
}
