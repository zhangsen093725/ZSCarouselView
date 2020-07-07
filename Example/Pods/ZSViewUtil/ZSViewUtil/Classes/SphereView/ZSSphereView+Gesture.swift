//
//  ZSSphereView+Gesture.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/3/13.
//

import Foundation

extension ZSSphereView {
    
    func setUpGestureRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panRecognizer.minimumNumberOfTouches = 1
        addGestureRecognizer(panRecognizer)
        
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        addGestureRecognizer(rotationRecognizer)
    }
    
    // TODO: GestureRecognizer
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let touchPoint = gestureRecognizer.location(in: self)
        
        switch gestureRecognizer.state {
        case .began:
            property.inertiaRotatePower = inertiaRotatePower
            property.originalLocationInView = touchPoint
            property.previousLocationInView = property.originalLocationInView
            stopDisplay()
            stopInertiaDisplay()
            break
        case .changed:
            
            let normalizedTouchPoint = CGPointMakeNormalizedPoint(touchPoint, frame.width)
            let normalizedPreviousTouchPoint = CGPointMakeNormalizedPoint(property.previousLocationInView, frame.width)
            let normalizedOriginalTouchPoint = CGPointMakeNormalizedPoint(property.originalLocationInView, frame.width)
            
            let xAxisDirection = PFDirectionMakeXAxisSensitive(normalizedPreviousTouchPoint, normalizedTouchPoint)
            let yAxisDirection = PFDirectionMakeXAxisSensitive(normalizedPreviousTouchPoint, normalizedTouchPoint)
            
            if xAxisDirection != property.lastXAxisDirection &&
                xAxisDirection != PFAxisDirectionNone {
                property.lastXAxisDirection = xAxisDirection
                property.originalLocationInView = CGPoint(x: touchPoint.x, y: property.previousLocationInView.y)
            }
            
            if  yAxisDirection != property.lastYAxisDirection &&
                yAxisDirection != PFAxisDirectionNone {
                property.lastYAxisDirection = yAxisDirection
                property.originalLocationInView = CGPoint(x: property.previousLocationInView.x, y: touchPoint.y)
            }
            
            property.previousLocationInView = touchPoint
            
            property.intervalRotatePoint = CGPoint(
                x: normalizedTouchPoint.x < normalizedOriginalTouchPoint.x ? -1 : 1,
                y: normalizedTouchPoint.y < normalizedOriginalTouchPoint.y ? -1 : 1)
            
            rotateSphere(by: autoRotateSpeed * inertiaRotatePower / property.fps, fromPoint: normalizedOriginalTouchPoint, toPoint: normalizedTouchPoint)
            
            break
        default:
            startInertiaDisplay()
            break
        }
    }
    
    @objc func handleRotationGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {
        
        if gestureRecognizer.state == .ended {
            property.lastSphereRotationAngle = 0
            return
        }
        
        var rotationDirection = PFAxisDirectionNone
        
        var rotation = gestureRecognizer.rotation
        
        if rotation > property.lastSphereRotationAngle {
            rotationDirection = PFAxisDirectionPositive
        } else if rotation < property.lastSphereRotationAngle {
            rotationDirection = PFAxisDirectionNegative
        }
        
        rotation = abs(rotation) * CGFloat(rotationDirection.rawValue)
        
        for (index, subView) in property.items.enumerated() {
            
            var itemPoint = property.itemPoints[index]
            
            let aroundPoint = PFPointMake(0, 0, 0)
            let coordinate = PFMatrixTransform3DMakeFromPFPoint(itemPoint)
            let transform = PFMatrixTransform3DMakeZRotationOnPoint(aroundPoint, rotation)
            
            itemPoint = PFPointMakeFromMatrix(PFMatrixMultiply(coordinate, transform))
            
            property.itemPoints[index] = itemPoint
            layout(subView, with: itemPoint)
        }
    }
}
