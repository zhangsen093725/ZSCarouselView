//
//  ZSWaterFlowLayout.swift
//  ZSViewUtil
//
//  Created by Josh on 2020/7/14.
//

import UIKit

@objc public protocol ZSWaterFlowLayoutDelegate: UICollectionViewDelegateFlowLayout {
    
    /// collectionItem size
    func zs_collectionView(_ collectionView: UICollectionView,
                           layout: ZSWaterFlowLayout,
                           minimumSize: CGSize,
                           sizeForItemAt indexPath: IndexPath) -> CGSize
    
    /// 是否允许超过大小
    @objc optional func zs_collectionView(_ collectionView: UICollectionView,
                                          layout: ZSWaterFlowLayout,
                                          shouldBeyondSizeOf section: Int) -> Bool
    
    /// 设置每列的 inset（在sectionInset基础上，加上每列的 inset）
    @objc optional func zs_collectionView(_ collectionView: UICollectionView,
                                          layout: ZSWaterFlowLayout,
                                          insetForColumnAtIndex column: Int,
                                          columnCount: Int) -> UIEdgeInsets
    
    /// 每个section 列数（默认2列）
    @objc optional func zs_collectionView(_ collectionView: UICollectionView,
                                          layout: ZSWaterFlowLayout,
                                          columnNumberOf section: Int) -> Int
    
    /// section 的 header 与 上一组 section 的 footer 的间距（默认为0）
    @objc optional func zs_collectionView(_ collectionView: UICollectionView, layout: ZSWaterFlowLayout, sectionSpacingFor section: Int) -> CGFloat
}

@objcMembers open class ZSWaterFlowLayout: UICollectionViewFlowLayout {
    
    weak public var delegate: ZSWaterFlowLayoutDelegate? {
        
        return collectionView?.delegate as? ZSWaterFlowLayoutDelegate
    }
    
    /// 存放attribute的数组
    private var attributes: [UICollectionViewLayoutAttributes] = []
    
    /// 存放每组 section 最后一个长度
    private var columnLenghts: [CGFloat] = []
    
    /// collectionView 的 contentSize 的长度
    private var contentLenght: CGFloat = 0
    
    /// 记录上一组 section 最长一列的长度
    private var lastContentLenght: CGFloat = 0
    
    /// 返回长度最小的一列
    private var minLenghtColumn: Int {
        
        var min = CGFloat(MAXFLOAT)
        var column = 0
        
        for (index, vaule) in columnLenghts.enumerated()
        {
            if min > vaule
            {
                min = vaule
                column = index
            }
        }
        return column
    }
    
    /// 返回长度最大的一列
    private var maxLenghtColumn: Int {
        
        var max: CGFloat = 0
        var column = 0
        
        for (index, vaule) in columnLenghts.enumerated()
        {
            if max < vaule
            {
                max = vaule
                column = index
            }
        }
        return column
    }
    
    private var columnCount: Int = 2
    private var minimumSectionSpacing: CGFloat = 0
    
