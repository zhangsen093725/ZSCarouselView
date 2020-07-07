//
//  ZSLoopScrollView.swift
//  Pods-ZSBaseUtil_Example
//
//  Created by 张森 on 2019/11/30.
//

import UIKit

@objc public protocol ZSLoopScrollViewDataSource {
    
    /// 滚动视图的总数
    /// - Parameter loopScrollView: loopScrollView
    func zs_numberOfItemLoopScrollView(_ loopScrollView: ZSLoopScrollView) -> Int
    
    /// 滚动到的视图
    /// - Parameters:
    ///   - loopScrollView: loopScrollView
    ///   - index: 当前的index
    func zs_loopScrollView(_ loopScrollView: ZSLoopScrollView, itemAt index: Int) -> UIView
    
    /// 滚动到的视图的Size
    /// - Parameters:
    ///   - loopScrollView: loopScrollView
    ///   - index: 当前的index
    func zs_loopScrollView(_ loopScrollView: ZSLoopScrollView, sizeAt index: Int) -> CGSize
}

@objc public protocol ZSLoopScrollViewDelegate {
    
    /// 滚动视图Item的点击
    /// - Parameters:
    ///   - loopScrollView: loopScrollView
    ///   - index: 当前的index
    func zs_loopScrollView(_ loopScrollView: ZSLoopScrollView, didSelectedItemFor index: Int)
    
    /// 滚动视图的回调
    /// - Parameters:
    ///   - loopScrollView: loopScrollView
    ///   - index: 当前的index
    func zs_loopScrollViewDidScroll(_ loopScrollView: ZSLoopScrollView, index: Int)
}

@objcMembers open class ZSLoopScrollView: UIView, UIScrollViewDelegate {
    
    /// scrollView
    public var scrollView: UIScrollView {
        
        return _scrollView_
    }
    
    /// 标记 page 的Control
    public var pageControl: UIPageControl {
        
        return _pageControl_
    }
    
    lazy var _scrollView_: UIScrollView = {
        
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        insertSubview(scrollView, at: 0)
        return scrollView
    }()
    
    lazy var _pageControl_: UIPageControl = {
        
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .white
        addSubview(pageControl)
        return pageControl
    }()
    
    var timer: Timer?
    var _pageCount_: Int = 0
    var _loopPageCount_: Int = 0
    
    /// 滚动视图的数据配置
    public weak var dataSource: ZSLoopScrollViewDataSource?
    
    /// 滚动视图的交互
    public weak var delegate: ZSLoopScrollViewDelegate?
    
    /// 是否开启自动滚动，默认为 true
    public var isAutoScroll: Bool = true
    
    /// 自动滚动的间隔时长，默认是 3 秒
    public var interval: TimeInterval = 3
    
    /// 是否开启循环滚动，默认是true
    public var isLoopScroll: Bool = true
    
    /// 是否隐藏PageControl，默认是false
    public var isHiddenPageControl: Bool = false
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        
        _pageCount_ = dataSource?.zs_numberOfItemLoopScrollView(self) ?? 0
        
        isLoopScroll = isLoopScroll ? _pageCount_ > 1 : isLoopScroll
        
        isAutoScroll = isAutoScroll ? _pageCount_ > 1 : isAutoScroll
        
        _loopPageCount_ = (isLoopScroll ? _pageCount_ + 2 : _pageCount_)
        
        scrollView.contentSize = CGSize(width: CGFloat(_loopPageCount_) * frame.width, height: 0)
        scrollView.contentOffset = CGPoint(x: isLoopScroll ? frame.width : 0, y: 0)
        pageControl.frame = CGRect(x: 0, y: frame.height - 20, width: frame.width, height: 20)
        
