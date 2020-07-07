//
//  ZSTabContentViewServe.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/14.
//

import UIKit

@objcMembers open class ZSTabPageTablePlainViewServe: NSObject, UITableViewDelegate, UITableViewDataSource, ZSTabViewServeDelegate, ZSPageViewScrollDelegate {
    
    public weak var tableView: UITableView?
    
    public var tabViewServe: ZSTabViewServe!
    
    public var pageViewServe: ZSPageViewServe!
    
    /// 是否开始拖拽
    private var isBeginDecelerating: Bool = false
    
    /// base view 是否可以滚动
    private var isShouldBaseScroll: Bool = true
    
    /// tab page 是否可以滚动
    private var isShouldPageScroll: Bool = false
    
    public var tabCount: Int = 0 {
        didSet {
            tabViewServe.tabCount = tabCount
            pageViewServe.tabCount = tabCount
            tableView?.reloadData()
        }
    }
    
    var _selectIndex_: Int = 0
    
    public var selectIndex: Int { return _selectIndex_ }
    
    private override init() {
        super.init()
    }
    
    public convenience init(selectIndex: Int) {
        self.init()
        _selectIndex_ = selectIndex
        tabViewServe = ZSTabViewServe(selectIndex: selectIndex)
        pageViewServe = ZSPageViewServe(selectIndex: selectIndex)
    }
    
    open func zs_setSelectedIndex(_ index: Int) {
        _selectIndex_ = index
        tabViewServe.zs_setSelectedIndex(selectIndex)
        pageViewServe.zs_setSelectedIndex(selectIndex)
    }
}



/**
 * 1. ZSTabSectionViewServe 提供外部重写的方法
 * 2. 需要自定义TabContentView的样式，可重新以下的方法达到目的
 */
@objc extension ZSTabPageTablePlainViewServe {
    
    open func zs_bindTableView(_ tableView: UITableView,
                               tabView: ZSTabView,
                               pageView: ZSPageView) {
        
        zs_configTableView(tableView)
        zs_configTabViewServe(tabView)
        zs_configPageServe(pageView)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
    }
    
    open func zs_configTableView(_ tableView: UITableView) {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
    }
    
    open func zs_configTabViewServe(_ tabView: ZSTabView) {
        
        tabViewServe.zs_bind(collectionView: tabView, register: ZSTabTextCell.self)
        tabViewServe.delegate = self
    }
    
    open func zs_configPageServe(_ pageView: ZSPageView) {
        
        pageViewServe.zs_bindView(pageView)
        pageViewServe.scrollDelegate = self
    }
    
    open func zs_tabPageTablePlainViewContentViewDidScroll() -> (_ scrollView: UIScrollView, _ currentOffset: CGPoint) -> CGPoint {
        
        return { [weak self] (scrollView, currentOffset) in
            
            if self?.isShouldPageScroll == false
            {
                scrollView.contentOffset = currentOffset
                return currentOffset
            }
            
            if scrollView.contentOffset.y <= 0
            {
                self?.isShouldBaseScroll = true
                self?.isShouldPageScroll = false
                scrollView.contentOffset = .zero
                return .zero
            }
            
            return scrollView.contentOffset
        }
    }
}



/**
 * 1. ZSPageViewScrollDelegate 和 ZSTabViewServeDelegate
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabPageTablePlainViewServe {
    
    // TODO: ZSPageViewScrollDelegate
    open func zs_pageViewDidScroll(_ scrollView: UIScrollView, page: Int) {
        
        if selectIndex != page && page < tabCount
        {
            zs_setSelectedIndex(page)
        }
        
        guard scrollView.contentSize != .zero else { return }
        
        if scrollView.contentOffset.x >= 0 && isBeginDecelerating
        {
            isShouldPageScroll = !isShouldBaseScroll
            tableView?.isScrollEnabled = false
            return
        }
    }
    
    open func zs_pageViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isBeginDecelerating = true
    }
    
    open func zs_pageViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isBeginDecelerating = false
        tableView?.isScrollEnabled = true
    }
    
    // TODO: ZSTabViewServeDelegate
    open func zs_tabViewDidSelected(at index: Int) {
        zs_setSelectedIndex(index)
    }
}



/**
 * 1. UITableView 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabPageTablePlainViewServe {
    
    // UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.contentSize != .zero else { return }
        
        let bottomOffset = scrollView.contentSize.height - scrollView.bounds.height
        
        if scrollView.contentOffset.y >= bottomOffset
        {
            scrollView.contentOffset = CGPoint(x: 0, y: bottomOffset)
            if isShouldBaseScroll
            {
                isShouldBaseScroll = false
                isShouldPageScroll = true
            }
            return
        }
        
        if isShouldBaseScroll == false
        {
            scrollView.contentOffset = CGPoint(x: 0, y: bottomOffset)
            return
        }
    }
    
    // TODO: UITableViewDataSource
    open func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        
        cell.isExclusiveTouch = true
        
        for subView in cell.contentView.subviews
        {
            subView.removeFromSuperview()
        }
        
        guard let view = pageViewServe.collectionView else
        {
            return cell
        }
        
        cell.contentView.addSubview(view)
        view.frame = cell.contentView.bounds
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableView.frame.size.height - 44
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let view = tabViewServe.collectionView else { return nil }
        return view
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
}

