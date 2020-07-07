//
//  ZSTabView.swift
//  JadeToB
//
//  Created by 张森 on 2020/1/13.
//  Copyright © 2020 张森. All rights reserved.
//

import UIKit

@objcMembers open class ZSTabView: UICollectionView {
    
    /// 是否隐藏底部的滑块
    public var isSliderHidden: Bool = false {
        
        didSet {
            sliderView.isHidden = isSliderHidden
        }
    }
    
    /// 滑块的宽度
    public var sliderWidth: CGFloat = 2
    
    /// 滑块的长度
    public var sliderLength: CGFloat = 0
    
    public var sliderInset: UIEdgeInsets = .zero
    
    public lazy var sliderView: UIView = {
        
        let sliderView = UIView()
        sliderView.isHidden = isSliderHidden
        sliderView.backgroundColor = UIColor.systemGray
        addSubview(sliderView)
        return sliderView
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    convenience public init(frame: CGRect, collectionViewFlowLayout layout: UICollectionViewFlowLayout) {
        
        self.init(frame: frame, collectionViewLayout: layout)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// TODO: 动画处理
@objc extension ZSTabView {
    
    open func sliderViewAnimation(to cell: UICollectionViewCell,
                                  isHorizontal: Bool,
                                  isAnimation: Bool) {
        
        // SliderView 位置初始化
        if isHorizontal
        {
            sliderView.frame.origin.y = cell.frame.maxY - self.sliderWidth - sliderInset.bottom + sliderInset.top
            sliderView.frame.size.width = sliderLength > 0 ? sliderLength : cell.frame.width
            sliderView.frame.size.height = self.sliderWidth
        }
        else
        {
            sliderView.frame.origin.x = cell.frame.origin.x + self.sliderWidth + sliderInset.left - sliderInset.right
            sliderView.frame.size.width = self.sliderWidth
            sliderView.frame.size.height = sliderLength > 0 ? sliderLength : cell.frame.height
        }
        
        // SliderView 动画
        if !isAnimation
        {
            if isHorizontal
            {
                sliderView.frame.origin.x = cell.frame.origin.x + (cell.frame.size.width - sliderView.frame.size.width) * 0.5
            }
            else
            {
                sliderView.frame.origin.y = cell.frame.origin.y + (cell.frame.size.height - sliderView.frame.size.height) * 0.5
            }
            isUserInteractionEnabled = true
        }
        else
        {
            sliderView.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                
                if isHorizontal
                {
                    self?.sliderView.frame.origin.x = cell.frame.origin.x + (cell.frame.size.width - (self?.sliderView.frame.size.width ?? 0)) * 0.5
                }
                else
                {
                    self?.sliderView.frame.origin.y = cell.frame.origin.y + (cell.frame.size.height - (self?.sliderView.frame.size.height ?? 0)) * 0.5
                }
                
            }) { [weak self] (finished) in
                
                self?.isUserInteractionEnabled = true
            }
        }
    }
    
    open func cellForIndex(_ index: Int, isHorizontal: Bool) -> UICollectionViewCell? {
        
        let indexPath = IndexPath(item: index, section: 0)
        
        let cell = cellForItem(at: indexPath)

        if cell == nil
        {
            scrollToItem(at: indexPath, at: isHorizontal ? .centeredHorizontally : .centeredVertically, animated: false)
            layoutIfNeeded()
            return cellForItem(at: indexPath)
        }
        
        return cell
    }
    
    open func beginScrollToIndex(_ index: Int,
                                 isAnimation: Bool) {

        guard frame != .zero else { return }
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let isHorizontal = flowLayout.scrollDirection == .horizontal

        guard let cell = cellForIndex(index, isHorizontal: isHorizontal) else { return }
        
        isUserInteractionEnabled = false
        
        let min: CGFloat = 0
        let max = contentSize.width - (isHorizontal ? frame.width : frame.height)
        
        let cellCenter = isHorizontal ? cell.center.x : cell.center.y
        let centerContentOffset = cellCenter - (isHorizontal ? center.x : center.y)
        
        // CollectionView 滚动动画
        if contentOffset.x >= min
        {
            if centerContentOffset > max
            {
                let point = isHorizontal ? CGPoint(x: max, y: 0) : CGPoint(x: 0, y: max)
                setContentOffset(point, animated: isAnimation)
            }
            else if centerContentOffset > 0
            {
                let point = isHorizontal ? CGPoint(x: centerContentOffset, y: 0) : CGPoint(x: 0, y: centerContentOffset)
                setContentOffset(point, animated: isAnimation)
            }
            else
            {
                setContentOffset(.zero, animated: isAnimation)
            }
        }
        
        sliderViewAnimation(to: cell, isHorizontal: isHorizontal, isAnimation: isAnimation)
        
        reloadData()
    }
}
