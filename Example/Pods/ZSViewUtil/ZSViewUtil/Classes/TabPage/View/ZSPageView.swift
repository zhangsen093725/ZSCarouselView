//
//  ZSPageView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/14.
//

import UIKit

@objcMembers open class ZSPageView: UICollectionView {
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        isPagingEnabled = true
    }
    
    // TODO: 动画处理
    open func beginScrollToIndex(_ index: Int,
                                 isAnimation: Bool) {
        reloadData()
        
        scrollToItem(at: IndexPath(item: index, section: 0), at: .right, animated: isAnimation)
    }
}
