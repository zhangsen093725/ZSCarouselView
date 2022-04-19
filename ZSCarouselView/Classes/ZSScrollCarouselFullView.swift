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
        _cellClass_ = cellClass
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if collectionViewLayout.scrollDirection == .horizontal
        {
            _collectionView_.frame = CGRect(x: 0, y: 0, width: bounds.width + minimumSpacing, height: frame.height)
        }
        else
        {
            _collectionView_.frame = CGRect(x: 0, y: 0, width: bounds.width, height: frame.height  + minimumSpacing)
        }
    }
}



// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ZSScrollCarouselFullView {
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.zs_identifier, for: indexPath) as! ZSScrollCarouselCell
        
        if collectionViewLayout.scrollDirection == .horizontal
        {
            cell.minimumLineSpacing = minimumSpacing
            cell.minimumInteritemSpacing = 0
        }
        else
        {
            cell.minimumLineSpacing = 0
            cell.minimumInteritemSpacing = minimumSpacing
        }
        
        dataSource?.zs_configCarouseCell(cell, itemAt: scrollCarouseIndex(from: indexPath.item))
        
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
            if _collectionView_.contentOffset.x <= 0
            {
                _collectionView_.setContentOffset(CGPoint(x: collectionViewLayout.itemSize.width * CGFloat(_itemCount_), y: 0), animated: false)
            }
            else if Int(_collectionView_.contentOffset.x) >= Int(collectionViewLayout.itemSize.width) * (_loopScrollItemCount_ - 1)
            {
                _collectionView_.setContentOffset(CGPoint(x: collectionViewLayout.itemSize.width, y: 0), animated: false)
            }
        }
        else
        {
            if _collectionView_.contentOffset.y <= 0
            {
                _collectionView_.setContentOffset(CGPoint(x: 0, y: collectionViewLayout.itemSize.height * CGFloat(_itemCount_)), animated: false)
            }
            else if Int(_collectionView_.contentOffset.y) >= Int(collectionViewLayout.itemSize.height) * (_loopScrollItemCount_ - 1)
            {
                _collectionView_.setContentOffset(CGPoint(x: 0, y: collectionViewLayout.itemSize.height), animated: false)
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
        
        guard currentPage != _cachePage_ else { return }
        
        _cachePage_ = currentPage
        
        if isLoopScroll
        {
            guard currentPage != _loopScrollItemCount_ - 1 else { return }
            guard currentPage != 0 else { return }
            delegate?.zs_carouseViewDidScroll(self, index: currentPage - 1)
        }
        else
        {
            guard currentPage != _itemCount_ - 1 else { return }
            delegate?.zs_carouseViewDidScroll(self, index: currentPage)
        }
    }
}
