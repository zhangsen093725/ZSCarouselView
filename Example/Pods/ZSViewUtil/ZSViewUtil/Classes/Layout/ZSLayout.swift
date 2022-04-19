//
//  ZSLayout.swift
//  ZSViewUtil
//
//  Created by Josh on 2020/8/5.
//

import UIKit

public enum KDevice {
    
    // MARK: - 屏幕宽高、frame
    static public let width: CGFloat = UIScreen.main.bounds.width
    static public let height: CGFloat = UIScreen.main.bounds.height
    static public let bounds: CGRect = UIScreen.main.bounds
    
    // MARK: - 关于刘海屏幕适配
    static public let tabbarHeight: CGFloat = KDevice.isBangs ? 83 : 49
    static public let safeBottom: CGFloat = KDevice.isBangs ? 34 : 0
    static public let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    static public let navigationHeight: CGFloat = 44 + statusBarHeight
    
    // MARK: - 设备类型
    static public let isPhone: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    static public let isPad: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)
    static public let isBangs: Bool = (String(format: "%.2f", 9.0 / 19.5) == String(format: "%.2f", KDevice.width / KDevice.height))
}

// MARK: - iPhone以375 * 667为基础机型的比例系数，iPad以768 * 1024为基础机型的比例系数
public extension CGFloat {
    
    var zs_pt: CGFloat { return CGFloat(Double(String(format: "%.3f", self * KDevice.width / 375.0)) ?? 0) }
    
    var zs_width_ratio: CGFloat { return self * ( KDevice.isPad ?  768.0 / 1024.0 : 375.0 / 667.0 ) }
    
    var zs_height_ratio: CGFloat { return self * ( KDevice.isPad ?  1024.0 / 768.0 : 667.0 / 375.0 ) }
}

public extension Int {
    
    var zs_pt: CGFloat { return CGFloat(self).zs_pt }
    
    var zs_width_ratio: CGFloat { return CGFloat(self).zs_width_ratio }
    
    var zs_height_ratio: CGFloat { return CGFloat(self).zs_height_ratio }
}

public extension Float {
    
    var zs_pt: CGFloat { return CGFloat(self).zs_pt }
    
    var zs_width_ratio: CGFloat { return CGFloat(self).zs_width_ratio }
    
    var zs_height_ratio: CGFloat { return CGFloat(self).zs_height_ratio }
}

public extension Double {
    
    var zs_pt: CGFloat { return CGFloat(self).zs_pt }
    
    var zs_width_ratio: CGFloat { return CGFloat(self).zs_width_ratio }
    
    var zs_height_ratio: CGFloat { return CGFloat(self).zs_height_ratio }
}


// MARK: - UIView 扩展
@objc public extension UIView {
    
    func zs_margin(top: CGFloat = CGFloat(MAXFLOAT),
                   left: CGFloat = CGFloat(MAXFLOAT),
                   bottom: CGFloat = CGFloat(MAXFLOAT),
                   right: CGFloat = CGFloat(MAXFLOAT)) {
        
        zs_margin = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    var zs_margin: UIEdgeInsets {
        set
        {
            zs_top = newValue.top == CGFloat(MAXFLOAT) ? zs_top : newValue.top
            zs_left = newValue.left == CGFloat(MAXFLOAT) ? zs_left : newValue.left
            zs_bottom = newValue.bottom == CGFloat(MAXFLOAT) ? zs_bottom : newValue.bottom
            zs_right = newValue.right == CGFloat(MAXFLOAT) ? zs_right : newValue.right
        }
        get
        {
            return UIEdgeInsets(top: zs_top,
                                left: zs_left,
                                bottom: zs_bottom,
                                right: zs_right)
        }
    }
    
    var zs_top: CGFloat {
        set
        {
            frame.origin.y = newValue
        }
        get
        {
            return frame.minY
        }
    }
    
    var zs_left: CGFloat {
        set
        {
            frame.origin.x = newValue
        }
        get
        {
            return frame.minX
        }
    }
    
    var zs_bottom: CGFloat {
        
        set
        {
            let bottom = newValue == CGFloat(MAXFLOAT) ? zs_bottom : newValue

            let superheight = (superview?.frame.height ?? 0)
            
            zs_height = superheight > 0 ? superheight - zs_top - bottom : 0
        }
        get
        {
            let superheight = (superview?.frame.height ?? 0)
            
            return zs_maxY > 0 ? superheight - zs_maxY : zs_maxY
        }
    }
    
    var zs_right: CGFloat {
        
        set
        {
            let right = newValue == CGFloat(MAXFLOAT) ? zs_right : newValue

            let superwidth = (superview?.frame.width ?? 0)
            
            zs_width = superwidth > 0 ? superwidth - zs_left - right : 0
        }
        get
        {
            let superwidth = (superview?.frame.width ?? 0)
            
            return zs_maxX > 0 ? superwidth - zs_maxX : zs_maxX
        }
    }
    
    var zs_centerX: CGFloat {
        set
        {
            center.x = newValue
        }
        get
        {
            return center.x
        }
    }
    
    var zs_centerY: CGFloat {
        set
        {
            center.y = newValue
        }
        get
        {
            return center.y
        }
    }
    
    var zs_width: CGFloat {
        set
        {
            frame.size.width = newValue
        }
        get
        {
            return frame.width
        }
    }
    
    var zs_height: CGFloat {
        set
        {
            frame.size.height = newValue
        }
        get
        {
            return frame.height
        }
    }
    
    var zs_maxX: CGFloat { return frame.maxX }
    
    var zs_maxY: CGFloat { return frame.maxY }
}
