//
//  JDProfile.swift
//  JadeKing
//
//  Created by 张森 on 2019/8/3.
//  Copyright © 2019 张森. All rights reserved.
//

import Foundation

public enum KDevice {
    
    // MARK: - 屏幕宽高、frame
    static public let width: CGFloat = UIScreen.main.bounds.width
    static public let height: CGFloat = UIScreen.main.bounds.height
    static public let frame: CGRect = UIScreen.main.bounds
    
    // MARK: - 屏幕16:9比例系数下的宽高
    static public let width16_9: CGFloat = KDevice.height * 9.0 / 16.0
    static public let height16_9: CGFloat = KDevice.width * 16.0 / 9.0
    
    // MARK: - 关于刘海屏幕适配
    static public let tabbarHeight: CGFloat = KDevice.aboveiPhoneX ? 83 : 49
    public static let homeHeight: CGFloat = KDevice.aboveiPhoneX ? 34 : 0
    static public let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: - 设备类型
    static public let isPhone: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    static public let isPad: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)
    static public let aboveiPhoneX: Bool = (Float(String(format: "%.2f", 9.0 / 19.5)) == Float(String(format: "%.2f", KDevice.width / KDevice.height)))
}


// MARK: - iPhone以375 * 667为基础机型的比例系数，iPad以768 * 1024为基础机型的比例系数
public let KWidthUnit: CGFloat = KDevice.width / (KDevice.isPad ? 768.0 : 375.0)
public let KHeightUnit: CGFloat = KDevice.isPad ? KDevice.height / 1024.0 : ( KDevice.aboveiPhoneX ? KDevice.height16_9 / 667.0 : KDevice.height / 667.0 )


// MARK: - 子试图16:9比例系数下的宽高
public func KSubViewWidth(_ subViewHeight: CGFloat) -> CGFloat {
    return KDevice.isPad ? subViewHeight * 3.0 / 4.0 : subViewHeight * 9.0 / 16.0
}

public func KSubViewHeight(_ subviewWidth: CGFloat) -> CGFloat {
    return KDevice.isPad ? subviewWidth * 4.0 / 3.0 : subviewWidth * 16.0 / 9.0
}


// MARK: - iPad适配
public func iPadWidth(_ viewWidth: CGFloat) -> CGFloat {
    return viewWidth / 375.0 * KDevice.width  // 以375宽度进行比例计算
}

public func iPadHeight(_ viewHeight: CGFloat) -> CGFloat {
    return viewHeight / 667.0 * KDevice.height  // 以667高度进行比例计算
}

public func iPadFullScreenWidthToHeight(_ viewHeight: CGFloat) -> CGFloat {
    return KDevice.isPad ? KDevice.width / 375.0 * viewHeight * KHeightUnit : viewHeight * KHeightUnit
}


// MARK: - 字体和颜色
public func KNormalFont(_ font: CGFloat) -> UIFont {
    return .systemFont(ofSize: font * KHeightUnit)
}

public func KBoldFont(_ font: CGFloat) -> UIFont {
    return .boldSystemFont(ofSize: font * KHeightUnit)
}

public func KItalicFont(_ font: CGFloat) -> UIFont {
    return .italicSystemFont(ofSize: font * KHeightUnit)
}

public func KColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return .init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}

@available(iOS 8.2, *)
public func KFont(_ font: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
    return .systemFont(ofSize: font * KHeightUnit, weight: weight)
}

@available(iOS 13.0, *)
public func KColor(light: UIColor, dark: UIColor) -> UIColor {
    
    return UIColor { (traitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
        case .light:
            return light
        case .dark:
            return dark
        default:
            fatalError()
        }
    }
}

