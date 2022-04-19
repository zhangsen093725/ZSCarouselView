//
//  ZSButton.swift
//  JadeToB
//
//  Created by 张森 on 2019/11/12.
//  Copyright © 2019 张森. All rights reserved.
//

import UIKit

@objc public extension ZSButton {
    
    @objc enum ImageInset: Int {
        case left
        case right
        case top
        case bottom
    }
}


@objcMembers open class ZSButton: UIButton {
    
    @objc public var imageInset: ZSButton.ImageInset = .left
    
    private var _gradientLayer: CAGradientLayer?
    private var _gradientColors: [UIColor] = []
    
    /// 设置Button的背景渐变色
    /// - Parameters:
    ///   - locations: [颜色改变的位置，范围[0, 1]，0表示头部，1表示尾部，0.5表示中心，一个位置对应一个颜色]
    ///   - colors: [渐变的颜色，至少2个，和需要改变颜色的位置一一对应]
    ///   - startPoint: 渐变颜色的起始点，范围[0, 1], (0, 0）表示左上角，(0, 1)表示左下角，(1, 0)表示右上角，(1, 1)表示右下角
    ///   - endPoint: 渐变颜色的终止点，范围[0, 1], (0, 0）表示左上角，(0, 1)表示左下角，(1, 0)表示右上角，(1, 1)表示右下角
    open func zs_addBackgroundGradient(in locations: [NSNumber], colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        
        let _startPoint_ = CGPoint(x: CGFloat(fabsf(Float(startPoint.x)) < 1 ? fabsf(Float(startPoint.x)) : 1),
                                   y: CGFloat(fabsf(Float(startPoint.y)) < 1 ? fabsf(Float(startPoint.y)) : 1))
        
        let _endPoint_ = CGPoint(x: CGFloat(fabsf(Float(endPoint.x)) < 1 ? fabsf(Float(endPoint.x)) : 1),
                                 y: CGFloat(fabsf(Float(endPoint.y)) < 1 ? fabsf(Float(endPoint.y)) : 1))
        
        _gradientColors = colors
        
        let _colors_: [CGColor] = colors.map{ $0.cgColor }
        
        let _locations_: [NSNumber] = locations.map{ NSNumber(value: fabsf($0.floatValue) < 1 ? fabsf($0.floatValue) : 1)  }
        
        if _gradientLayer == nil
        {
            _gradientLayer = CAGradientLayer()
        }
        _gradientLayer?.locations = _locations_
        _gradientLayer?.colors = _colors_
        _gradientLayer?.startPoint = _startPoint_
        _gradientLayer?.endPoint = _endPoint_
        
        layer.addSublayer(_gradientLayer!)
    }
    
