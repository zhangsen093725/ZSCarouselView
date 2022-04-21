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
            reloadData()
        }
    }
    
    /// collectionView flowLayout
    var _collectionViewLayout: UICollectionViewFlowLayout!
    public var collectionViewLayout: UICollectionViewFlowLayout { return _collectionViewLayout }
    
    /// cellClass
    var _cellClass: ZSScrollCarouselCell.Type!
    public var cellClass: ZSScrollCarouselCell.Type { return _cellClass }
    
    var _isLoopScrollFirstScroll: Bool = true
    var _itemCount: Int = 0
    var _loopScrollItemCount: Int = 0
    var _cachePage: Int = 1
    var _timer: Timer?
    
    
    public var collectionView: UICollectionView { return _collectionView }
    lazy var _collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false

        configCollectionView(collectionView)
        
        addSubview(collectionView)
        return collectionView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        _cellClass = ZSScrollCarouselCell.self
        _collectionViewLayout = UICollectionViewFlowLayout()
//        beginAutoScroll()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        _collectionView.frame = bounds
        
        if isLoopScroll
        {
            guard _collectionView.frame != .zero else { return }
            
            reloadData()
            _collectionView.layoutIfNeeded()
            
            let isHorizontal = collectionViewLayout.scrollDirection == .horizontal
            DispatchQueue.main.async {
                
                self.collectionView.scrollToItem(at: IndexPath(item: self._cachePage, section: 0), at: isHorizontal ? .centeredHorizontally : .centeredVertically, animated: false)
            }
        }
    }
    
    open func configCollectionView(_ collectionView: UICollectionView) {
        collectionView.isPagingEnabled = true
        collectionView.register(cellClass, forCellWithReuseIdentifier: cellClass.zs_identifier)
    }
    
    open func reloadData() {
        _collectionView.reloadData()
    }
    
    open func scrollToPage(_ page: Int, animated: Bool) {
        
        var index = page
        
        if isLoopScroll
        {
            guard page < _loopScrollItemCount else { return }

            index = page + 1
            index = page == _loopScrollItemCount - 1 ? _itemCount : index
            index = page == 0 ? 1 : index
        }
        else
        {
            guard page < _itemCount else { return }
        }
        
        let isHorizontal = collectionViewLayout.scrollDirection == .horizontal
        _collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: isHorizontal ? .centeredHorizontally : .centeredVertically, animated: animated)
    }
    
    func beginAutoScroll() {
        
        guard isAutoScroll else { return }
        
        guard _timer == nil else { return }
        
        _timer = Timer.scrollCarouse_supportiOS_10EarlierTimer(interval, repeats: true, block: { [weak self] (timer) in
            
            self?.autoScroll()
        })
        RunLoop.current.add(_timer!, forMode: .common)
    }
    
    func endAutoScroll() {
        
        _timer?.invalidate()
        _timer = nil
    }
    
    func autoScroll() {
        
        let page = _cachePage + 1
     
        if isLoopScroll
        {
            guard page < _loopScrollItemCount else { return }
        }
        else
        {
            guard page < _itemCount else {
                
                endAutoScroll()
                return
            }
        }
        
        let isHorizontal = collectionViewLayout.scrollDirection == .horizontal
        self.collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: isHorizontal ? .centeredHorizontally : .centeredVertically, animated: true)
    }
    
    deinit {
        endAutoScroll()
    }
}



// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ZSScrollCarouselView {
    
    func scrollCarouseIndex(from page: Int) -> Int {
        
        var index = page + 1
        
        if isLoopScroll && _loopScrollItemCount > 0
        {
            index = page == _loopScrollItemCount - 1 ? 1 : page
            index = page == 0 ? _itemCount : index
        }
        return index - 1
    }
    
    // TODO: UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        _itemCount = dataSource?.zs_numberOfItemcarouseView(self) ?? 0
        _loopScrollItemCount = _itemCount + 2
        
        return isLoopScroll ? _loopScrollItemCount : _itemCount
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
        endAutoScroll()
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        beginAutoScroll()
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
