//
//  ZSFocusFlowLayout.swift
//  Pods-ZSViewUtil_Example
//
//  Created by Josh on 2020/7/1.
//

import UIKit

@objcMembers open class ZSFocusFlowLayout: UICollectionViewFlowLayout {
    
    /// 聚焦位置放大的倍数，默认是 1.1
    public var zoomScale: CGFloat = 1.1
    
    /*
     返回值决定了collectionView停止滚动时, 最终的偏移量
     velocity: 滚动速率, 通过这个参数可以了解到滚动方向
     */
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        // 计算出最终显示的矩形框
        var elementRect: CGRect = .zero
        
        elementRect.origin = proposedContentOffset
        elementRect.size = collectionView?.frame.size ?? .zero
        
        // 获得super已经计算好的布局的属性
        let attributes: [UICollectionViewLayoutAttributes] = Array(super.layoutAttributesForElements(in: elementRect) ?? [])
        
        var min = CGFloat(MAXFLOAT)
        
        // 计算collectionView最中心点的值
        if scrollDirection == .horizontal
        {
            let centerX = proposedContentOffset.x + elementRect.size.width * 0.5
            
            for attribute in attributes
            {
                if fabsf(Float(min)) > fabsf(Float(attribute.center.x - centerX))
                {
                    min = attribute.center.x - centerX
                }
            }
            elementRect.origin.x += min
        }
        else
        {
            let centerY = proposedContentOffset.y + elementRect.size.height * 0.5
            
            for attribute in attributes
            {
                if fabsf(Float(min)) > fabsf(Float(attribute.center.y - centerY))
                {
                    min = attribute.center.y - centerY
                }
            }
            elementRect.origin.y += min
        }
        
        return proposedContentOffset
    }
    
    /**
     * 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性）
     * 这个方法的返回值决定了rect范围内所有元素的排布（frame）
     */
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // 获得super已经计算好的布局的属性
        let origins = super.layoutAttributesForElements(in: rect) ?? []
        let attributes: [UICollectionViewLayoutAttributes] = origins.map({$0.copy() as! UICollectionViewLayoutAttributes})
        
        // 计算collectionView最中心点的值
        if scrollDirection == .horizontal
        {
            let centerX = (collectionView?.contentOffset.x ?? 0) + (collectionView?.frame.size.width ?? 0) * 0.5
            
            for attribute in attributes
            {
                let distance = CGFloat(fabsf(Float(attribute.center.x - centerX)))
                let zoom = collectionView?.frame.size.width == 0 ? 0 : zoomScale - distance / collectionView!.frame.size.width * 0.5
                attribute.transform3D = CATransform3DMakeScale(zoom, zoom, 5.5)
            }
        }
        else
        {
            let centerY = (collectionView?.contentOffset.y ?? 0) + (collectionView?.frame.size.height ?? 0) * 0.5
            
            for attribute in attributes
            {
                let distance = CGFloat(fabsf(Float(attribute.center.y - centerY)))
                let zoom = collectionView?.frame.size.height == 0 ? 0 : zoomScale - distance / collectionView!.frame.size.height * 0.5
                attribute.transform3D = CATransform3DMakeScale(zoom, zoom, 5.5)
            }
        }
        
        return attributes
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
