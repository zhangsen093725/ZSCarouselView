//
//  ZSDragCollectionViewServe.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/3.
//

import UIKit

@objcMembers open class ZSDragCollectionViewServe: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public weak var dragCollectView: ZSDragCollectionView?
    
    open func setterDragCollectionView(_ dragCollectView: ZSDragCollectionView) {
        dragCollectView.collectionView.delegate = self
        dragCollectView.collectionView.dataSource = self
        self.dragCollectView = dragCollectView
        configCollectionView(dragCollectView.collectionView)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(itemGestureRecognizer(_:)))
        dragCollectView.collectionView.addGestureRecognizer(longPress)
    }
    
    open func configCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell.self))
    }
    
    open func configCollectionItem() {
        
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
    @available(iOS 9.0, *)
    open func itemGestureRecognizerStateBegin(_ gestureRecognizer: UIGestureRecognizer) {
        
        let dragPoint = gestureRecognizer.location(in: gestureRecognizer.view)
        guard let selectedIndexPath = dragCollectView?.collectionView.indexPathForItem(at: dragPoint) else { return }
        dragCollectView?.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
    }
    
    @available(iOS 9.0, *)
    open func itemGestureRecognizerStateChaged(_ gestureRecognizer: UIGestureRecognizer) {
        
        dragCollectView?.collectionView.updateInteractiveMovementTargetPosition( gestureRecognizer.location(in: gestureRecognizer.view))
    }
    
    @available(iOS 9.0, *)
    open func itemGestureRecognizerStateEnd(_ gestureRecognizer: UIGestureRecognizer) {
        
        dragCollectView?.collectionView.endInteractiveMovement()
    }
    
    @available(iOS 9.0, *)
    open func itemGestureCanceledOrFailed(_ gestureRecognizer: UIGestureRecognizer) {
        
        dragCollectView?.collectionView.cancelInteractiveMovement()
    }
    
    open func itemGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        
        if #available(iOS 9.0, *) {
            if gestureRecognizer.state == .began {
                
                itemGestureRecognizerStateBegin(gestureRecognizer)
                
            } else if gestureRecognizer.state == .changed {
                
                itemGestureRecognizerStateChaged(gestureRecognizer)
                
            } else if gestureRecognizer.state == .ended {
                
                itemGestureRecognizerStateEnd(gestureRecognizer)
                
            } else {
                
                itemGestureCanceledOrFailed(gestureRecognizer)
            }
        } else {
            // Fallback on earlier versions
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
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.self), for: indexPath)
        cell.backgroundColor = .brown
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 80, height: 80)
    }
    
    // UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    @available(iOS 9.0, *)
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    @available(iOS 9.0, *)
    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        updateDataSourceForDragItem(destinationIndexPath.item > sourceIndexPath.item)
    }
}