        refreshItemUI(_loopPageCount_)
    }
    
    /// 获取复用的同一视图的方法
    /// - Parameter index: 当前的index
    public func viewWithIndex<ResultValue: UIView>(_ index: Int) -> ResultValue? {
        
        return view(with: index) as? ResultValue
    }
    
    public func view(with index: Int) -> UIView? {
        
        let tag = index + 101
        
        return scrollView.viewWithTag(tag)
    }
    
    /// 刷新数据源
    public func reloadDataSource() {
        
        layoutSubviews()
    }
    
    func getContentView(for index: Int) -> UIButton {
        
        var contentView: UIButton? = scrollView.viewWithTag(1001 + index) as? UIButton
        
        if contentView == nil {
            
            contentView = UIButton(type: .custom)
            contentView?.removeTarget(self, action: #selector(didSelected(_:)), for: .touchUpInside)
            contentView?.addTarget(self, action: #selector(didSelected(_:)), for: .touchUpInside)
        }
        scrollView.addSubview(contentView!)
        
        return contentView!
    }
    
    
    func refreshItemUI(_ pageCount: Int) {
        
        guard pageCount > 0 else { return }
        
        pageControl.numberOfPages = _pageCount_
        pageControl.isHidden = isHiddenPageControl ? isHiddenPageControl : pageCount == 1
        
        for page in 0..<pageCount {
            
            var index = page + 1
            
            if isLoopScroll {
                
                index = page == pageCount - 1 ? 1 : page
                index = page == 0 ? _pageCount_ : index
            }
            
            let size = dataSource?.zs_loopScrollView(self, sizeAt: index - 1) ?? .zero
            
            guard size.width > 0 && size.height > 0 else { continue }
            
            guard let view = dataSource?.zs_loopScrollView(self, itemAt: index - 1) else { continue }
            view.tag = 101 + page
            view.isUserInteractionEnabled = false
            
            let contentView = getContentView(for: page)
            
            let subFrame: CGRect = CGRect(x: (scrollView.frame.width - size.width) * 0.5 + scrollView.frame.width * CGFloat(page), y: (scrollView.frame.height - size.height) * 0.5, width: size.width, height: size.height)
            
            contentView.frame = subFrame
            view.frame = contentView.bounds
            
            if contentView.tag == 0 {
                contentView.addSubview(view)
            }
            
            contentView.tag = 1001 + page
        }
        
        beginAutoLoopScroll()
    }
    
    func beginAutoLoopScroll() {
        
        guard isAutoScroll else { return }
        
        guard timer == nil else { return }
        
        timer = Timer.loopScroll_supportiOS_10EarlierTimer(interval, repeats: true, block: { [weak self] (timer) in
            
            self?.autoLoopScroll()
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func endAutoLoopScroll() {
        
        timer?.invalidate()
        timer = nil
    }
    
    func autoLoopScroll() {
        
        let offsetX = scrollView.contentOffset.x + scrollView.frame.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    deinit {
        endAutoLoopScroll()
    }
    
    // TODO: Action
    @objc func didSelected(_ sender: UIButton) {
        
        let page = sender.tag - 1001
        var index = page + 1
        
        if isLoopScroll {
            
            index = page == _loopPageCount_ - 1 ? 1 : page
            index = page == 0 ? _pageCount_ : index
        }

        delegate?.zs_loopScrollView(self, didSelectedItemFor: index - 1)
    }
    
    
    // TODO: UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if isLoopScroll {
            
            if scrollView.contentOffset.x <= 0 {
                
                scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(_pageCount_), y: 0), animated: false)
                
            } else if Int(scrollView.contentOffset.x) >= Int(scrollView.frame.width) * (_loopPageCount_ - 1) {

                scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
            }
        }
        
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
        let prePage = pageControl.currentPage + (isLoopScroll ? 1 : 0)
        
        guard currentPage != prePage else { return }
        
        pageControl.currentPage = isLoopScroll ? currentPage - 1 : currentPage
        
        delegate?.zs_loopScrollViewDidScroll(self, index: pageControl.currentPage)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endAutoLoopScroll()
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        beginAutoLoopScroll()
    }
}



extension Timer {
    
    class func loopScroll_supportiOS_10EarlierTimer(_ interval: TimeInterval, repeats: Bool, block: @escaping (_ timer: Timer) -> Void) -> Timer {
        
        if #available(iOS 10.0, *) {
            return Timer.init(timeInterval: interval, repeats: repeats, block: block)
        } else {
            return Timer.init(timeInterval: interval, target: self, selector: #selector(loopScrollRunTimer(_:)), userInfo: block, repeats: repeats)
        }
    }
    
    @objc private class func loopScrollRunTimer(_ timer: Timer) -> Void {
        
        guard let block: ((Timer) -> Void) = timer.userInfo as? ((Timer) -> Void) else { return }
        
        block(timer)
    }
}
