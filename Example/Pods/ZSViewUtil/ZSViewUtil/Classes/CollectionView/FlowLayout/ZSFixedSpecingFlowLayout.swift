//
//  ZSFixedSpecingFlowLayout.swift
//  ZSViewUtil
//
//  Created by Josh on 2020/8/28.
//

import UIKit

@objc public enum ZSFixedSpecingAlignment: Int {
    
    case Left = 0, Center = 1, Right = 2
}

@objcMembers open class ZSFixedSpecingFlowLayout: UICollectionViewFlowLayout {
    
    private override init() {
        
        super.init()
    }
    
    private var _alignment_: ZSFixedSpecingAlignment = .Left
    private var _isLineBreakByClipping_: Bool = true
    
    convenience public init(with alignment: ZSFixedSpecingAlignment = .Left,
                            isLineBreakByClipping: Bool = true,
                            interitemSpacing: CGFloat = 0,
                            sectionInset: UIEdgeInsets = .zero) {
        
        self.init()
        _alignment_ = alignment
        _isLineBreakByClipping_ = isLineBreakByClipping
        minimumInteritemSpacing = interitemSpacing
        self.sectionInset = sectionInset
        scrollDirection = .vertical
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var scrollDirection: UICollectionView.ScrollDirection {
        
        set {
            super.scrollDirection = .vertical
        }
        
        get {
           return .vertical
        }
    }
    
    /**
     * 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性）
     * 这个方法的返回值决定了rect范围内所有元素的排布（frame）
     */
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // 获得super已经计算好的布局的属性
        let origins = super.layoutAttributesForElements(in: rect) ?? []
        
        let maxWidth = (collectionView!.frame.width - sectionInset.left - sectionInset.right)
        
        if _isLineBreakByClipping_ && (origins.first?.frame.maxX ?? 0) > maxWidth
        {
            return []
        }
        
        var subAttributes: [UICollectionViewLayoutAttributes] = []
        
        // 计算collectionView最中心点的值
        for (index, attribute) in origins.enumerated()
        {
            if attribute.representedElementCategory != .cell { continue }
            
            let pre = index > 0 ? origins[index - 1] : nil
            
            if pre?.frame.minY == attribute.frame.minY && pre != nil
            {
                attribute.frame.origin.x = pre!.frame.maxX + minimumInteritemSpacing
            }
            else
            {
                if collectionView?.isScrollEnabled == false
                {
                    let isOutOfFrame = attribute.frame.maxY + sectionInset.bottom > collectionView!.frame.height
                
                    if isOutOfFrame
                    {
                        if _isLineBreakByClipping_ == false
                        {
                            attribute.frame.origin.x = (pre?.frame.maxX ?? 0) + minimumInteritemSpacing
                            attribute.frame.origin.y = pre?.frame.minY ?? 0
                            attribute.frame.size.width = collectionView!.frame.width - attribute.frame.minX - sectionInset.right
                            
                            if attribute.frame.width > 20
                            {
                                subAttributes.append(attribute.copy() as! UICollectionViewLayoutAttributes)
                            }
                        }
                        
                        break
                    }
                }
                
                attribute.frame.origin.x = sectionInset.left
            }
            
            subAttributes.append(attribute.copy() as! UICollectionViewLayoutAttributes)
        }
        
        switch _alignment_
        {
        case .Left:
            return Array(subAttributes)
        case .Right:
            
            var tempArray: [UICollectionViewLayoutAttributes] = []
            var preIndex = 0
            
            for (index, attribute) in subAttributes.enumerated()
            {
                let pre = index > 0 ? subAttributes[index - 1] : nil
                
                /// 上一行的右对齐
                if pre?.frame.minY != attribute.frame.minY && pre != nil
                {
                    tempArray += cellsAlignmentRight(from: subAttributes, start: preIndex, end: index)
                    preIndex = index
                }
                /// 最后一行的右对齐
                else if index == subAttributes.count - 1
                {
                    tempArray += cellsAlignmentRight(from: subAttributes, start: preIndex, end: subAttributes.count)
                }
            }
            
            return Array(tempArray)
        case .Center:
            
            var tempArray: [UICollectionViewLayoutAttributes] = []
            var preIndex = 0
            
            for (index, attribute) in subAttributes.enumerated()
            {
                let pre = index > 0 ? subAttributes[index - 1] : nil
                
                /// 上一行的居中布局
                if pre?.frame.minY != attribute.frame.minY && pre != nil
                {
                    tempArray += cellsAlignmentCenter(from: subAttributes, last: pre!, start: preIndex, end: index)
                    preIndex = index
                }
                /// 最后一行的居中布局
                else if index == subAttributes.count - 1
                {
                    tempArray += cellsAlignmentCenter(from: subAttributes, last: attribute, start: preIndex, end: subAttributes.count)
                }
            }
            
            return Array(tempArray)
        }
    }
    
    func cellsAlignmentRight(from subAttributes: [UICollectionViewLayoutAttributes],
                             start: Int, end: Int) -> [UICollectionViewLayoutAttributes] {
        
        var tempArray: [UICollectionViewLayoutAttributes] = []
        
        let reversedAttributes: [UICollectionViewLayoutAttributes] = subAttributes[start..<end].reversed()
        
        for (index, attribute) in reversedAttributes.enumerated()
        {
            let pre = index > 0 ? reversedAttributes[index - 1] : nil
            
            /// 同一行的 Cell 修改 frame
            if pre?.frame.minY == attribute.frame.minY && pre != nil
            {
                attribute.frame.origin.x = pre!.frame.minX - attribute.frame.size.width - minimumInteritemSpacing
            }
            /// 修改每行第一个 Cell 的 frame
            else
            {
                attribute.frame.origin.x = collectionView!.frame.maxX - attribute.frame.size.width - sectionInset.right
            }
            
            tempArray.append(attribute)
        }
        
        return Array(tempArray)
    }
    
    func cellsAlignmentCenter(from subAttributes: [UICollectionViewLayoutAttributes],
                              last cell: UICollectionViewLayoutAttributes,
                              start: Int, end: Int) -> [UICollectionViewLayoutAttributes] {
        
        let x = (self.collectionView!.frame.width + sectionInset.left - cell.frame.maxX) * 0.5
        
        var tempArray: [UICollectionViewLayoutAttributes] = []
        
        let _subAttributes = Array(subAttributes[start..<end])
        
        for (index, attribute) in _subAttributes.enumerated()
        {
            let pre = index > 0 ? _subAttributes[index - 1] : nil
            
            /// 同一行的 Cell 修改 frame
            if pre?.frame.minY == attribute.frame.minY && pre != nil
            {
                attribute.frame.origin.x = pre!.frame.maxX + minimumInteritemSpacing
            }
            /// 修改每行第一个 Cell 的 frame
            else
            {
                attribute.frame.origin.x = x
            }
            
            tempArray.append(attribute)
        }
        
        return Array(tempArray)
    }
    
    /**
     * 当collectionView的显示范围发生改变的时候，是否需要重新刷新布局
     * 一旦重新刷新布局，就会重新调用下面的方法：
     * 1.prepareLayout
     * 2.layoutAttributesForElementsInRect:方法
     */
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
