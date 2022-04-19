//
//  ZSLayerUtil.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/18.
//

import UIKit

@objc public extension CAGradientLayer {
    
    /// 初始化渐变Layer
    /// - Parameters:
    ///   - locations: [颜色改变的位置，范围[0, 1]，0表示头部，1表示尾部，0.5表示中心，一个位置对应一个颜色]
    ///   - colors: [渐变的颜色，至少2个，和需要改变颜色的位置一一对应]
    ///   - startPoint: 渐变颜色的起始点，范围[0, 1], (0, 0）表示左上角，(0, 1)表示左下角，(1, 0)表示右上角，(1, 1)表示右下角
    ///   - endPoint: 渐变颜色的终止点，范围[0, 1], (0, 0）表示左上角，(0, 1)表示左下角，(1, 0)表示右上角，(1, 1)表示右下角
    @discardableResult
    class func zs_init(locations: [NSNumber],
                       colors: [UIColor],
                       startPoint: CGPoint,
                       endPoint: CGPoint) -> Self {
        
        let _startPoint_ = CGPoint(x: CGFloat(fabsf(Float(startPoint.x)) < 1 ? fabsf(Float(startPoint.x)) : 1),
                                   y: CGFloat(fabsf(Float(startPoint.y)) < 1 ? fabsf(Float(startPoint.y)) : 1))
        
        let _endPoint_ = CGPoint(x: CGFloat(fabsf(Float(endPoint.x)) < 1 ? fabsf(Float(endPoint.x)) : 1),
                                 y: CGFloat(fabsf(Float(endPoint.y)) < 1 ? fabsf(Float(endPoint.y)) : 1))
        
        let _colors_: [CGColor] = colors.map{ $0.cgColor }
        
        let _locations_: [NSNumber] = locations.map{ NSNumber(value: fabsf($0.floatValue) < 1 ? fabsf($0.floatValue) : 1)  }
        
        let gradientLayer = Self()
        gradientLayer.locations = _locations_
        gradientLayer.colors = _colors_
        gradientLayer.startPoint = _startPoint_
        gradientLayer.endPoint = _endPoint_
        return gradientLayer
    }
}




@objc public extension CAReplicatorLayer {
    
    /// 复制图层
    /// - Parameters:
    ///   - count: 图层总数
    ///   - delay: 每一个图层相对于前一个的延迟
    ///   - backgroundColor: 图层背景颜色
    ///   - offsetX: 相对于前一个图层的偏移量，起始从0计算，默认为0
    ///   - offsetY: 相对于前一个图层的偏移量，起始从0计算，默认为0
    ///   - offsetZ: 相对于前一个图层的偏移量，起始从0计算，默认为0
    ///   - offsetRed: 相对于前一个图层颜色的渐变，（取值-1~+1）
    ///   - offsetGreen: 相对于前一个图层颜色的渐变，（取值-1~+1）
    ///   - offsetBlue: 相对于前一个图层颜色的渐变，（取值-1~+1）
    @discardableResult
    class func zs_init(_ count: Int,
                       delay: TimeInterval = 0,
                       backgroundColor: UIColor,
                       offsetX: CGFloat = 0,
                       offsetY: CGFloat = 0,
                       offsetZ: CGFloat = 0,
                       offsetRed: Float = 0,
                       offsetGreen: Float = 0,
                       offsetBlue: Float = 0) -> Self {
        
        let replicatorLayer = Self()
        
        // 设置复制层里面包含子层的个数
        replicatorLayer.instanceCount = count
        
        // 设置子层相对于前一个层的偏移量
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(offsetX, offsetY, offsetZ)
        
        // 设置子层相对于前一个层的延迟时间
        replicatorLayer.instanceDelay = delay
        
        // 设置层的颜色，(前提是要设置层的背景颜色，如果没有设置背景颜色，默认是透明的，再设置这个属性不会有效果。
        replicatorLayer.instanceColor = backgroundColor.cgColor
        
        let _offsetRed_ = fabsf(offsetRed) > 1 ? 1 : fabsf(offsetRed)
        let _offsetGreen_ = fabsf(offsetGreen) > 1 ? 1 : fabsf(offsetGreen)
        let _offsetBlue_ = fabsf(offsetBlue) > 1 ? 1 : fabsf(offsetBlue)
        
        // 颜色的渐变，相对于前一个层的渐变（取值-1~+1）.RGB有三种颜色，所以这里也是绿红蓝三种。
        replicatorLayer.instanceRedOffset = _offsetRed_
        replicatorLayer.instanceGreenOffset = _offsetGreen_
        replicatorLayer.instanceBlueOffset = _offsetBlue_
        
        return replicatorLayer
    }
}