    open override func prepare() {
        super.prepare()
        
        contentLenght = 0
        lastContentLenght = 0
        
        columnLenghts.removeAll()
        attributes.removeAll()
        
        let sectionCount = collectionView?.numberOfSections ?? 0
        
        // 遍历section
        for section in 0..<sectionCount
        {
            let sectionIndexPath = IndexPath(item: 0, section: section)
            
            columnCount = delegate?.zs_collectionView?(collectionView!, layout:self, columnNumberOf: section) ?? 2
            columnCount = columnCount < 1 ? 1 : columnCount
            
            sectionInset = delegate?.collectionView?(collectionView!, layout:self, insetForSectionAt: section) ?? sectionInset
            minimumLineSpacing = delegate?.collectionView?(collectionView!, layout:self, minimumLineSpacingForSectionAt: section) ?? minimumLineSpacing
            minimumInteritemSpacing = delegate?.collectionView?(collectionView!, layout:self, minimumInteritemSpacingForSectionAt: section) ?? minimumInteritemSpacing
            headerReferenceSize = delegate?.collectionView?(collectionView!, layout:self, referenceSizeForHeaderInSection: section) ?? headerReferenceSize
            footerReferenceSize = delegate?.collectionView?(collectionView!, layout:self, referenceSizeForFooterInSection: section) ?? footerReferenceSize
            
            if section > 0
            {
                minimumSectionSpacing = delegate?.zs_collectionView?(collectionView!, layout: self, sectionSpacingFor: section) ?? 0
            }
            else
            {
                minimumSectionSpacing = 0
            }
            
            // 生成header
            if headerReferenceSize == .zero
            {
                contentLenght += minimumSectionSpacing
                contentLenght += (scrollDirection == .vertical ? self.sectionInset.top : self.sectionInset.left)
            }
            else if let header = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: sectionIndexPath)
            {
                attributes.append(header)
            }
            
            columnLenghts.removeAll()
            
            lastContentLenght = contentLenght
            
            // 初始化
            for _ in 0..<columnCount
            {
                columnLenghts.append(contentLenght)
            }
            
            let itemCount = collectionView?.numberOfItems(inSection: section) ?? 0
            
            for item in 0..<itemCount
            {
                let cellIndexPath = IndexPath(item: item, section: section)
                if let cell = layoutAttributesForItem(at: cellIndexPath)
                {
                    attributes.append(cell)
                }
            }
            
            // 初始化footer
            if footerReferenceSize == .zero
            {
                contentLenght += (scrollDirection == .vertical ? sectionInset.bottom : self.sectionInset.right)
            }
            else if let footer = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: sectionIndexPath)
            {
                attributes.append(footer)
            }
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return Array(attributes)
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let cell = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let minColumnLenght = columnLenghts[minLenghtColumn]
        let shouldBeyondSize = delegate?.zs_collectionView?(collectionView!, layout: self, shouldBeyondSizeOf: indexPath.section)
        
        if scrollDirection == .vertical
        {
            let width = collectionView!.frame.width - sectionInset.left - sectionInset.right - CGFloat(columnCount - 1) * minimumInteritemSpacing
            
            let minimumWidth = width / CGFloat(columnCount)
            
            let cellSize = self.delegate?.zs_collectionView(collectionView!, layout:self, minimumSize:CGSize(width: minimumWidth, height: CGFloat(MAXFLOAT)), sizeForItemAt: indexPath) ?? .zero
            
            var cellWidth: CGFloat = 0.0
            var cellHeight: CGFloat = 0.0
            
            var cellX: CGFloat = 0.0
            var cellY: CGFloat = 0.0
            
            if shouldBeyondSize == true && cellSize.width > minimumWidth
            {
                let columnInset = delegate?.zs_collectionView?(collectionView!, layout: self, insetForColumnAtIndex: 0, columnCount: 1) ?? .zero
                
                cellX = sectionInset.left + columnInset.left
                cellWidth = min(width - columnInset.right - columnInset.left, cellSize.width)
                cellY = columnLenghts[maxLenghtColumn] + columnInset.top
                cellHeight = cellSize.height + columnInset.bottom
            }
            else
            {
                let columnInset = delegate?.zs_collectionView?(collectionView!, layout: self, insetForColumnAtIndex: minLenghtColumn, columnCount: columnCount) ?? .zero
                
                let itemSpacing = CGFloat(minLenghtColumn) * (minimumWidth + minimumInteritemSpacing)
                
                cellX = sectionInset.left + itemSpacing + columnInset.left
                cellWidth = min(minimumWidth - columnInset.right - columnInset.left, cellSize.width)
                cellY = minColumnLenght + columnInset.top
                cellHeight = cellSize.height + columnInset.bottom
            }
            
            if cellY != self.lastContentLenght
            {
                cellY += minimumLineSpacing
            }
            
            cell.frame = CGRect(x: cellX, y: cellY, width: cellWidth, height: cellHeight)
            
            if shouldBeyondSize == true && cellSize.width > minimumWidth
            {
                for idx in 0..<columnCount
                {
                    columnLenghts[idx] = cell.frame.maxY
                }
            }
            else
            {
                columnLenghts[minLenghtColumn] = cell.frame.maxY
            }
        }
        else
        {
            let height = collectionView!.frame.height - sectionInset.top - sectionInset.bottom - CGFloat(columnCount - 1) * minimumLineSpacing
            
            let cellMinimumHeight = height / CGFloat(columnCount)
            
            let cellSize = self.delegate?.zs_collectionView(collectionView!, layout:self, minimumSize:CGSize(width: CGFloat(MAXFLOAT), height: cellMinimumHeight), sizeForItemAt: indexPath) ?? .zero
            
            var cellWidth: CGFloat = 0.0
            var cellHeight: CGFloat = 0.0
            
            var cellX: CGFloat = 0.0
            var cellY: CGFloat = 0.0
            
            if shouldBeyondSize == true && cellSize.height > cellMinimumHeight
            {
                let columnInset = delegate?.zs_collectionView?(collectionView!, layout: self, insetForColumnAtIndex: 0, columnCount: 1) ?? .zero
                
                cellY = sectionInset.top + columnInset.top
                cellHeight = cellSize.height - columnInset.bottom
                cellX = columnLenghts[maxLenghtColumn] + columnInset.left
                cellWidth = cellSize.width - columnInset.right
            }
            else
            {
                let columnInset = delegate?.zs_collectionView?(collectionView!, layout: self, insetForColumnAtIndex: minLenghtColumn, columnCount: columnCount) ?? .zero
                
                let itemSpacing = CGFloat(minLenghtColumn) * (cellMinimumHeight + minimumLineSpacing)
                
                cellY = sectionInset.top + itemSpacing + columnInset.top
                cellHeight = min(cellMinimumHeight, cellSize.height) - columnInset.bottom
                cellX = minColumnLenght + columnInset.left
                cellWidth = cellSize.width - columnInset.right
            }
            
            if cellX != self.lastContentLenght
            {
                cellX += minimumInteritemSpacing
            }
            
            cell.frame = CGRect(x: cellX, y: cellY, width: cellWidth, height: cellHeight)
            
            if shouldBeyondSize == true && cellSize.height > cellMinimumHeight
            {
                for idx in 0..<columnCount
                {
                    columnLenghts[idx] = cell.frame.maxX
                }
            }
            else
            {
                columnLenghts[minLenghtColumn] = cell.frame.maxX
            }
        }
        
