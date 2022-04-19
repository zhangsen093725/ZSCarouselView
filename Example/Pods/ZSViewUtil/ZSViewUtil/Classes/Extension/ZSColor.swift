//
//  ZSColor.swift
//  ZSViewUtil
//
//  Created by Josh on 2020/11/12.
//

import UIKit

// MARK: - UIColor扩展
@objc extension UIColor {
    
    class func hexString(hexCode: String) -> String {
        
        var hexString: String = hexCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (hexString.hasPrefix("#"))
        {
            hexString.remove(at: hexString.startIndex)
        }
        
        if (hexString.hasPrefix("0X"))
        {
            hexString = String(hexString[hexString.index(hexString.startIndex, offsetBy: 2)..<hexString.endIndex])
        }
        
        return hexString
    }
    
    public convenience init(rgb hexCode: String, alpha: CGFloat = 1) {
        
        let cString = Self.hexString(hexCode: hexCode)
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        if cString.count == 6
        {
            
            self.init(r: CGFloat((rgbValue & 0x00FF0000) >> 16),
                      g: CGFloat((rgbValue & 0x0000FF00) >> 8),
                      b: CGFloat(rgbValue & 0x000000FF),
                      a: alpha)
            return
        }
        
        self.init(r: 255,
                  g: 255,
                  b: 255,
                  a: 1)
    }
    
    public convenience init(argb hexCode: String, alpha: CGFloat = 1) {
        
        let cString = Self.hexString(hexCode: hexCode)
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        if cString.count == 8
        {
            
            self.init(r: CGFloat((rgbValue & 0x00FF0000) >> 16),
                      g: CGFloat((rgbValue & 0x0000FF00) >> 8),
                      b: CGFloat(rgbValue & 0x000000FF),
                      a: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0)
            return
        }
        
        self.init(r: 255,
                  g: 255,
                  b: 255,
                  a: 1)
    }
    
    public convenience init(rgba hexCode: String, alpha: CGFloat = 1) {
        
        let cString = Self.hexString(hexCode: hexCode)
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        if cString.count == 8
        {
            
            self.init(r: CGFloat((rgbValue & 0xFF000000) >> 24),
                      g: CGFloat((rgbValue & 0x00FF0000) >> 16),
                      b: CGFloat((rgbValue & 0x0000FF00) >> 8),
                      a: CGFloat(rgbValue & 0x000000FF) / 255.0)
            return
        }
        
        self.init(r: 255,
                  g: 255,
                  b: 255,
                  a: 1)
    }
    
    public convenience init(r red: CGFloat,
                            g green: CGFloat,
                            b blue: CGFloat,
                            a alpha: CGFloat = 1) {
        
        self.init(red: red / 255.0,
                  green: green / 255.0,
                  blue: blue / 255.0,
                  alpha: alpha)
    }
    
    @available(iOS 13.0, *)
    public convenience init(lightR: CGFloat, darkR: CGFloat,
                            lightG: CGFloat, darkG: CGFloat,
                            lightB: CGFloat, darkB: CGFloat,
                            lightA: CGFloat, darkA: CGFloat) {
        
        self.init { (traitCollection) -> UIColor in
            
            switch traitCollection.userInterfaceStyle {
            case .light:
                return UIColor(r: lightR, g: lightG, b: lightB, a: lightA)
            case .dark:
                return UIColor(r: darkR, g: darkG, b: darkB, a: darkA)
            default:
                fatalError()
            }
        }
    }
    
    @available(iOS 13.0, *)
    public func dark(r red: CGFloat, g green: CGFloat, b blue: CGFloat, a alpha: CGFloat = 1) -> UIColor {
        
        return dark(UIColor(r: red/255.0, g: green/255.0, b: blue/255.0, a: alpha))
    }
    
    @available(iOS 13.0, *)
    public func dark(rgb hexCode: String) -> UIColor {
        
        return dark(UIColor(rgb: hexCode))
    }
    
    @available(iOS 13.0, *)
    public func dark(argb hexCode: String) -> UIColor {
        
        return dark(UIColor(argb: hexCode))
    }
    
    @available(iOS 13.0, *)
    public func dark(rgba hexCode: String) -> UIColor {
        
        return dark(UIColor(rgba: hexCode))
    }
    
    @available(iOS 13.0, *)
    public func dark(_ color: UIColor) -> UIColor {
        
        return UIColor { (traitCollection) -> UIColor in
            
            switch traitCollection.userInterfaceStyle {
            case .light:
                return self
            case .dark:
                return color
            default:
                fatalError()
            }
        }
    }
}
