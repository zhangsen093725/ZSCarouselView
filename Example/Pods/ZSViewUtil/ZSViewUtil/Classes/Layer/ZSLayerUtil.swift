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
    ///   - locations: [渐变的位置，区间在[0,1]]
    ///   - colors: [对应的渐变位置的颜色]
    ///   - startPointX: 渐变的水平起点，区间在[0,1]，默认为 0
    ///   - endPointX: 渐变的水平终点，区间在[0,1]，默认为 1
    ///   - startPointY: 渐变的垂直起点，区间在[0,1]，默认为 0
    ///   - endPointY: 渐变的垂直终点，区间在[0,1]，默认为 1
    @discardableResult
    class func zs_init(locations: [NSNumber],
                       colors: [UIColor],
                       horizontal startPointX: CGFloat = 0,
                       toX endPointX: CGFloat = 1,
                       vertical startPointY: CGFloat = 0,
                       toY endPointY: CGFloat = 1) -> Self {
        
        var _startPointX_ = startPointX > 1 ? 1 : startPointX
        _startPointX_ = startPointX < 0 ? 0 : startPointX
        
        var _endPointX_ = endPointX > 1 ? 1 : endPointX
        _endPointX_ = endPointX < 0 ? 0 : endPointX
        
        var _startPointY_ = startPointY > 1 ? 1 : startPointY
        _startPointY_ = startPointY < 0 ? 0 : startPointY
        
        var _endPointY_ = endPointY > 1 ? 1 : endPointY
        _endPointY_ = endPointY < 0 ? 0 : endPointY
        
        var _colors_: [CGColor] = []
        for color in colors {
            _colors_.append(color.cgColor)
        }
        
        let gradientLayer = Self()
        gradientLayer.locations = locations
        gradientLayer.colors = _colors_
        gradientLayer.startPoint = CGPoint(x: _startPointX_, y: _startPointY_)
        gradientLayer.endPoint = CGPoint(x: _endPointX_, y: _endPointY_)
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
        
        var _offsetRed_ = offsetRed > 1 ? 1 : offsetRed
        _offsetRed_ = offsetRed < -1 ? -1 : offsetRed
        
        var _offsetGreen_ = offsetGreen > 1 ? 1 : offsetGreen
        _offsetGreen_ = offsetGreen < -1 ? -1 : offsetGreen
        
        var _offsetBlue_ = offsetBlue > 1 ? 1 : offsetBlue
        _offsetBlue_ = offsetBlue < -1 ? -1 : offsetBlue
        
        // 颜色的渐变，相对于前一个层的渐变（取值-1~+1）.RGB有三种颜色，所以这里也是绿红蓝三种。
        replicatorLayer.instanceRedOffset = _offsetRed_
        replicatorLayer.instanceGreenOffset = _offsetGreen_
        replicatorLayer.instanceBlueOffset = _offsetBlue_
        
        return replicatorLayer
    }
}
