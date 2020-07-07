//
//  ZSTabPageViewServe.swift
//  JadeToB
//
//  Created by 张森 on 2020/1/13.
//  Copyright © 2020 张森. All rights reserved.
//

import UIKit

@objc public protocol ZSTabViewServeDelegate {
    func zs_tabViewDidSelected(at index: Int)
}

@objc public protocol ZSTabViewServeDataSource {
    
    @objc func zs_configTabCellSize(forItemAt index: Int) -> CGSize
    @objc func zs_configTabCell(_ cell: ZSTabCell, forItemAt index: Int)
}

@objcMembers open class ZSTabViewServe: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public weak var collectionView: ZSTabView? {
        
        didSet {
            oldValue?.removeObserver(self, forKeyPath: "frame")
            collectionView?.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        }
    }
    
    public var cellClass: ZSTabCell.Type = ZSTabCell.self
    
    public weak var delegate: ZSTabViewServeDelegate?
    
    public weak var dataSource: ZSTabViewServeDataSource?
    
    /// tab count
    public var tabCount: Int = 0 {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// tab 之间的间隙
    public var minimumSpacing: CGFloat = 8 {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    private var _selectIndex_: Int = 0
    
    /// 当前选择的 tab 索引
    public var selectIndex: Int { return _selectIndex_ }
    
    private override init() {
        super.init()
    }
    
    public convenience init(selectIndex: Int) {
        self.init()
        _selectIndex_ = selectIndex
    }
    
    open func zs_setSelectedIndex(_ index: Int) {
        _selectIndex_ = index
        collectionView?.beginScrollToIndex(selectIndex, isAnimation: true)
    }
    
    /// tab insert
    public var tabViewInsert: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    public func zs_bind(collectionView: ZSTabView, register cellClass: ZSTabCell.Type) {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(cellClass, forCellWithReuseIdentifier: cellClass.zs_identifier)
        
        self.collectionView = collectionView
        
        self.cellClass = cellClass
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let _object = (object as? ZSTabView) else { return }
        
        if _object == collectionView
        {
            let new = change?[.newKey] as? CGRect
            let old = change?[.oldKey] as? CGRect
            
            guard new != old else { return }
    
            zs_setSelectedIndex(selectIndex)
        }
    }
    
    deinit {
        collectionView?.removeObserver(self, forKeyPath: "frame")
    }
}



/**
 * 1. UICollectionView 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabViewServe {
    
    // TODO: UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tabCount
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.zs_identifier, for: indexPath) as! ZSTabCell
        
        dataSource?.zs_configTabCell(cell, forItemAt: indexPath.item)
        
        return cell
    }
    
    // TODO: UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return dataSource?.zs_configTabCellSize(forItemAt: indexPath.item) ?? .zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return tabViewInsert
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return 0 }
        
        return flowLayout.scrollDirection == .vertical ? minimumSpacing : 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return 0 }
        
        return flowLayout.scrollDirection == .horizontal ? minimumSpacing : 0
    }
    
    // TODO: UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        delegate?.zs_tabViewDidSelected(at: indexPath.item)
    }
}
