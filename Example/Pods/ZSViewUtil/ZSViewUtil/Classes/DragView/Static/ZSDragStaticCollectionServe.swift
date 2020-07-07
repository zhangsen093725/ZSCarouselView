//
//  ZSDragStaticCollectionServe.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/3/11.
//

import UIKit

@objcMembers open class ZSDragStaticCollectionServe: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public weak var collectionView: UICollectionView?
    
    public var dragPoint: CGPoint = .zero
    
    public var dragItemSnapshotView: UIView?
    
    public var dragIndexPath: IndexPath?
    
    public var moveIndexPath: IndexPath?
    
    public var dragCell: UICollectionViewCell?
    
    open func setterCollectionView(_ collectionView: UICollectionView) {
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView = collectionView
        configCollectionView(collectionView)
    }
    
    open func configCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(ZSDragStaticItemView.self, forCellWithReuseIdentifier: NSStringFromClass(ZSDragStaticItemView.self))
    }
    
    private func updateDataSourceForDragItem(_ isMoveToBack: Bool) {
        
        // 是否是向后移动
        isMoveToBack ? updateDataSourceForBackwardItem() : updateDataSourceForForwardItem()
    }
    
    // 先remove，再insert
    open func updateDataSourceForForwardItem() {
        // let data = DataSource[dragIndexPath.item]
        // DataSource.remove(at: dragIndexPath.item)
        // DataSource.insert(data, at: moveIndexPath.item)
    }
    
    // 先insert插入，再remove
    open func updateDataSourceForBackwardItem() {
        // let data = DataSource[dragIndexPath.item]
        // DataSource.insert(data, at: moveIndexPath.item)
        // DataSource.remove(at: dragIndexPath.item)
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
    
    // TODO: EditAction
    open func itemEditForCell(_ cell: UICollectionViewCell) {
        
        //        guard let editIndexPath = collectionView?.indexPath(for: cell) else { return }
        //        DataSource.remove(at: dragIndexPath.item)
        //        collectionView?.deleteItems(at: editIndexPath)
    }
    
    // TODO: UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return .zero
    }
    
    // TODO: UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ZSDragStaticItemView = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ZSDragStaticItemView.self), for: indexPath) as! ZSDragStaticItemView
        cell.backgroundColor = .brown
        cell.itemGestureRecognizerHandle = { [weak self] (gestureRecognizer) in
            self?.itemGestureRecognizer(gestureRecognizer)
        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 80, height: 80)
    }
    
    // UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
