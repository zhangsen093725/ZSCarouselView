//
//  ZSShapeLayerUtil.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/28.
//

import UIKit

@objc public extension CAShapeLayer {
    
    /// 圆角图层
    /// - Parameters:
    ///   - corners: 圆角位置
    ///   - cornerRadius: 圆角半径
    ///   - layer: 添加到的View的图层
    @discardableResult
    class func zs_init(roundingCorners corners: UIRectCorner,
                       cornerRadius: CGFloat,
                       to layer: CALayer) -> Self {
        
        let maskPath = UIBezierPath(roundedRect:layer.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: 0))
        
        let maskLayer = Self()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
        return maskLayer
    }
}
