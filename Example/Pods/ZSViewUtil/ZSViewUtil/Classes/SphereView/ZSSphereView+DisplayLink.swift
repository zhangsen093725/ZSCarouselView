//
//  ZSSphereView+DisplayLink.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/3/13.
//

import Foundation

extension ZSSphereView {
    
    // TODO: 自动滚动
    func startDisplay() {
        
        guard isAutoRotate else { return }
        
        guard property.displayLink == nil else { return }
        
        property.displayLink = ZSSphereDisplayLink.zs_displayLink(Int(property.fps), block: { [weak self] (displayLink) in
            self?.runDisplayLink()
        })
    }
    
    func stopDisplay() {
        
        guard property.displayLink != nil else { return }
        
        property.displayLink?.invalidate()
        property.displayLink = nil
    }
    
    func runDisplayLink() {
        
        let origin = frame.origin
        let movePoint = CGPoint(x: origin.x + autoRotateSpeed * property.intervalRotatePoint.x, y: origin.y + autoRotateSpeed * property.intervalRotatePoint.y)
        
        rotateSphere(by: autoRotateSpeed / property.fps, fromPoint: origin, toPoint: movePoint)
    }
    
    // TODO: 惯性滚动
    func startInertiaDisplay() {
        
        guard isInertiaRotate else { return }
        
        guard property.inertiaDisplayLink == nil else { return }
        
        property.inertiaDisplayLink = ZSSphereDisplayLink.zs_displayLink(Int(property.fps), block: { [weak self] (displayLink) in
            self?.runInertiaDisplayLink()
        })
    }
    
    func stopInertiaDisplay() {
        
        guard property.inertiaDisplayLink != nil else { return }
        
        property.inertiaDisplayLink?.invalidate()
        property.inertiaDisplayLink = nil
    }
    
    func runInertiaDisplayLink() {

        guard property.inertiaRotatePower >= 1.2 else {
            stopInertiaDisplay()
            startDisplay()
            return
        }
        
        property.inertiaRotatePower -= property.inertiaRotatePower / property.fps
        
        let origin = frame.origin
        let movePoint = CGPoint(x: origin.x + autoRotateSpeed * property.intervalRotatePoint.x, y: origin.y + autoRotateSpeed * property.intervalRotatePoint.y)
        
        rotateSphere(by: autoRotateSpeed * property.inertiaRotatePower / property.fps, fromPoint: origin, toPoint: movePoint)
    }
}





class ZSSphereDisplayLink: NSObject {
    
    private var userInfo: ((_ displayLink: CADisplayLink) -> Void)?
    private var displayLink: CADisplayLink?
    
    /// 初始化CADisplayLink
    /// - Parameters:
    ///   - fps: 刷新频率，表示一秒钟刷新多少次，默认是60次
    ///   - block: 回调
    public class func zs_displayLink(_ fps: Int = 60,
                                     block: @escaping (_ displayLink: CADisplayLink) -> Void) -> ZSSphereDisplayLink {
        
        let weak_displayLink = ZSSphereDisplayLink()
        weak_displayLink.userInfo = block
        
        weak_displayLink.displayLink = CADisplayLink(target: weak_displayLink, selector: #selector(runDisplayLink(_:)))
        
        guard fps > 0 else { return weak_displayLink }
        
        if #available(iOS 10.0, *) {
            weak_displayLink.displayLink?.preferredFramesPerSecond = fps
        } else {
            weak_displayLink.displayLink?.frameInterval = fps
        }
        weak_displayLink.displayLink?.add(to: RunLoop.current, forMode: .default)
        
        return weak_displayLink
    }
    
    @objc private func runDisplayLink(_ displayLink: CADisplayLink) -> Void {
        
        guard userInfo != nil else { return }
        userInfo!(displayLink)
    }
    
    public func invalidate() {
        displayLink?.remove(from: RunLoop.current, forMode: .default)
        displayLink?.invalidate()
        displayLink = nil
        userInfo = nil
    }
}
