//
//  ZSMediaPreview.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/4/8.
//

import UIKit

@objcMembers open class ZSMediaPreview: UIView {
    
    /// 是否允许拖动
    public var shouldPanGesture: Bool = true
    
    /// 缩放倍数
    fileprivate var panScale: CGFloat = 1
    
    /// 背景透明度
    fileprivate var panColorAlpha: CGFloat = 1
    
    /// 是否开始拖动
    fileprivate var isPanGestureEnalbe: Bool = false
    
    /// 是否关闭预览
    fileprivate var isEndPreview: Bool = false
    
    /// 屏幕截图视图
    fileprivate var mediaPreviewSnapshotView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    var previewLineSpacing: CGFloat = 0 {
        didSet {
            collectionView.frame.size.width = contentView.bounds.width + previewLineSpacing
        }
    }
    
    /// 动画最后需要返回到的View
    weak var lastView: UIView?
    
    /// 动画最后需要返回到的frame
    fileprivate var lastFrame: CGRect = .zero
    
    public lazy var contentView: UIView = {
        
        let contentView = UIView()
        contentView.backgroundColor = .clear
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(_:)))
        contentView.addGestureRecognizer(pan)
        insertSubview(contentView, at: 0)
        return contentView
    }()
    
    public lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        contentView.insertSubview(collectionView, at: 0)
        return collectionView
    }()
        
    public var zs_didEndPreview: (() -> Void)?
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        collectionView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width + previewLineSpacing, height: contentView.bounds.height)
    }
    
    open func reset() {
        panScale = 1
        panColorAlpha = 1
        isPanGestureEnalbe = false
        shouldPanGesture = true
    }
    
    func updateFrame(from view: UIView?) {
        lastView?.isHidden = false
        lastView = view
        lastFrame = (view == nil ? .zero : convert(view!.frame, to: self))
    }
}



/**
 * ZSMediaPreview 动画
 */
@objc extension ZSMediaPreview {
    
    open func beginPreview(from view: UIView? = nil, to index: Int = 0) {
        
        view?.isHidden = true
        
        frame = UIScreen.main.bounds
        
        var rootVC = UIApplication.shared.keyWindow?.rootViewController
        
        while ((rootVC?.presentedViewController) != nil && !(rootVC?.presentedViewController is UIAlertController)) {
            rootVC = rootVC?.presentedViewController
        }
        
        rootVC?.view.addSubview(self)
        
        layoutSubviews()
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)

        let fromViewSnapshotView = view?.snapshotView(afterScreenUpdates: false)
        
        if fromViewSnapshotView == nil {
            
            backgroundColor = UIColor.black.withAlphaComponent(0)
            contentView.alpha = 0

            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.backgroundColor = UIColor.black.withAlphaComponent(1)
                self?.contentView.alpha = 1
            }
            return
        }
        
        backgroundColor = UIColor.black.withAlphaComponent(0)
        contentView.isHidden = true

        updateFrame(from: view)
        fromViewSnapshotView?.frame = lastFrame
        insertSubview(fromViewSnapshotView!, at: 0)
        layoutIfNeeded()
        
        var _imageFrame_ = lastFrame
        _imageFrame_.size.width = frame.width
        _imageFrame_.size.height = frame.width * (lastFrame.height / lastFrame.width)
        _imageFrame_.origin.x = 0
        _imageFrame_.origin.y = (frame.height - _imageFrame_.height) * 0.5
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            
            self?.backgroundColor = UIColor.black.withAlphaComponent(1)
            fromViewSnapshotView?.frame = _imageFrame_
            
        }) { [weak self] (finished) in
            
            self?.contentView.isHidden = false
            fromViewSnapshotView?.isHidden = true
            fromViewSnapshotView?.removeFromSuperview()
        }
    }
    
    open func endPreview() {
        
        if lastView == nil {
            
            backgroundColor = .clear
            
            let keyAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            keyAnimation.duration = 0.3
            keyAnimation.values = [0.56, 0.4, 0.2, 0.1, 0]
            keyAnimation.isCumulative = false
            keyAnimation.isRemovedOnCompletion = false
            layer.add(keyAnimation, forKey: "Scale")
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.alpha = 0
            }) { [weak self] (finished) in
                self?.mediaPreviewSnapshotView?.removeFromSuperview()
                self?.removeFromSuperview()
                self?.layer.removeAllAnimations()
                self?.lastView?.isHidden = false
                self?.zs_didEndPreview?()
            }
            return
        }
        
        contentView.isHidden = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            
            self?.backgroundColor = UIColor.black.withAlphaComponent(0)
            self?.getMediaPreviewSnapshotView().frame = self?.lastFrame ?? .zero
            
        }) { [weak self] (finished) in
            
            self?.mediaPreviewSnapshotView?.removeFromSuperview()
            self?.lastView?.isHidden = false
            self?.removeFromSuperview()
            self?.zs_didEndPreview?()
        }
    }
    
    open func getMediaPreviewSnapshotView() -> UIView {
        
        guard mediaPreviewSnapshotView == nil else { return mediaPreviewSnapshotView! }
        
        mediaPreviewSnapshotView = contentView.snapshotView(afterScreenUpdates: false)
        mediaPreviewSnapshotView?.frame = bounds
        addSubview(mediaPreviewSnapshotView!)
        contentView.isHidden = true
        
        return mediaPreviewSnapshotView!
    }
}


