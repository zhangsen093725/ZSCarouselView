//
//  ZSDragStaticShakeItemView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/3.
//

import UIKit

@objcMembers open class ZSDragStaticShakeItemView: ZSDragStaticItemView  {
    
    open override func configGestureRecognizer() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(gestureRecognizerAction(_:)))
        addGestureRecognizer(longPress)
    }
    
    open func beginShakeAnimation() {
        
        let rotation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotation.duration = 0.1
        rotation.fromValue = -Double.pi / 50
        rotation.toValue = Double.pi / 50
        rotation.repeatCount = Float(LONG_MAX)
        rotation.autoreverses = true
        layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        layer.add(rotation, forKey: "shake")
    }
    
    open func endShakeAnimation() {
        layer.removeAnimation(forKey: "shake")
    }
}
