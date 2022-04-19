//
//  ZSEditTableViewCell.swift
//  ZSViewUtil
//
//  Created by Josh on 2020/9/1.
//

import UIKit

@objcMembers public class ZSEditTableViewCellScrollView: UIScrollView {
 
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesEnded(touches, with: event)
    }
}

@objc public protocol ZSEditTableViewCellDelegate {
    
    /// 将要开始滚动
    /// - Parameter cell: 当前的Cell
    func zs_cellWillBeginScrollEdit(_ cell: ZSEditTableViewCell)
}

@objcMembers open class ZSEditTableViewCell: UITableViewCell, UIScrollViewDelegate {
    
    /// 是否可以滑动，根据scrollView上手指滑动的方向确定，放手后是否可以显示操作按钮
    private var isScrollEditEnable: Bool = false
    
    /// 是否正在执行结束操作的动画
    private var isEndScrollEditing: Bool = false
    
    public var delegate: ZSEditTableViewCellDelegate?
    
    /// Cell的内容添加到ScrollView上
    public lazy var scrollView: ZSEditTableViewCellScrollView = {
        
        let scrollView = ZSEditTableViewCellScrollView()
        
        scrollView.backgroundColor = .clear
        scrollView.delegate = self
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        contentView.addSubview(scrollView)
        return scrollView
    }()
    
    open override func layoutSubviews() {
        superview?.layoutSubviews()
        
        scrollView.frame = contentView.bounds
//        scrollView.contentSize = CGSize(width: contentView.frame.width + 50, height: 0)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if scrollView.contentOffset.x > 0
        {
            endScrollEditing()
        }
        else
        {
            super.touchesBegan(touches, with: event)
        }
    }
    
    open func endScrollEditing() {
        
        guard scrollView.contentOffset.x > 0 else { return }
        
        scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - scrollView.bounds.width, y: 0), animated: true)

        isEndScrollEditing = true
        
        UIView .animate(withDuration: 0.25, animations: { [weak self] in
            self?.scrollView.contentOffset = .zero
        }) { [weak self] (finished) in
            self?.isEndScrollEditing = false
        }
    }
    
    // TODO: UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard isEndScrollEditing == false else { return }
        
        let vel = scrollView.panGestureRecognizer.velocity(in: scrollView)
        
        isScrollEditEnable = vel.x < -5
        
        if scrollView.contentOffset.x < 0
        {
            scrollView.contentOffset = .zero
            return
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
         delegate?.zs_cellWillBeginScrollEdit(self)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        scrollView.isUserInteractionEnabled = !decelerate
        
        scrollView .setContentOffset(scrollView.contentOffset, animated: true)
        
        guard decelerate == false else { return }
        
        if isScrollEditEnable
        {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - scrollView.bounds.width, y: 0), animated: true)
        }
        else
        {
            scrollView.setContentOffset(.zero, animated: true)
        }
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollView.isUserInteractionEnabled = true
    }
}
