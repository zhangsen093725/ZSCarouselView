//
//  ZSLoadView+DisplayLink.swift
//  ZSViewUtil
//
//  Created by 张森 on 2020/4/15.
//

import UIKit

class ZSLoadViewDisplayLink: NSObject {
    
    private var userInfo: ((_ displayLink: CADisplayLink) -> Void)?
    private var displayLink: CADisplayLink?
    
    /// 初始化CADisplayLink
    /// - Parameters:
    ///   - fps: 刷新频率，表示一秒钟刷新多少次，默认是60次
    ///   - block: 回调
    public class func zs_displayLink(_ fps: Int = 60,
                                     block: @escaping (_ displayLink: CADisplayLink) -> Void) -> ZSLoadViewDisplayLink {
        
        let weak_displayLink = ZSLoadViewDisplayLink()
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