/**
 * 手势
 */
@objc extension ZSMediaPreview {
    
    open func endPanGestureRecognizer(_ complete: (()->Void)? = nil) {
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.contentView.transform = CGAffineTransform.identity
            self?.mediaPreviewSnapshotView?.transform = CGAffineTransform.identity
            self?.backgroundColor = self?.backgroundColor?.withAlphaComponent(1)
        }) { [weak self] (finished) in
            self?.reset()
            self?.contentView.isHidden = false
            self?.mediaPreviewSnapshotView = nil
            guard complete != nil else { return }
            complete!()
        }
    }
    
    @objc open func panGestureRecognizer(_ panGestureRecognizer : UIPanGestureRecognizer) {
        
        guard shouldPanGesture else {
            panGestureRecognizer.setTranslation(.zero, in: panGestureRecognizer.view)
            return
        }
        
        let currentPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        
        let _mediaPreviewSnaphotView_ = getMediaPreviewSnapshotView()
        
        if abs(currentPoint.y) > abs(currentPoint.x) {
            
            let offset: CGFloat = sqrt(pow(currentPoint.x, 2) + pow(currentPoint.y, 2)) / sqrt(pow(frame.width, 2) + pow(frame.height, 2))
            panColorAlpha = (currentPoint.y < 0 ? (1 + offset) : (1 - offset)) * panColorAlpha
            panColorAlpha = panColorAlpha > 1 ? 1 : panColorAlpha
            panScale = currentPoint.y < 0 ? (1 + offset) : (1 - offset)
            
            isEndPreview = currentPoint.y > 0
            
            let isShouldScale = currentPoint.y >= 0 || (currentPoint.y < 0 && (_mediaPreviewSnaphotView_.transform.d < 1 || _mediaPreviewSnaphotView_.transform.a < 1))
            
            if isShouldScale {
                _mediaPreviewSnaphotView_.transform = _mediaPreviewSnaphotView_.transform.scaledBy(x: panScale, y: panScale)
            }
            
            if currentPoint.y >= 0 {
                isPanGestureEnalbe = true
            }
            
            backgroundColor = backgroundColor?.withAlphaComponent(panColorAlpha)
        }
        
        if isPanGestureEnalbe {
            _mediaPreviewSnaphotView_.transform = _mediaPreviewSnaphotView_.transform.translatedBy(x: currentPoint.x, y: currentPoint.y)
        }
        
        if panGestureRecognizer.state == .ended {
            
            isEndPreview ? endPreview() : endPanGestureRecognizer()
        }
        
        panGestureRecognizer.setTranslation(.zero, in: panGestureRecognizer.view)
    }
}
