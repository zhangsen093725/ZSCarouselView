//
//  ZSTabPageView.swift
//  JadeToB
//
//  Created by 张森 on 2020/1/13.
//  Copyright © 2020 张森. All rights reserved.
//

import UIKit

@objcMembers open class ZSTabPageView: UIView {
    
    open lazy var tabView: ZSTabView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
       let tabView = ZSTabView(frame: .zero, collectionViewFlowLayout: layout)
        
        if #available(iOS 11.0, *) {
            tabView.contentInsetAdjustmentBehavior = .never
        }
        
        tabView.isPagingEnabled = true
        tabView.backgroundColor = .clear
        tabView.showsHorizontalScrollIndicator = false
        
        addSubview(tabView)
        return tabView
    }()
    
    public lazy var pageView: ZSPageView = {
        
        let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .horizontal
         
        let pageView = ZSPageView(frame: .zero, collectionViewLayout: layout)
         
         if #available(iOS 11.0, *) {
             pageView.contentInsetAdjustmentBehavior = .never
         }
         
         pageView.isPagingEnabled = true
         pageView.backgroundColor = .clear
         pageView.showsHorizontalScrollIndicator = false
        
        addSubview(pageView)
        return pageView
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        tabView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
        pageView.frame = CGRect(x: 0, y: tabView.frame.maxY, width: bounds.width, height: bounds.height - tabView.frame.maxY)
    }
}
