//
//  ZSDragStaticCollectionServe.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/3/11.
//

import UIKit

@objc public protocol ZSDragStaticCollectionServeDelegate {
    
    func zs_dragStaticCollectionView(didSelectItemAt indexPath: IndexPath)
    
    /// 处理数据源移除操作
    func zs_dragStaticCollectionView(removeDataSourceAt indexPath: IndexPath)
    
    /// 处理数据源插入操作
    func zs_dragStaticCollectionView(insertDataSourceAt indexPath: IndexPath)
}

@objc public protocol ZSDragStaticCollectionServeDataSource {
    
    func zs_dragStaticCollectionView(layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    func zs_dragStaticCollectionView(_ cell: ZSDragStaticItemView, forItemAt indexPath: IndexPath)
    
    @objc optional func zs_dragStaticCollectionView(layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    @objc optional func zs_dragStaticCollectionView(layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    @objc optional func zs_dragStaticCollectionView(layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
}

@objcMembers open class ZSDragStaticCollectionServe: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public weak var collectionView: UICollectionView?
    
    /// 当前正在拖拽的Point
    public var dragPoint: CGPoint = .zero
    
    /// 当前正在拖拽的Item的截图
    public var dragItemSnapshotView: UIView?
    
    /// 当前正在推拽的Item的IndexPath
    public var dragIndexPath: IndexPath?
    
    /// 需要移动的Item的IndexPath
    public var moveIndexPath: IndexPath?
    
    /// 当前正在推拽的Item
    public var dragCell: UICollectionViewCell?
    
    public var cellClass: ZSDragStaticItemView.Type = ZSDragStaticItemView.self
    
    public weak var delegate: ZSDragStaticCollectionServeDelegate?
    
    public weak var dataSource: ZSDragStaticCollectionServeDataSource?
    
    /// item count
    private var _itemCount_: Int = 0
    public var itemCount: Int = 0 {
        didSet {
            _itemCount_ = itemCount;
            collectionView?.reloadData()
        }
    }
    
    open func zs_bindCollectionView(_ collectionView: UICollectionView, register cellClass: ZSDragStaticItemView.Type = ZSDragStaticItemView.self) {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView = collectionView
        collectionView.register(cellClass, forCellWithReuseIdentifier: cellClass.zs_identifier)
    }
    
    open func zs_deleteItem(_ cell: ZSDragStaticItemView) {
        
        guard let editIndexPath = collectionView?.indexPath(for: cell) else { return }
        delegate?.zs_dragStaticCollectionView(removeDataSourceAt: editIndexPath)
        _itemCount_ -= 1
        collectionView?.deleteItems(at: [editIndexPath])
    }
    
    private func updateDataSourceForDragItem(_ isMoveToBack: Bool) {
        
        // 是否是向后移动
        isMoveToBack ? updateDataSourceForBackwardItem() : updateDataSourceForForwardItem()
    }
    
    // 先remove，再insert
    open func updateDataSourceForForwardItem() {
        
        guard let _dragIndexPath_ = dragIndexPath else { return }
        guard let _moveIndexPath_ = moveIndexPath else { return }
        
        delegate?.zs_dragStaticCollectionView(removeDataSourceAt: _dragIndexPath_)
        delegate?.zs_dragStaticCollectionView(insertDataSourceAt: _moveIndexPath_)
    }
    
    // 先insert插入，再remove
    open func updateDataSourceForBackwardItem() {
        
        guard let _dragIndexPath_ = dragIndexPath else { return }
        guard let _moveIndexPath_ = moveIndexPath else { return }
        
        delegate?.zs_dragStaticCollectionView(insertDataSourceAt: _moveIndexPath_)
        delegate?.zs_dragStaticCollectionView(removeDataSourceAt: _dragIndexPath_)
    }
    
    // TODO: GestureRecognizerAction
    open func itemGestureRecognizerStateBegin(_ gestureRecognizer: UIGestureRecognizer) {
        
        guard let cell = gestureRecognizer.view as? UICollectionViewCell else { return }
        
        dragItemSnapshotView = cell.snapshotView(afterScreenUpdates: true)
        dragItemSnapshotView?.center = cell.center
        collectionView?.addSubview(dragItemSnapshotView!)
        dragIndexPath = collectionView?.indexPath(for: cell)
        dragCell = cell
        dragCell?.isHidden = true
        dragPoint = gestureRecognizer.location(in: collectionView)
    }
    
    open func itemGestureRecognizerStateChaged(_ gestureRecognizer: UIGestureRecognizer) {
        
        guard dragItemSnapshotView != nil else { return }
        
        guard let _dragIndexPath_ = dragIndexPath else { return }
        
        let tranx: CGFloat = gestureRecognizer.location(ofTouch: 0, in: collectionView).x - dragPoint.x
        let trany:CGFloat = gestureRecognizer.location(ofTouch: 0, in: collectionView).y - dragPoint.y
        
        // 跟随偏移量拖动
        dragItemSnapshotView!.center = dragItemSnapshotView!.center.applying(CGAffineTransform(translationX: tranx, y: trany))
        
        // 更新拖动结果
        dragPoint = gestureRecognizer.location(ofTouch: 0, in: collectionView)
        
        // 遍历可见Item，根据勾股定理计算是否需要交换位置
        for _cell_ in collectionView?.visibleCells ?? [] {
            
            guard collectionView?.indexPath(for: _cell_) != _dragIndexPath_ else { continue }
            
            guard let _moveIndexPath_ = collectionView?.indexPath(for: _cell_) else { continue }
            
            // 计算偏移量
            let offset: CGFloat = sqrt(pow(dragItemSnapshotView!.center.y - _cell_.center.y, 2) + pow(dragItemSnapshotView!.center.x - _cell_.center.x, 2))
            
            if offset <= dragItemSnapshotView!.bounds.width * 0.5 {
                
                moveIndexPath = _moveIndexPath_
                // 更新数据源
                updateDataSourceForDragItem(_moveIndexPath_.item > _dragIndexPath_.item)
                
                collectionView?.moveItem(at: _dragIndexPath_, to: _moveIndexPath_)
                dragIndexPath = _moveIndexPath_
                break
            }
        }
    }
    
    open func itemGestureRecognizerStateEnd(_ gestureRecognizer: UIGestureRecognizer) {
        
        dragItemSnapshotView?.removeFromSuperview()
        dragCell?.isHidden = false
    }
    
    open func itemGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            
            itemGestureRecognizerStateBegin(gestureRecognizer)
            
        } else if gestureRecognizer.state == .changed {
            
            itemGestureRecognizerStateChaged(gestureRecognizer)
            
        } else if gestureRecognizer.state == .ended {
            
            itemGestureRecognizerStateEnd(gestureRecognizer)
        }
    }
    
    // TODO: UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return dataSource?.zs_dragStaticCollectionView?(layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) ?? 10
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return dataSource?.zs_dragStaticCollectionView?(layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) ?? 10
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return dataSource?.zs_dragStaticCollectionView?(layout: collectionViewLayout, insetForSectionAt: section) ?? .zero
    }
    
    // TODO: UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return _itemCount_
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ZSDragStaticItemView = collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.zs_identifier, for: indexPath) as! ZSDragStaticItemView
        cell.backgroundColor = .brown
        cell.itemGestureRecognizerHandle = { [weak self] (gestureRecognizer) in
            self?.itemGestureRecognizer(gestureRecognizer)
        }
        
        dataSource?.zs_dragStaticCollectionView(cell, forItemAt: indexPath)
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return dataSource?.zs_dragStaticCollectionView(layout: collectionViewLayout, sizeForItemAt: indexPath) ?? .zero
    }
    
    // UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.zs_dragStaticCollectionView(didSelectItemAt: indexPath)
    }
}