    /// 移除Button的背景渐变色
    open func zs_removeBackgroundGradient() {
        
        guard _gradientLayer != nil else { return }
        
        _gradientLayer?.removeFromSuperlayer()
        _gradientLayer = nil
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        _gradientLayer?.frame = bounds
        CATransaction.commit()
        
        switch imageInset
        {
        case .left:
            
            layoutImageLeft()
            break
        case .right:
            
            layoutImageRight()
            break
        case .top:
            
            layoutImageTop()
            break
        case .bottom:
            
            layoutImageBottom()
            break
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        
        var imageViewSize = self.imageView?.intrinsicContentSize ?? .zero
        var titleLabelSize = self.titleLabel?.intrinsicContentSize ?? .zero

        if imageViewSize == CGSize(width: -1, height: -1)
        {
            imageViewSize = .zero;
        }
        
        if titleLabelSize == CGSize(width: -1, height: -1)
        {
            titleLabelSize = .zero;
        }
        
        return CGSize(width: imageViewSize.width + self.imageEdgeInsets.left + self.imageEdgeInsets.right +
                        titleLabelSize.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      height: imageViewSize.height + self.imageEdgeInsets.top + self.imageEdgeInsets.bottom +
                        titleLabelSize.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom)
    }
    
    var imageViewSize: CGSize {
        
        let imageViewSize = self.imageView?.intrinsicContentSize ?? .zero
        
        var height = min(imageViewSize.height, frame.height)
        height = height > 0 ? height : 0
        
        let scale = imageViewSize.height > 0 ? imageViewSize.width / imageViewSize.height : 1
        
        var width = min(height * scale, frame.width)
        width = width > 0 ? width : 0;
        
        return CGSize(width: width, height: height)
    }
    
    func layoutImageLeft() {
        
        var titleLabelSize = self.titleLabel?.intrinsicContentSize ?? .zero
        
        let contentWidth = frame.width - (imageViewSize.width + imageEdgeInsets.right + imageEdgeInsets.left +
                                            titleLabelSize.width + titleEdgeInsets.left + titleEdgeInsets.right)
        let contentHeight = frame.height
        
        titleLabelSize = CGSize(width: min(titleLabelSize.width, contentWidth), height: min(contentHeight, titleLabelSize.height))
        
        var imageViewX: CGFloat = 0
        
        switch contentHorizontalAlignment
        {
        case .center:
            
            imageViewX = (frame.width - (imageViewSize.width + imageEdgeInsets.right +
                                            titleLabelSize.width + titleEdgeInsets.left)) * 0.5
            break
            
        case .left:
            
            imageViewX = imageEdgeInsets.left
            break
            
        case .right:
            
            imageViewX = (frame.width - (imageViewSize.width + imageEdgeInsets.right +
                                            titleLabelSize.width + titleEdgeInsets.left + titleEdgeInsets.right))
            break
            
        case .fill:
            
            imageViewX = imageEdgeInsets.left
            break
            
        default:
            break
        }
        
        var titleLabelY: CGFloat = 0
        var imageViewY: CGFloat = 0
        
        switch (contentVerticalAlignment)
        {
        case .center:
            
            imageViewY = (frame.height - imageViewSize.height) * 0.5 + imageEdgeInsets.top - imageEdgeInsets.bottom
            titleLabelY = (frame.height - titleLabelSize.height) * 0.5 + titleEdgeInsets.top - titleEdgeInsets.bottom
            
            break
            
        case .top:
            
            imageViewY = imageEdgeInsets.top
            titleLabelY = titleEdgeInsets.top
            
            break
            
        case .bottom:
            
            imageViewY = (frame.height - imageViewSize.height - imageEdgeInsets.bottom)
            titleLabelY = (frame.height - titleLabelSize.height - titleEdgeInsets.bottom)
            
            break
            
        case .fill:
            
            imageViewY = imageEdgeInsets.top
            titleLabelY = titleEdgeInsets.top
            
            break
            
        default:
            break;
        }
        
        imageView?.frame.origin.x = imageViewX
        imageView?.frame.origin.y = imageViewY
        imageView?.frame.size = imageViewSize
        
        titleLabel?.frame.origin.x = (imageView?.frame.maxX ?? 0) + titleEdgeInsets.left
        titleLabel?.frame.origin.y = titleLabelY
        titleLabel?.frame.size = titleLabelSize
    }
    
    
    func layoutImageRight() {
        
        var titleLabelSize = self.titleLabel?.intrinsicContentSize ?? .zero
        
        let contentWidth = frame.width - (imageViewSize.width + imageEdgeInsets.right + imageEdgeInsets.left +
                                            titleLabelSize.width + titleEdgeInsets.left + titleEdgeInsets.right)
        let contentHeight = frame.height
        
        titleLabelSize = CGSize(width: min(titleLabelSize.width, contentWidth), height: min(contentHeight, titleLabelSize.height))
        
        var titleLabelX: CGFloat = 0
        
        switch contentHorizontalAlignment
        {
        case .center:
            
            titleLabelX = (frame.width - (imageViewSize.width + imageEdgeInsets.left +
                                            titleLabelSize.width + titleEdgeInsets.right)) * 0.5
            break
            
        case .left:
            
            titleLabelX = titleEdgeInsets.left
            break
            
        case .right:
            
            titleLabelX = (frame.width - (imageViewSize.width + imageEdgeInsets.left + imageEdgeInsets.right +
                                            titleLabelSize.width + titleEdgeInsets.right))
            break
            
        case .fill:
            
            titleLabelX = titleEdgeInsets.left
            break
            
        default:
            break
        }
        
        var titleLabelY: CGFloat = 0
        var imageViewY: CGFloat = 0
        
        switch (contentVerticalAlignment)
        {
        case .center:
            
            imageViewY = (frame.height - imageViewSize.height) * 0.5 + imageEdgeInsets.top - imageEdgeInsets.bottom
            titleLabelY = (frame.height - titleLabelSize.height) * 0.5 + titleEdgeInsets.top - titleEdgeInsets.bottom
            
            break
            
        case .top:
            
            imageViewY = imageEdgeInsets.top
            titleLabelY = titleEdgeInsets.top
            
            break
            
        case .bottom:
            
            imageViewY = (frame.height - imageViewSize.height - imageEdgeInsets.bottom)
            titleLabelY = (frame.height - titleLabelSize.height - titleEdgeInsets.bottom)
            
            break
            
        case .fill:
            
            imageViewY = imageEdgeInsets.top
            titleLabelY = titleEdgeInsets.top
            
            break
            
        default:
            break;
        }
        
        titleLabel?.frame.origin.x = titleLabelX
        titleLabel?.frame.origin.y = titleLabelY
        titleLabel?.frame.size = titleLabelSize
        
        imageView?.frame.origin.x = imageEdgeInsets.left + (titleLabel?.frame.maxX ?? 0)
        imageView?.frame.origin.y = imageViewY
        imageView?.frame.size = imageViewSize
    }
    
    
    func layoutImageTop() {
        
        var titleLabelSize = self.titleLabel?.intrinsicContentSize ?? .zero
        
        let contentWidth = frame.width
        let contentHeight = frame.height - (imageViewSize.height + imageEdgeInsets.top + imageEdgeInsets.bottom +
                                                titleLabelSize.width + titleEdgeInsets.top + titleEdgeInsets.bottom)
        
        titleLabelSize = CGSize(width: min(titleLabelSize.width, contentWidth), height: min(contentHeight, titleLabelSize.height))
        
        var titleLabelX: CGFloat = 0
        var imageViewX: CGFloat = 0
        
        switch contentHorizontalAlignment
        {
        case .center:
            
            imageViewX = (frame.width - imageViewSize.width) * 0.5 + imageEdgeInsets.left - imageEdgeInsets.right
            titleLabelX = (frame.width - titleLabelSize.width) * 0.5 + titleEdgeInsets.left - titleEdgeInsets.right
            break
            
        case .left:
            
            imageViewX = imageEdgeInsets.left
            titleLabelX = titleEdgeInsets.left
            break
            
        case .right:
            
            imageViewX = frame.width - imageViewSize.width - imageEdgeInsets.right
            titleLabelX = frame.width - titleLabelSize.width - titleEdgeInsets.right
            break
            
        case .fill:
            
            imageViewX = imageEdgeInsets.left
            titleLabelX = titleEdgeInsets.left
            break
            
        default:
            break
        }
        
        var imageViewY: CGFloat = 0
        
        switch (contentVerticalAlignment)
        {
        case .center:
            
            imageViewY = (frame.height - (imageViewSize.height + imageEdgeInsets.bottom +
                                            titleLabelSize.height + titleEdgeInsets.top)) * 0.5
            
            break
            
        case .top:
            
            imageViewY = imageEdgeInsets.top
            
            break
            
        case .bottom:
            
            imageViewY = (frame.height - (imageViewSize.height + imageEdgeInsets.bottom +
                                            titleLabelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom))
            
            break
            
        case .fill:
            
            imageViewY = imageEdgeInsets.top
            
            break
            
        default:
            break;
        }
        
        imageView?.frame.origin.x = imageViewX
        imageView?.frame.origin.y = imageViewY
        imageView?.frame.size = imageViewSize
        
        titleLabel?.frame.origin.x = titleLabelX
        titleLabel?.frame.origin.y = (imageView?.frame.maxY ?? 0) + titleEdgeInsets.top
        titleLabel?.frame.size = titleLabelSize
    }
    
    func layoutImageBottom() {
        
        var titleLabelSize = self.titleLabel?.intrinsicContentSize ?? .zero
        
        let contentWidth = frame.width
        let contentHeight = frame.height - (imageViewSize.height + imageEdgeInsets.top + imageEdgeInsets.bottom +
                                                titleLabelSize.width + titleEdgeInsets.top + titleEdgeInsets.bottom)
        
        titleLabelSize = CGSize(width: min(titleLabelSize.width, contentWidth), height: min(contentHeight, titleLabelSize.height))
        
        var titleLabelX: CGFloat = 0
        var imageViewX: CGFloat = 0
        
        switch contentHorizontalAlignment
        {
        case .center:
            
            imageViewX = (frame.width - imageViewSize.width) * 0.5 + imageEdgeInsets.left - imageEdgeInsets.right
            titleLabelX = (frame.width - titleLabelSize.width) * 0.5 + titleEdgeInsets.left - titleEdgeInsets.right
            break
            
        case .left:
            
            imageViewX = imageEdgeInsets.left
            titleLabelX = titleEdgeInsets.left
            break
            
        case .right:
            
            imageViewX = frame.width - imageViewSize.width - imageEdgeInsets.right
            titleLabelX = frame.width - titleLabelSize.width - titleEdgeInsets.right
            break
            
        case .fill:
            
            imageViewX = imageEdgeInsets.left
            titleLabelX = titleEdgeInsets.left
            break
            
        default:
            break
        }
        
        var titleLabelY: CGFloat = 0
        
        switch (contentVerticalAlignment)
        {
        case .center:
            
            titleLabelY = (frame.height - (imageViewSize.height + imageEdgeInsets.top +
                                            titleLabelSize.height + titleEdgeInsets.bottom)) * 0.5
            
            break
            
        case .top:
            
            titleLabelY = titleEdgeInsets.top
            
            break
            
        case .bottom:
            
            titleLabelY = (frame.height - (imageViewSize.height + imageEdgeInsets.top + imageEdgeInsets.bottom +
                                            titleLabelSize.height + titleEdgeInsets.bottom))
            
            break
            
        case .fill:
            
            titleLabelY = titleEdgeInsets.top
            
            break
            
        default:
            break;
        }
        
        titleLabel?.frame.origin.x = titleLabelX
        titleLabel?.frame.origin.y = titleLabelY
        titleLabel?.frame.size = titleLabelSize
        
        imageView?.frame.origin.x = imageViewX
        imageView?.frame.origin.y = (titleLabel?.frame.maxY ?? 0) + imageEdgeInsets.top
        imageView?.frame.size = imageViewSize
    }
}
