//
//  ZSDragImageItemView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/3.
//

import UIKit

@objcMembers open class ZSDragStaticItemView: UICollectionViewCell {
    
    open class var zs_identifier: String { return NSStringFromClass(self) }
    
    public var itemGestureRecognizerHandle: ((_ gestureRecognizer: UIGestureRecognizer)->Void)?
    
    private lazy var backView: UIView = {
        
        let backView = UIView()
        backView.backgroundColor = .clear
        configGestureRecognizer()
        contentView.addSubview(backView)
        return backView
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        backView.frame = contentView.bounds
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        itemGestureRecognizerHandle = nil
    }
    
    open func configGestureRecognizer() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizerAction(_:)))
        addGestureRecognizer(pan)
    }
    
    @objc open func gestureRecognizerAction(_ gestureRecognizer: UIGestureRecognizer) {
     
        guard itemGestureRecognizerHandle != nil else { return }
        itemGestureRecognizerHandle!(gestureRecognizer)
    }
}
