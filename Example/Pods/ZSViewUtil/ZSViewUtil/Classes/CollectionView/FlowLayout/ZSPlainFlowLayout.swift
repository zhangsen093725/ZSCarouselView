//
//  ZSPlainFlowLayout.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/10.
//
//  参考MTPlainFlowLayout

import UIKit

@objcMembers open class ZSPlainFlowLayout: UICollectionViewFlowLayout {
    // 设置停留偏移量Y，默认为64
    public var plainOffset: CGFloat = 64
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let isVertical = scrollDirection == .vertical
        
        // 获取collectionView中的item attributes（包括cell和header、footer这些）
        var superAttributesArray: [UICollectionViewLayoutAttributes] = []
        if let _superAttributesArray_ = super.layoutAttributesForElements(in: rect) {
            superAttributesArray = _superAttributesArray_
        }
        
        // 创建当前不在屏幕中的section索引的集合
        let noneHeaderSections = NSMutableIndexSet()
        
        // 遍历所有的item attributes
        for attributes in superAttributesArray {
            // 将同一个section中的cell归类
            if attributes.representedElementCategory == .cell {
                noneHeaderSections.add(attributes.indexPath.section)
            }
        }
        
        for attributes in superAttributesArray {
            if let kind = attributes.representedElementKind {
                // 如果当前的元素是一个header，将header所在的section从数组中移除
                if kind == UICollectionView.elementKindSectionHeader {
                    noneHeaderSections.remove(attributes.indexPath.section)
                }
            }
        }
        
        // 遍历当前不在屏幕中的section
        noneHeaderSections.enumerate { (section, stop) in
            // 取到当前section中第一个item的indexPath
            let indexPath = IndexPath(item: 0, section: section)
            // 获取当前section在正常情况下已经离开屏幕的header结构信息
            if let attributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                // 如果当前分区确实有因为离开屏幕而被系统回收的header，将该header结构信息重新加入到superArray中去
                superAttributesArray.append(attributes)
            }
        }

        // 遍历superArray，改变header结构信息中的参数，使它可以在当前section还没完全离开屏幕的时候一直显示
        for attributes in superAttributesArray {
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                let section = attributes.indexPath.section
                
                let firstItemIndexPath = IndexPath(item: 0, section: section)
                
                var numberOfItemsInSection = 0
                // 得到当前header所在分区的cell的数量
                if let number = collectionView?.numberOfItems(inSection: section) {
                    numberOfItemsInSection = number
                }
                
                // 得到最后一个item的indexPath
                let lastItemIndexPath = IndexPath(item: max(0, numberOfItemsInSection-1), section: section)
                
                // 得到第一个item和最后一个item的结构信息
                let firstItemAttributes: UICollectionViewLayoutAttributes!
                let lastItemAttributes: UICollectionViewLayoutAttributes!
                if numberOfItemsInSection > 0 {
                    // cell有值，则获取第一个cell和最后一个cell的结构信息
                    firstItemAttributes = layoutAttributesForItem(at: firstItemIndexPath)
                    lastItemAttributes = layoutAttributesForItem(at: lastItemIndexPath)
                } else {
                    // cell没值,就新建一个UICollectionViewLayoutAttributes
                    firstItemAttributes = UICollectionViewLayoutAttributes()
                    // 然后模拟出在当前分区中的唯一一个cell，cell在header的下面，高度为0，还与header隔着可能存在的sectionInset的top
                    
                    if isVertical {
                        let itemY = attributes.frame.maxY + sectionInset.top
                        firstItemAttributes.frame = CGRect(x: 0, y: itemY, width: 0, height: 0)
                    } else {
                        let itemX = attributes.frame.maxX + sectionInset.left
                        firstItemAttributes.frame = CGRect(x: itemX, y: 0, width: 0, height: 0)
                    }
                    
                    // 因为只有一个cell，所以最后一个cell等于第一个cell
                    lastItemAttributes = firstItemAttributes
                }
                
                // 获取当前header的frame
                var rect = attributes.frame
                
                // 当前的滑动距离 + 偏移量，默认为64
                var offset: CGFloat = 0
                if let _offset_ = (isVertical ? collectionView?.contentOffset.y : collectionView?.contentOffset.x) {
                    offset = _offset_
                }
                offset = offset + plainOffset
                
                if isVertical {
                    // 第一个cell的y值 - 当前header的高度 - 可能存在的sectionInset的top
                    let headerY = firstItemAttributes.frame.origin.y - rect.size.height - sectionInset.top
                    
                    // 哪个大取哪个，保证header悬停
                    // 针对当前header基本上都是offset更加大，针对下一个header则会是headerY大，各自处理
                    let maxY = max(offset, headerY)
                    
                    // 最后一个cell的y值 + 最后一个cell的高度 + 可能存在的sectionInset的bottom - 当前header的高度
                    // 当当前section的footer或者下一个section的header接触到当前header的底部，计算出的headerMissingY即为有效值
                    let headerMissingY = lastItemAttributes.frame.maxY + sectionInset.bottom - rect.size.height
                    
                    // 给rect的y赋新值，因为在最后消失的临界点要跟谁消失，所以取小
                    rect.origin.y = min(maxY, headerMissingY)
                } else {
                    let headerX = firstItemAttributes.frame.origin.x - rect.size.height - sectionInset.left
                    let maxX = max(offset, headerX)
                    let headerMissingX = lastItemAttributes.frame.maxX + sectionInset.right - rect.size.width
                    rect.origin.x = min(maxX, headerMissingX)
                }
                
                // 给header的结构信息的frame重新赋值
                attributes.frame = rect
                
                // 如果按照正常情况下, header离开屏幕被系统回收，而header的层次关系又与cell相等，如果不去理会，会出现cell在header上面的情况
                
                // 通过打印可以知道cell的层次关系zIndex数值为0，我们可以将header的zIndex设置成1，如果不放心，也可以将它设置成非常大
                attributes.zIndex = 1407
            }
        }
        return superAttributesArray
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

