//
//  ZSDragCollectionView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/3.
//

import UIKit

@objcMembers open class ZSDragCollectionView: UIView {
    
    public lazy var flowLayout: UICollectionViewFlowLayout = {

        return configFlowLayout()
    }()
    
    public lazy var collectionView: UICollectionView = {

        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = false
        addSubview(collectionView)
        return collectionView
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    open func configFlowLayout() -> UICollectionViewFlowLayout {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }
}
