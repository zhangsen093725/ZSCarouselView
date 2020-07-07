//
//  ZSScrollCarouseCustomView.swift
//  Pods-ZSCarouselView_Example
//
//  Created by Josh on 2020/7/6.
//

import UIKit

@objcMembers open class ZSScrollCarouseCustomView: ZSScrollCarouseView {
    
    var _isBeginDragging_: Bool = false
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(collectionViewLayout: UICollectionViewFlowLayout,
                            cellClass: ZSScrollCarouseCell.Type = ZSScrollCarouseCell.self) {
        self.init(frame: .zero)
        _collectionViewLayout_ = collectionViewLayout
        _cellClass_ = cellClass
    }
    
    open override func configCollectionView(_ collectionView: UICollectionView) {
        super.configCollectionView(collectionView)
        collectionView.isPagingEnabled = false
    }
}


// MARK: - UIScrollViewDelegate
extension ZSScrollCarouseCustomView {
    
    func calculationLoopScrollOffset() {
        
        let isHorizontal: Bool = collectionViewLayout.scrollDirection == .horizontal
        
        if isHorizontal
        {
            if _collectionView_.contentOffset.x <= 0
            {
                guard let cell = _collectionView_.cellForItem(at: IndexPath(item: 0, section: 0)) else { return }
                let offset = _collectionView_.contentSize.width - cell.frame.size.width - collectionViewLayout.itemSize.width - collectionViewLayout.minimumLineSpacing
                _collectionView_.setContentOffset(CGPoint(x: offset, y: 0), animated: false)

                if !_isBeginDragging_
                {
                    scrollViewWillBeginDecelerating(_collectionView_)
                }
            }
            else if _collectionView_.contentOffset.x >= _collectionView_.contentSize.width - _collectionView_.frame.width
            {
                guard let pre = _collectionView_.cellForItem(at: IndexPath(item: _loopScrollItemCount_ - 2, section: 0)) else { return }
                guard let next = _collectionView_.cellForItem(at: IndexPath(item: _loopScrollItemCount_ - 1, section: 0)) else { return }
                
                let offset = _collectionView_.contentOffset.x - pre.frame.origin.x + (next.frame.origin.x - pre.frame.maxX)
                _collectionView_.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
                
                if !_isBeginDragging_
                {
                    scrollViewWillBeginDecelerating(_collectionView_)
                }
            }
        }
        else
        {
            if _collectionView_.contentOffset.y <= 0
            {
                guard let cell = _collectionView_.cellForItem(at: IndexPath(item: 0, section: 0)) else { return }
                let offset = _collectionView_.contentSize.height - cell.frame.size.height - collectionViewLayout.itemSize.height - collectionViewLayout.minimumLineSpacing
                _collectionView_.setContentOffset(CGPoint(x: 0, y: offset), animated: false)

                if !_isBeginDragging_
                {
                    scrollViewWillBeginDecelerating(_collectionView_)
                }
            }
            else if _collectionView_.contentOffset.y >= _collectionView_.contentSize.height - _collectionView_.frame.height
            {
                guard let pre = _collectionView_.cellForItem(at: IndexPath(item: _loopScrollItemCount_ - 2, section: 0)) else { return }
                guard let next = _collectionView_.cellForItem(at: IndexPath(item: _loopScrollItemCount_ - 1, section: 0)) else { return }

                let offset = _collectionView_.contentOffset.y - pre.frame.origin.y + (next.frame.origin.y - pre.frame.maxY)
                _collectionView_.setContentOffset(CGPoint(x: 0, y: offset), animated: false)

                if !_isBeginDragging_
                {
                    scrollViewWillBeginDecelerating(_collectionView_)
                }
            }
        }
    }
    
    func calculationPage() -> Int {
        
        let xx = (_collectionView_.frame.width - collectionViewLayout.itemSize.width) * 0.5
        let yy = (_collectionView_.frame.height - collectionViewLayout.itemSize.height) * 0.5
        
        let itemWidth = collectionViewLayout.itemSize.width + collectionViewLayout.minimumLineSpacing
        let itemHeight = collectionViewLayout.itemSize.height + collectionViewLayout.minimumLineSpacing
        
        let offsetX = xx + _collectionView_.contentOffset.x
        let offsetY = yy + _collectionView_.contentOffset.y
        
        return collectionViewLayout.scrollDirection == .horizontal ? Int(offsetX / itemWidth  + 0.5) : Int(offsetY / itemHeight + 0.5)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isLoopScroll
        {
            calculationLoopScrollOffset()
        }
        
        let currentPage = calculationPage()
        
        guard currentPage != _cachePage_ else { return }
        
        _cachePage_ = currentPage
        
        guard currentPage != _loopScrollItemCount_ - 1 else { return }
        
        guard currentPage != 0 else { return }
        
        delegate?.zs_carouseViewDidScroll(self, index: currentPage - 1)
    }
    
    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        super.scrollViewWillBeginDragging(scrollView)
        
        _isBeginDragging_ = true
    }
    
    open override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        
        _isBeginDragging_ = false
        scrollViewWillBeginDecelerating(scrollView)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        let currentPage = calculationPage()
        
        let isHorizontal: Bool = collectionViewLayout.scrollDirection == .horizontal
        
        _collectionView_.scrollToItem(at: IndexPath(item: currentPage, section: 0), at: isHorizontal ? .centeredHorizontally : .centeredVertically, animated: true)
    }
}
