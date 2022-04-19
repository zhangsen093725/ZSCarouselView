//
//  ZSScrollCarouselView.swift
//  Pods-ZSCarouselView_Example
//
//  Created by Josh on 2020/7/6.
//

import UIKit

@objc public protocol ZSScrollCarouselViewDataSource {
    
    /// 滚动视图的总数
    /// - Parameter carouseView: carouseView
    func zs_numberOfItemcarouseView(_ carouseView: ZSScrollCarouselView) -> Int
    
    /// 滚动到的视图
    /// - Parameters:
    ///   - cell: 当前的carouseCell
    ///   - index: 当前的index
    func zs_configCarouseCell(_ cell: ZSScrollCarouselCell, itemAt index: Int)
}

@objc public protocol ZSScrollCarouselViewDelegate {
    
    /// 滚动视图Item的点击
    /// - Parameters:
    ///   - carouseView: carouseView
    ///   - index: 当前的index
    func zs_carouseView(_ carouseView: ZSScrollCarouselView, didSelectedItemFor index: Int)
    
    /// 滚动视图的回调
    /// - Parameters:
    ///   - carouseView: carouseView
    ///   - index: 当前的index
    func zs_carouseViewDidScroll(_ carouseView: ZSScrollCarouselView, index: Int)
}

@objcMembers open class ZSScrollCarouselView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// 滚动视图的数据配置
    public weak var dataSource: ZSScrollCarouselViewDataSource?
    
    /// 滚动视图的交互
    public weak var delegate: ZSScrollCarouselViewDelegate?
    
    /// 是否开启自动滚动，默认为 true
    public var isAutoScroll: Bool = true
    
    /// 自动滚动的间隔时长，默认是 3 秒
    public var interval: TimeInterval = 3
    
    /// 是否开启循环滚动，默认是true
    public var isLoopScroll: Bool = true {
        didSet {
            _collectionView_.reloadData()
        }
    }
    
    /// collectionView flowLayout
    var _collectionViewLayout_: UICollectionViewFlowLayout!
    public var collectionViewLayout: UICollectionViewFlowLayout { return _collectionViewLayout_ }
    
    /// cellClass
    var _cellClass_: ZSScrollCarouselCell.Type!
    public var cellClass: ZSScrollCarouselCell.Type { return _cellClass_ }
    
    var _itemCount_: Int = 0
    var _loopScrollItemCount_: Int = 0
    var _cachePage_: Int = 1
    var _timer_: Timer?
    
    public var collectionView: UICollectionView { return _collectionView_ }
    
    lazy var _collectionView_: UICollectionView = {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        
        configCollectionView(collectionView)
        
        addSubview(collectionView)
        return collectionView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        _cellClass_ = ZSScrollCarouselCell.self
        _collectionViewLayout_ = UICollectionViewFlowLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        _collectionView_.frame = bounds
    }
    
    open func configCollectionView(_ collectionView: UICollectionView) {
        collectionView.isPagingEnabled = true
        collectionView.register(cellClass, forCellWithReuseIdentifier: cellClass.zs_identifier)
    }
    
    open func reloadData() {
        _collectionView_.reloadData()
    }
    
    open func scrollToItem(at page: Int, animated: Bool) {
        
        var index = page
        
        if isLoopScroll
        {
            guard page < _loopScrollItemCount_ else { return }

            index = page + 1
            index = page == _loopScrollItemCount_ - 1 ? _itemCount_ : index
            index = page == 0 ? 1 : index
        }
        else
        {
            guard page < _itemCount_ else { return }
        }
        
        let isHorizontal = collectionViewLayout.scrollDirection == .horizontal
        _collectionView_.scrollToItem(at: IndexPath(item: index, section: 0), at: isHorizontal ? .centeredHorizontally : .centeredVertically, animated: animated)
    }
    
    func beginAutoLoopScroll() {
        
        guard isAutoScroll else { return }
        
        guard _timer_ == nil else { return }
        
        _timer_ = Timer.scrollCarouse_supportiOS_10EarlierTimer(interval, repeats: true, block: { [weak self] (timer) in
            
            self?.autoLoopScroll()
        })
        RunLoop.current.add(_timer_!, forMode: .common)
    }
    
    func endAutoLoopScroll() {
        
        _timer_?.invalidate()
        _timer_ = nil
    }
    
    func autoLoopScroll() {
        
        let isHorizontal = collectionViewLayout.scrollDirection == .horizontal
        
        if isLoopScroll == false && _cachePage_ + 1 == _itemCount_
        {
            endAutoLoopScroll()
            return
        }
        
        _collectionView_.scrollToItem(at: IndexPath(item: _cachePage_ + 1, section: 0), at: isHorizontal ? .centeredHorizontally : .centeredVertically, animated: true)
    }
    
    deinit {
        _collectionView_.removeObserver(self, forKeyPath: "frame")
        endAutoLoopScroll()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (object as? UICollectionView) == _collectionView_
        {
            guard isLoopScroll else { return }
            
            let old = change?[.oldKey] as? CGRect
            let new = change?[.newKey] as? CGRect
            
            guard old != new else { return }
            
            _collectionView_.reloadData()
            _collectionView_.layoutIfNeeded()
            
            let isHorizontal = collectionViewLayout.scrollDirection == .horizontal
            
            _collectionView_.scrollToItem(at: IndexPath(item: _cachePage_, section: 0), at: isHorizontal ? .centeredHorizontally : .centeredVertically, animated: false)
            
            beginAutoLoopScroll()
        }
    }
}



// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ZSScrollCarouselView {
    
    func scrollCarouseIndex(from page: Int) -> Int {
        
        var index = page + 1
        
        if isLoopScroll && _loopScrollItemCount_ > 0
        {
            index = page == _loopScrollItemCount_ - 1 ? 1 : page
            index = page == 0 ? _itemCount_ : index
        }
        return index - 1
    }
    
    // TODO: UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        _itemCount_ = dataSource?.zs_numberOfItemcarouseView(self) ?? 0
        _loopScrollItemCount_ = _itemCount_ + 2
        
        return isLoopScroll ? _loopScrollItemCount_ : _itemCount_
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.zs_identifier, for: indexPath) as! ZSScrollCarouselCell
        
        dataSource?.zs_configCarouseCell(cell, itemAt: scrollCarouseIndex(from: indexPath.item))
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return self.collectionViewLayout.itemSize
    }
    
    // TODO: UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.zs_carouseView(self, didSelectedItemFor: scrollCarouseIndex(from: indexPath.item))
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return self.collectionViewLayout.minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return self.collectionViewLayout.minimumInteritemSpacing
    }
}


// MARK: - UIScrollViewDelegate
extension ZSScrollCarouselView {
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endAutoLoopScroll()
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        beginAutoLoopScroll()
    }
}



fileprivate extension Timer {
    
    class func scrollCarouse_supportiOS_10EarlierTimer(_ interval: TimeInterval, repeats: Bool, block: @escaping (_ timer: Timer) -> Void) -> Timer {
        
        if #available(iOS 10.0, *) {
            return Timer.init(timeInterval: interval, repeats: repeats, block: block)
        } else {
            return Timer.init(timeInterval: interval, target: self, selector: #selector(scrollCarouseRunTimer(_:)), userInfo: block, repeats: repeats)
        }
    }
    
    @objc private class func scrollCarouseRunTimer(_ timer: Timer) -> Void {
        
        guard let block: ((Timer) -> Void) = timer.userInfo as? ((Timer) -> Void) else { return }
        
        block(timer)
    }
}
