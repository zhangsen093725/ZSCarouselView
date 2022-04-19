//
//  ZSCAAnimationUtil.swift
//  Pods-ZSBaseUtil_Example
//
//  Created by 张森 on 2019/11/8.
//

import UIKit

@objc public extension CALayer {
    
    /// 缩放动画
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - values: 缩放值，数值表示放大或缩小多少倍
    @objc func zs_keyFrameScale(animation duration: TimeInterval,
                                scale values: [Float]) {
        
        let keyAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        keyAnimation.duration = duration
        keyAnimation.values = values
        keyAnimation.isCumulative = false
        keyAnimation.isRemovedOnCompletion = false
        add(keyAnimation, forKey: "Scale")
    }
    
    /// 抖动动画
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - startPoint: 动画起始位置
    ///   - offsetPoint: 动画偏移位置
    @objc func zs_keyFrameShake(animation duration: TimeInterval,
                                in startPoint: CGPoint,
                                offsetPoint: CGPoint) {
        
        let keyAnimation = CAKeyframeAnimation(keyPath: "position")
        
        let path = CGMutablePath()
        
        path.move(to: startPoint)
        
        for index in 3...0 {
            path.addLine(to: CGPoint(x: startPoint.x - (offsetPoint.x * CGFloat(index)), y: startPoint.y - (offsetPoint.y * CGFloat(index))))
            path.addLine(to: CGPoint(x: startPoint.x + (offsetPoint.x * CGFloat(index)), y: startPoint.y + (offsetPoint.y * CGFloat(index))))
        }
        
        path.closeSubpath()
        
        keyAnimation.path = path
        keyAnimation.duration = duration
        keyAnimation.isRemovedOnCompletion = true
        add(keyAnimation, forKey: nil)
    }
}


@objc public extension CALayer {
    
    /// 转圈动画
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - fromValue: 其实位置
    ///   - toValue: 结束位置
    ///   - repeatCount: 重复次数
    @objc func zs_basicRevole(animation duration: TimeInterval = 2,
                              fromValue: Double = 0,
                              toValue: Double = -.pi * 2.0,
                              repeatCount: Float = MAXFLOAT) {
        
        let basicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        basicAnimation.fromValue = fromValue
        basicAnimation.toValue = toValue
        basicAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        basicAnimation.duration = duration
        basicAnimation.repeatCount = repeatCount
        basicAnimation.isCumulative = false
        basicAnimation.isRemovedOnCompletion = false
        basicAnimation.fillMode = .forwards
        add(basicAnimation, forKey: "Rotation")
    }
    
    /// 移动动画
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - delay: 间隔时间
    ///   - endPoint: 终点位置
    ///   - repeatCount: 重复次数
    @objc func zs_basicMove(animation duration: TimeInterval,
                            delay: TimeInterval = 0,
                            to endPoint: CGPoint,
                            repeatCount: Float = 0) {
        
        let basicAnimation = CABasicAnimation(keyPath: "position")
        basicAnimation.beginTime = CACurrentMediaTime() + delay
        basicAnimation.duration = duration
        basicAnimation.repeatCount = repeatCount
        basicAnimation.isRemovedOnCompletion = false
        basicAnimation.fromValue = position
        basicAnimation.toValue = CGPoint(x: position.x + endPoint.x, y: position.y + endPoint.y)
        add(basicAnimation, forKey: "move")
    }
    
    /// 纵坐标缩放动画
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - startPoint: 动画起始位置，锚点，范围在[0,1]
    ///   - endValue: 最终的缩放倍数
    ///   - repeatCount: 重复次数
    @objc func zs_basicScaleY(animation duration: TimeInterval,
                              startPoint: CGPoint = CGPoint(x: 0.5, y: 0.5),
                              value: CGFloat,
                              repeatCount: Float = MAXFLOAT) {
        
        var anchorPointX = startPoint.x > 1 ? 1 : startPoint.x
        anchorPointX = startPoint.x < 0 ? 0 : startPoint.x
        
        var anchorPointY = startPoint.y > 1 ? 1 : startPoint.y
        anchorPointY = startPoint.y < 0 ? 0 : startPoint.y
        
        anchorPoint = CGPoint(x: anchorPointX, y: anchorPointY)
        
        let basicAnimation = CABasicAnimation.init(keyPath: "transform.scale.y")
        basicAnimation.toValue = value
        basicAnimation.duration = duration
        // 动画结束时是否执行逆动画
        basicAnimation.autoreverses = true
        basicAnimation.repeatCount = repeatCount
        basicAnimation.isRemovedOnCompletion = false
        add(basicAnimation, forKey: "scale")
    }
}
