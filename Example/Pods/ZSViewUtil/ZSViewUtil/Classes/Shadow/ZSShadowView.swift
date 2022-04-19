//
//  ZSShadowView.swift
//  ZSViewUtil
//
//  Created by Josh on 2020/8/31.
//

import UIKit

@objcMembers open class ZSShadowView: UIView {

    public var color: UIColor = UIColor.black.withAlphaComponent(0.2) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var offset: CGPoint = CGPoint(x: 0, y: 4) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var blur: CGFloat = 16 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var radius: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var _backgroundColor_: UIColor? = UIColor.white
    open override var backgroundColor: UIColor? {
        set {
            _backgroundColor_ = newValue
            super.backgroundColor = UIColor.clear
        }
        get {
            return _backgroundColor_
        }
    }
    
    public lazy var contentView: UIView = {
        
        let contentView = UIView()
        contentView.backgroundColor = UIColor.clear
        contentView.clipsToBounds = true
        addSubview(contentView)
        return contentView
    }()
    
    open override func draw(_ rect: CGRect) {
        
        //获取绘制上下文
        guard let context = UIGraphicsGetCurrentContext() else { return }
         
        //计算要在其中绘制的矩形
        let pathRect = self.bounds.insetBy(dx: blur, dy: blur)
         
        //创建一个圆角矩形路径
        let rectanglePath = UIBezierPath(roundedRect: pathRect, cornerRadius: radius)
         
        //等价于保存上下文
        context.saveGState()
         
        //此函数创建和应用阴影
        context.setShadow(offset: CGSize(width: offset.x, height: offset.y), blur: blur, color: color.cgColor)
         
        //绘制路径；它将带有一个阴影
        _backgroundColor_?.setFill()
        rectanglePath.fill()
         
        //等价于重载上下文
        context.restoreGState()
        
        contentView.frame = pathRect
        contentView.layer.cornerRadius = radius
    }

    open override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
}