        if contentLenght < minColumnLenght
        {
            contentLenght = minColumnLenght
        }
        
        //取最大的
        for vaule in columnLenghts
        {
            if contentLenght < vaule
            {
                contentLenght = vaule
            }
        }
        
        return cell
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let supplementaryView = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        if elementKind == UICollectionView.elementKindSectionHeader
        {
            contentLenght += minimumSectionSpacing
            
            if scrollDirection == .vertical
            {
                supplementaryView.frame = CGRect(x: 0, y: contentLenght, width: headerReferenceSize.width, height: headerReferenceSize.height)
                contentLenght += headerReferenceSize.height
                contentLenght += sectionInset.top
            }
            else
            {
                supplementaryView.frame = CGRect(x: contentLenght, y: 0, width: headerReferenceSize.width, height: headerReferenceSize.height)
                contentLenght += headerReferenceSize.width
                contentLenght += sectionInset.left
            }
        }
        else if elementKind == UICollectionView.elementKindSectionFooter
        {
            if scrollDirection == .vertical
            {
                contentLenght += sectionInset.bottom
                supplementaryView.frame = CGRect(x: 0, y: contentLenght, width: footerReferenceSize.width, height: footerReferenceSize.height)
                contentLenght += footerReferenceSize.height
            }
            else
            {
                contentLenght += sectionInset.right
                supplementaryView.frame = CGRect(x: contentLenght, y: 0, width: footerReferenceSize.width, height: footerReferenceSize.height)
                contentLenght += footerReferenceSize.width
            }
        }
        return supplementaryView
    }
    
    open override var collectionViewContentSize: CGSize {
        
        if scrollDirection == .vertical
        {
            return CGSize(width: 0, height: self.contentLenght)
        }
        else
        {
            return CGSize(width: self.contentLenght, height: 0)
        }
    }
}
