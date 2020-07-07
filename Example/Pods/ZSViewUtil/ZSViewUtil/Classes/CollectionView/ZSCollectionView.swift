//
//  ZSCollectionView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/10.
//

import UIKit

@objcMembers open class ZSCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    
    public var shouldMultipleGestureRecognize: Bool = false
    
    open var collectionViewTopView: UIView? {
        
        didSet {
            guard oldValue != collectionViewTopView else { return }
            oldValue?.removeFromSuperview()
            
            if collectionViewTopView == nil
            {
                contentInset.top = 0
            }
            else
            {
                addSubview(collectionViewTopView!)
            }
        }
    }
    
    open var collectionViewBottomView: UIView? {
        
        didSet {
            guard oldValue != collectionViewBottomView else { return }
            oldValue?.removeFromSuperview()

            if collectionViewBottomView == nil
            {
                contentInset.bottom = 0
            }
            else
            {
                addSubview(collectionViewBottomView!)
            }
        }
    }
    
    open var collectionViewLeftView: UIView? {
        
        didSet {
            guard oldValue != collectionViewLeftView else { return }
            oldValue?.removeFromSuperview()

            if collectionViewLeftView == nil
            {
                contentInset.left = 0
            }
            else
            {
                addSubview(collectionViewLeftView!)
            }
        }
    }
    
    open var collectionViewRightView: UIView? {
        
        didSet {
            guard oldValue != collectionViewRightView else { return }
            oldValue?.removeFromSuperview()

            if collectionViewRightView == nil
            {
                contentInset.right = 0
            }
            else
            {
                addSubview(collectionViewRightView!)
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        reloadTop()
        reloadBottom()
        reloadLeft()
        reloadRight()
    }
    
    open override func reloadData() {
        super.reloadData()
        
        reloadTop()
        reloadBottom()
        reloadLeft()
        reloadRight()
    }
    
    open func reloadTop() {
        
        guard collectionViewTopView != nil else { return }
        
        collectionViewTopView?.frame = CGRect(x: 0, y: -collectionViewTopView!.frame.height, width: frame.width, height: collectionViewTopView!.frame.height)
        contentInset = UIEdgeInsets(top: collectionViewTopView!.frame.height, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
    }
    
    open func reloadBottom() {

        guard collectionViewBottomView != nil else { return }
        
        collectionViewBottomView?.frame = CGRect(x: 0, y: contentSize.height, width: frame.width, height: collectionViewBottomView!.frame.height)
        contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: collectionViewBottomView!.frame.height, right: contentInset.right)
    }
    
    open func reloadLeft() {
        
        guard collectionViewLeftView != nil else { return }
        
        collectionViewLeftView?.frame = CGRect(x: -collectionViewLeftView!.frame.width, y: 0, width: collectionViewLeftView!.frame.width, height: frame.height)
        contentInset = UIEdgeInsets(top: contentInset.top, left: collectionViewLeftView!.frame.width, bottom: contentInset.bottom, right: contentInset.right)
    }
    
    open func reloadRight() {

        guard collectionViewRightView != nil else { return }
        
        collectionViewRightView?.frame = CGRect(x: contentSize.width, y: 0, width: collectionViewRightView!.frame.width, height: frame.height)
        collectionViewRightView?.frame.origin.x = contentSize.width
        contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: contentInset.bottom, right: collectionViewRightView!.frame.width)
    }
    
    // TODO: UIGestureRecognizerDelegate
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return shouldMultipleGestureRecognize
    }
}
