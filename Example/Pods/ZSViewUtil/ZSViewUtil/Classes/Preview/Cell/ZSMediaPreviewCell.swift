//
//  ZSMediaPreviewCell.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/4/8.
//

import UIKit

@objc public protocol ZSMediaPreviewCellDelegate: class {
    
    func zs_mediaPreviewCellScrollViewDidSingleTap()
    func zs_mediaPreviewCellScrollViewDidLongPress(_ collectionCell: UICollectionViewCell)
    func zs_mediaPreviewCellScrollViewShouldPanGestureRecognizer(_ enable: Bool)
    
    func zs_mediaPreviewCellMediaLoadFail(_ error: Error)
    func zs_mediaPreviewCellMediaDidChangePlay(status: ZSPlayerStatus)
    func zs_mediaPreviewCellMediaDidiChangePlayTime(second: TimeInterval)
    func zs_mediaPreviewCellMediaLoadingView() -> UIView?
}

@objcMembers open class ZSMediaPreviewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var previewLineSpacing: CGFloat = 0 {
        didSet {
            zoomScrollView.frame.size.width = contentView.frame.width - previewLineSpacing
        }
    }
    
    var isBeginDecelerating: Bool = false
    
    var scrollLimit: CGFloat {
        return zoomScrollView.contentSize.height <= zoomScrollView.frame.height ?
            (zoomScrollView.contentSize.height - zoomScrollView.frame.height) :
            zoomScrollView.frame.height * 0.15
    }
    
    weak var delegate: ZSMediaPreviewCellDelegate? {
        didSet {
            getCustomLoadingView()
        }
    }
    
    public lazy var zoomScrollView: ZSMediaPreviewScrollView = {
        
        let scrollView = ZSMediaPreviewScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPress.minimumPressDuration = 0.5
        contentView.addGestureRecognizer(longPress)
        contentView.insertSubview(scrollView, at: 0)
        
        return scrollView
    }()
    
    var customLoadingView: UIView?
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        zoomScrollView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width - previewLineSpacing, height: contentView.frame.height)
        customLoadingView?.frame = CGRect(x: (contentView.frame.width - 75) * 0.5, y: (contentView.frame.height - 75) * 0.5, width: 75, height: 75)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }
    
    func getCustomLoadingView() {
        
        guard delegate != nil else { return }
        
        let customLoadingView = delegate?.zs_mediaPreviewCellMediaLoadingView()
                
        if customLoadingView != self.customLoadingView {
            self.customLoadingView?.removeFromSuperview()
        }
            
        if customLoadingView != nil {
            contentView.addSubview(customLoadingView!)
        }
        
        self.customLoadingView = customLoadingView
    }
}



@objc extension ZSMediaPreviewCell {
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        let touch = touches.first
        let touchPoint = touch?.location(in: self)
        
        if touch?.tapCount == 1 {
            perform(#selector(singleTap), with: touchPoint, afterDelay: 0.3)
        }
        
        if touch?.tapCount == 2 {
            enlargeImage(from: touchPoint ?? .zero)
        }
    }
    
    @objc open func singleTap() {
        delegate?.zs_mediaPreviewCellScrollViewDidSingleTap()
    }
    
    @objc open func longPress(_ longPressGesture: UILongPressGestureRecognizer) {
        delegate?.zs_mediaPreviewCellScrollViewDidLongPress(self)
    }
}




@objc extension ZSMediaPreviewCell {
    
    open func zoomToOrigin() {
        guard zoomScrollView.zoomScale != 1 else { return }
        zoomScrollView.setZoomScale(1, animated: true)
    }
    
    open func enlargeImage(from point: CGPoint) {
        
        guard viewForZooming(in: zoomScrollView)?.frame.contains(point) ?? false else { return }
        
        if zoomScrollView.zoomScale > zoomScrollView.minimumZoomScale {
            zoomScrollView.setZoomScale(zoomScrollView.minimumZoomScale, animated: true)
            return
        }
        
        let zoomScale = zoomScrollView.maximumZoomScale
        let x = self.frame.width / zoomScale
        let y = self.frame.height / zoomScale
        zoomScrollView.zoom(to: CGRect(x: point.x - x * 0.5, y: point.y - y * 0.5, width: x, height: y), animated: true)
    }
    
    open func refreshMediaViewCenter(from point: CGPoint) {
        viewForZooming(in: zoomScrollView)?.center = point
    }
}




@objc extension ZSMediaPreviewCell {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.contentSize != .zero else { return }
        
        guard scrollView.zoomScale == 1 else {
            delegate?.zs_mediaPreviewCellScrollViewShouldPanGestureRecognizer(false)
            return
        }
        
        if scrollView.contentOffset.y > 0 {
            delegate?.zs_mediaPreviewCellScrollViewShouldPanGestureRecognizer(false)
        }
        
        guard isBeginDecelerating == false else { return }
        
        let shouldPanGesture = scrollView.contentOffset.y < -scrollLimit
        
        guard shouldPanGesture else { return }
        
        delegate?.zs_mediaPreviewCellScrollViewShouldPanGestureRecognizer(shouldPanGesture)
        
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        return
    }
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        refreshMediaViewCenter(from: CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY))
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isBeginDecelerating = true
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isBeginDecelerating = false
    }
}




@objcMembers open class ZSMediaPreviewScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    // TODO: UIGestureRecognizerDelegate
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
                
        if otherGestureRecognizer.view is UICollectionView {
            return false
        }
        
        return zoomScale == 1
    }
}
