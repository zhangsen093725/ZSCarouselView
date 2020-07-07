//
//  ZSSphereView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/3/13.
//

import UIKit

@objcMembers open class ZSSphereView: UIView {
    
    /// 是否开启自动滚动，默认为 true
    public var isAutoRotate: Bool = true
    
    /// 自动滚动的速度，默认是 6 度 / 秒，惯性的大小和速度影响手指拖拽时滚动的速度
    public var autoRotateSpeed: CGFloat = 6
    
    /// 是否开启滚动惯性，默认为 true
    public var isInertiaRotate: Bool = true
    
    /// 惯性的初始大小，默认为 20，惯性的大小和速度影响手指拖拽时滚动的速度
    public var inertiaRotatePower: CGFloat = 20
    
    /// 是否开启翻转手势，defult：true
    public var isRotationGesture: Bool = true
    
    /// 是否开启拖动手势，defult：true
    public var isPanGesture: Bool = true
    
    var property = Property()
    
    struct Property {
        
        /// 惯性滚动的方向，x=1为左， x=-1为右，y=1为下，y=-1为上
        var intervalRotatePoint: CGPoint = CGPoint(x: 1, y: 1)
        
        /// 滚动动画每秒多少帧
        var fps: CGFloat = 60
        
        /// 自动滚动的定时器
        var displayLink: ZSSphereDisplayLink?
        
        /// 惯性滚动的定时器
        var inertiaDisplayLink: ZSSphereDisplayLink?
        
        /// item的集合
        var items: [UIView] = []
        
        /// 每一个item的位置
        var itemPoints: [PFPoint] = []
        
        /// 拖动以前的位置
        var previousLocationInView: CGPoint = .zero
        
        /// 拖动之后的位置
        var originalLocationInView: CGPoint = .zero
        
        /// 拖拽最后的x
        var lastXAxisDirection: PFAxisDirection = PFAxisDirectionNone
        
        /// 拖拽最后的y
        var lastYAxisDirection: PFAxisDirection = PFAxisDirectionNone
        
        /// 惯性的力度，逐渐减弱，直到为0
        var inertiaRotatePower: CGFloat = 0
        
        /// 最后旋转的角度
        var lastSphereRotationAngle: CGFloat = 1
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpGestureRecognizer()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    deinit {
        stopDisplay()
        stopInertiaDisplay()
    }
    
    /// 初始化设置球体内部的item
    /// - Parameter items: item集合
    open func zs_setSphere(_ items: [UIView]) {
        
        guard items.count > 0 else { return }
        property.items = Array(items)
    }
    
    open func zs_beginAnimation() {
        
        guard frame != .zero else { return }
        
        guard property.items.count > 0 else { return }
        
        let inc = Double.pi * (3 - sqrt(5))
        let offset = 2 / Double(property.items.count)
        
        for (index, item) in property.items.enumerated() {
            
            let y = Double(index) * offset - 1 + (offset * 0.5)
            let r = sqrt(1 - pow(y, 2))
            let phi = Double(index) * inc
            
            let point = PFPoint(x: CGFloat(cos(phi)*r), y: CGFloat(y), z: CGFloat(sin(phi)*r))
            property.itemPoints.append(point)
            item.center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
            addSubview(item)
            layoutIfNeeded()
            
            let time = TimeInterval(CGFloat(arc4random() % UInt32(property.fps)) / property.fps)
            UIView.animate(withDuration: time) {
                self.layout(item, with: point)
            }
        }
        
        if isAutoRotate {
            startDisplay()
        } else {
            runDisplayLink()
        }
    }
}
