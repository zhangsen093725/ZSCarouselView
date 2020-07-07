//
//  ZSLoadView.swift
//  ZSToastView
//
//  Created by 张森 on 2019/8/14.
//  Copyright © 2019 张森. All rights reserved.
//

import UIKit

// MARK: - ZSLoadingView
@objcMembers public class ZSLoadingView: UIView {
    
    private var startRatio: Double = 0.1 {
        willSet {
            setNeedsDisplay()
        }
    }
    
    private var endRatio: Double = 1.9 {
        willSet {
            setNeedsDisplay()
        }
    }
    
    private var inertiaDisplayLink: ZSLoadViewDisplayLink?
    
    override public func draw(_ rect: CGRect) {
        
        let lineWidth: CGFloat = 2
        
        let bezierWidth: CGFloat = rect.width - 20
        let bezierHeight: CGFloat = rect.height - 20
        
        let radius = (min(bezierWidth, bezierHeight) - lineWidth) * 0.5
        
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = lineWidth
        UIColor.white.set()
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round
        
        bezierPath.addArc(withCenter: CGPoint(x: rect.width * 0.5, y: rect.height * 0.5), radius: radius, startAngle: CGFloat(Double.pi * (1.5 + startRatio)), endAngle: CGFloat(Double.pi * (1.5 + endRatio)), clockwise: true)
        
        bezierPath.stroke()
    }
    
    
      open func startAnimation() {
            
            guard inertiaDisplayLink == nil else { return }
            
            inertiaDisplayLink = ZSLoadViewDisplayLink.zs_displayLink(60, block: { [weak self] (displayLink) in
                self?.runDisplayLink()
            })
        }
        
        open func stopAnimation() {
            
            inertiaDisplayLink?.invalidate()
            inertiaDisplayLink = nil
        }
        
        func runDisplayLink() {
            
            if startRatio >= 2.1 {
                startRatio = 0.1
                endRatio = 1.9
            }
            
            endRatio += 0.05
            startRatio += 0.05
        }
    
    
    open func configLoadView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 8
        clipsToBounds = true
        setNeedsDisplay()
    }
}
