//
//  ZSSphereView+Layout.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/3/13.
//

import Foundation

extension ZSSphereView {
    
    /// 球体转动的布局
    /// - Parameters:
    ///   - angle: 转动的角度
    ///   - fromPoint: 从什么位置转动
    ///   - toPoint: 转动到什么位置
    func rotateSphere(by angle: CGFloat, fromPoint: CGPoint, toPoint: CGPoint) {
        
        for (index, subView) in property.items.enumerated() {
            
            var itemPoint = property.itemPoints[index]
            
            let aroundpoint = PFPointMake(0, 0, 0)
            let coordinate = PFMatrixTransform3DMakeFromPFPoint(itemPoint)
            
            var transform = PFMatrixMakeIdentity(4, 4)
            let xAxisDirection = PFDirectionMakeXAxis(fromPoint, toPoint)
            let yAxisDirection = PFDirectionMakeYAxis(fromPoint, toPoint)
            
            if xAxisDirection != PFAxisDirectionNone {
                transform = PFMatrixMultiply(transform, PFMatrixTransform3DMakeYRotationOnPoint(aroundpoint, CGFloat(xAxisDirection.rawValue) * -angle))
            }
            
            if yAxisDirection != PFAxisDirectionNone {
                transform = PFMatrixMultiply(transform, PFMatrixTransform3DMakeXRotationOnPoint(aroundpoint, CGFloat(yAxisDirection.rawValue) * angle))
            }
            
            itemPoint = PFPointMakeFromMatrix(PFMatrixMultiply(coordinate, transform))
            property.itemPoints[index] = itemPoint
            
            layout(subView, with: itemPoint)
        }
    }
    
    /// 对球体内部的item进行布局
    /// - Parameters:
    ///   - subView: item
    ///   - point: 更新的位置
    func layout(_ subView: UIView, with point: PFPoint) {
        
        let width = frame.width - subView.frame.width * 2
        let height = frame.height - subView.frame.height * 2
        
        let x = coordinate(for: point.x, withinRange: width)
        let y = coordinate(for: point.y, withinRange: height)
        let z = coordinate(for: point.z, withinRange: 1)
        
        subView.center = CGPoint(x: x + subView.frame.width, y: y + subView.frame.height)
        subView.transform = CGAffineTransform.identity.scaledBy(x: z, y: z)
        subView.layer.zPosition = z
    }
    
    /// 坐标转换
    /// - Parameters:
    ///   - normalizedValue: PFPointz的值
    ///   - offset: 范围的偏移量
    func coordinate(for normalizedValue: CGFloat, withinRange offset: CGFloat) -> CGFloat {
        
        let half = offset * 0.5
        let coordinate = abs(normalizedValue) * half
        
        return normalizedValue > 0 ? coordinate + half : half - coordinate
    }
}
