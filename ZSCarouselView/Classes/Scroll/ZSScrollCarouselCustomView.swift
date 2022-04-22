//
//  ZSScrollCarouselCustomView.swift
//  Pods-ZSCarouselView_Example
//
//  Created by Josh on 2020/7/6.
//

import UIKit

@objcMembers open class ZSScrollCarouselCustomView: ZSScrollCarouselView {
    
    var _isBeginDragging: Bool = false
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(collectionViewLayout: UICollectionViewFlowLayout,
                            cellClass: ZSScrollCarouselCell.Type = ZSScrollCarouselCell.self) {
        self.init(frame: .zero)
        _collectionViewLayout = collectionViewLayout
        _cellClass = cellClass
    }
    
    open override func configCollectionView(_ collectionView: UICollectionView) {
        super.configCollectionView(collectionView)
        collectionView.isPagingEnabled = false
    }
}


// MARK: - UIScrollViewDelegate
extension ZSScrollCarouselCustomView {
    
    func calculationLoopScrollOffset() {
        
        let isHorizontal: Bool = collectionViewLayout.scrollDirection == .horizontal
        
        if isHorizontal
        {
            if _collectionView.contentOffset.x <= 0
            {
                guard let cell = _collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) else { return }
                let offset = _collectionView.contentSize.width - cell.frame.size.width - collectionViewLayout.itemSize.width - collectionViewLayout.minimumLineSpacing
                _collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)

                if !_isBeginDragging
                {
                    scrollViewWillBeginDecelerating(_collectionView)
                }
            }
            else if _collectionView.contentOffset.x >= _collectionView.contentSize.width - _collectionView.frame.width
            {
                guard let pre = _collectionView.cellForItem(at: IndexPath(item: _loopScrollItemCount - 2, section: 0)) else { return }
                guard let next = _collectionView.cellForItem(at: IndexPath(item: _loopScrollItemCount - 1, section: 0)) else { return }
                
                let offset = _collectionView.contentOffset.x - pre.frame.origin.x + (next.frame.origin.x - pre.frame.maxX)
                _collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
                
                if !_isBeginDragging
                {
                    scrollViewWillBeginDecelerating(_collectionView)
                }
            }
        }
        else
        {
            if _collectionView.contentOffset.y <= 0
            {
                guard let cell = _collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) else { return }
                let offset = _collectionView.contentSize.height - cell.frame.size.height - collectionViewLayout.itemSize.height - collectionViewLayout.minimumLineSpacing
                _collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)

                if !_isBeginDragging
                {
                    scrollViewWillBeginDecelerating(_collectionView)
                }
            }
            else if _collectionView.contentOffset.y >= _collectionView.contentSize.height - _collectionView.frame.height
            {
                guard let pre = _collectionView.cellForItem(at: IndexPath(item: _loopScrollItemCount - 2, section: 0)) else { return }
                guard let next = _collectionView.cellForItem(at: IndexPath(item: _loopScrollItemCount - 1, section: 0)) else { return }

                let offset = _collectionView.contentOffset.y - pre.frame.origin.y + (next.frame.origin.y - pre.frame.maxY)
                _collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)

                if !_isBeginDragging
                {
                    scrollViewWillBeginDecelerating(_collectionView)
                }
            }
        }
    }
    
    func calculationPage() -> Int {
        
        let xx = (_collectionView.frame.width - collectionViewLayout.itemSize.width) * 0.5
        let yy = (_collectionView.frame.height - collectionViewLayout.itemSize.height) * 0.5
        
        let width = collectionViewLayout.itemSize.width + collectionViewLayout.minimumLineSpacing
        let height = collectionViewLayout.itemSize.height + collectionViewLayout.minimumLineSpacing
        
        let offsetX = xx + _collectionView.contentOffset.x
        let offsetY = yy + _collectionView.contentOffset.y
        
        return Int((collectionViewLayout.scrollDirection == .horizontal ? offsetX / width : offsetY / height) + 0.5)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isLoopScroll
        {
            calculationLoopScrollOffset()
        }
        
        let currentPage = calculationPage()
        
        guard currentPage != _cachePage else { return }
        
        _cachePage = currentPage
        
        if isLoopScroll
        {
            guard currentPage != _loopScrollItemCount - 1 else { return }
            guard currentPage != 0 else { return }
            delegate?.zs_carouseViewDidScroll(self, index: currentPage - 1)
        }
        else
        {
            guard currentPage != _itemCount - 1 else { return }
            delegate?.zs_carouseViewDidScroll(self, index: currentPage)
        }
    }
    
    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        super.scrollViewWillBeginDragging(scrollView)
        
        _isBeginDragging = true
    }
    
    open override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        
        _isBeginDragging = false
        scrollViewWillBeginDecelerating(scrollView)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        let currentPage = calculationPage()
        
        let isHorizontal = collectionViewLayout.scrollDirection == .horizontal
        self.collectionView.scrollToItem(at: IndexPath(item: currentPage, section: 0), at: isHorizontal ? .centeredHorizontally : .centeredVertically, animated: true)
    }
}
