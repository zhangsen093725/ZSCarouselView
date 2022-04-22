//
//  ZSScrollCarouselFullView.swift
//  Pods-ZSCarouselView_Example
//
//  Created by Josh on 2020/7/3.
//

import UIKit

@objcMembers open class ZSScrollCarouselFullView: ZSScrollCarouselView {
    
    /// item 之间的间隙
    public var minimumSpacing: CGFloat = 0
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(scrollDirection: UICollectionView.ScrollDirection,
                            cellClass: ZSScrollCarouselCell.Type = ZSScrollCarouselCell.self) {
        
        self.init(frame: .zero)
        collectionViewLayout.scrollDirection = scrollDirection
        _cellClass = cellClass
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
//        if collectionViewLayout.scrollDirection == .horizontal
//        {
//            _collectionView.frame = CGRect(x: 0, y: 0, width: bounds.width + minimumSpacing, height: frame.height)
//        }
//        else
//        {
//            _collectionView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: frame.height  + minimumSpacing)
//        }
    }
}



// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ZSScrollCarouselFullView {
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        
        if let __cell = cell as? ZSScrollCarouselCell
        {
            if collectionViewLayout.scrollDirection == .horizontal
            {
                __cell.minimumInteritemSpacing = minimumSpacing
                __cell.minimumLineSpacing = 0
            }
            else
            {
                __cell.minimumInteritemSpacing = 0
                __cell.minimumLineSpacing = minimumSpacing
            }
        }
        return cell
    }
    
    public override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSize = collectionView.bounds.size
        
        self.collectionViewLayout.itemSize = itemSize
        
        return itemSize
    }
    
    public override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    public override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}



// MARK: - UIScrollViewDelegate
extension ZSScrollCarouselFullView {
    
    func calculationLoopScrollOffset() {
        
        let isHorizontal: Bool = collectionViewLayout.scrollDirection == .horizontal
        
        if isHorizontal
        {
            if _collectionView.contentOffset.x <= 0
            {
                _collectionView.setContentOffset(CGPoint(x: collectionViewLayout.itemSize.width * CGFloat(_itemCount), y: 0), animated: false)
            }
            else if Int(_collectionView.contentOffset.x) >= Int(collectionViewLayout.itemSize.width) * (_loopScrollItemCount - 1)
            {
                _collectionView.setContentOffset(CGPoint(x: collectionViewLayout.itemSize.width, y: 0), animated: false)
            }
        }
        else
        {
            if _collectionView.contentOffset.y <= 0
            {
                _collectionView.setContentOffset(CGPoint(x: 0, y: collectionViewLayout.itemSize.height * CGFloat(_itemCount)), animated: false)
            }
            else if Int(_collectionView.contentOffset.y) >= Int(collectionViewLayout.itemSize.height) * (_loopScrollItemCount - 1)
            {
                _collectionView.setContentOffset(CGPoint(x: 0, y: collectionViewLayout.itemSize.height), animated: false)
            }
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isLoopScroll
        {
            calculationLoopScrollOffset()
        }
        
        let offsetX = collectionViewLayout.itemSize.width * 0.5 + scrollView.contentOffset.x
        let offsetY = collectionViewLayout.itemSize.height * 0.5 + scrollView.contentOffset.y
        
        let currentPage = collectionViewLayout.scrollDirection == .horizontal ? Int(offsetX / collectionViewLayout.itemSize.width) : Int(offsetY / collectionViewLayout.itemSize.height)
        
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
}
