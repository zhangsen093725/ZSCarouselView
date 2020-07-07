//
//  ZSToastView.swift
//  ZSToastView
//
//  Created by 张森 on 2019/8/14.
//  Copyright © 2019 张森. All rights reserved.
//

import UIKit

// MARK: - 弹窗按钮
@objc public enum ZSPopActionType: Int {
    case done = 0, cancel
}

@objcMembers public class ZSPopAction: UIButton {
    
    private var action: (()->Void)?
    private var type: ZSPopActionType = .done
    
    public var popAction: (()->Void)? {
        get {
            return action
        }
    }
    
    public var popType: ZSPopActionType {
        get {
            return type
        }
    }
    
    public class func zs_init(type: ZSPopActionType, action: (()->Void)?) -> ZSPopAction {
        
        let popAction = ZSPopAction(type: .system)
        popAction.tintColor = .clear
        popAction.setTitleColor(toastColor(82, 82, 82, 1), for: .normal)
        popAction.titleLabel?.font = toastDevice.isPad ? toastFont(17) : toastFont(15)
        popAction.type = type
        popAction.action = action
        
        return popAction
    }
    
}



// MARK: - ZSPopBaseView
public class ZSPopBaseView: UIView {
    
    fileprivate lazy var backView: UIScrollView = {
        
        let view = UIScrollView()
        view.backgroundColor = .white
        view.layer.shadowColor = toastColor(189, 189, 189, 1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1
        view.clipsToBounds = true
        addSubview(view)
        return view
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = toastColor(51, 51, 51, 1)
        label.font = .boldSystemFont(ofSize: (toastDevice.isPad ? 22 : 18) * toastHeightUnit)
        label.textAlignment = .center
        backView.addSubview(label)
        return label
    }()
    
    fileprivate var lineLabel: UILabel {
        
        let label = UILabel()
        label.backgroundColor = toastColor(239, 239, 239, 1)
        backView.addSubview(label)
        return label
    }
    
    fileprivate var actions: Array<ZSPopAction>? = []
    
    fileprivate func layoutToView() {
        frame = UIScreen.main.bounds
        alpha = 1
        backgroundColor = toastColor(0, 0, 0, 0.5)
        
        var controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        
        while (controller?.presentedViewController != nil && !(controller?.presentedViewController is UIAlertController)) {
            controller = controller?.presentedViewController
        }
        controller?.view.addSubview(self)
    }
    
    @objc public func add(action: ZSPopAction) {
        actions?.append(action)
        backView.addSubview(action)
    }
}



// MARK: - ZSAlertView
@objcMembers public class ZSAlertView: ZSPopBaseView {
    
    private lazy var messageLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 0
        backView.addSubview(label)
        return label
    }()
    
    private func getMessageAttribute(_ message: String, textMaxSize: CGSize) -> Dictionary<NSAttributedString.Key, Any> {
        
        let msgFont = toastDevice.isPad ? toastFont(16) : toastFont(14)
        var tempAttribute: Dictionary<NSAttributedString.Key, Any>? = [.font : msgFont]
        
        let msgHeight = message.boundingRect(with: textMaxSize, options: .usesLineFragmentOrigin, attributes: tempAttribute, context: nil).size.height
        let lineHeight = 8 * toastHeightUnit
        
        let paraStyle = NSMutableParagraphStyle()
        
        paraStyle.lineSpacing = msgHeight > msgFont.lineHeight ? lineHeight : 0
        paraStyle.alignment = .center
 
        tempAttribute?[.foregroundColor] = toastColor(51, 51, 51, 1)
        tempAttribute?[.paragraphStyle] = paraStyle
        return tempAttribute!
    }
    
    private func layoutBackView(_ backX: CGFloat, backHeight: CGFloat) {
        
        let backH = min(backHeight, 470 * toastHeightUnit)
        backView.frame = CGRect(x: backX, y: (toastDevice.height - backH) * 0.5, width: toastDevice.width - 2 * backX, height: backH)
        backView.contentSize = CGSize(width: 0, height: backHeight)
        backView.layer.cornerRadius = 15 * toastHeightUnit
        backView.layer.shadowRadius = 15 * toastHeightUnit
    }
    
    private func layoutAction() {
        
        var actionWidth = backView.frame.width
        var actionHeight = (toastDevice.isPad ? 50 : 40) * toastHeightUnit
        var actionY = messageLabel.frame.maxY + 32 * toastHeightUnit
        
        if actions?.count == 2 {
            actionWidth = backView.frame.width * 0.5
            lineLabel.frame = CGRect(x: actionWidth, y: actionY, width: 1, height: actionHeight)
            lineLabel.frame = CGRect(x: 0, y: actionY, width: backView.frame.width, height: 1)
            actionY += 1
            actionHeight += 1
        }
        
        guard let tempActions = actions else { return }
        
        for (index, action) in tempActions.enumerated() {
            
            action.frame = CGRect(x: 0, y: actionY + actionHeight * CGFloat(index), width: actionWidth, height: actionHeight)
            action.addTarget(self, action: #selector(popAction(_:)), for: .touchUpInside)
            
            lineLabel.frame = CGRect(x: 0, y: actionY + actionHeight * CGFloat(index), width: actionWidth, height: 1)
            actionY += 1
            actionHeight -= 1
            
            switch action.popType {
            case .done:
                
                if actions?.count == 2 {
                    action.frame = CGRect(x: actionWidth + 1, y: actionY - 1, width: actionWidth - 1, height: actionHeight + 1)
                    continue
                }
                action.restorationIdentifier = "done_\(index)"
                continue
                
            case .cancel:
                
                if actions?.count == 2 {
                    action.frame = CGRect(x: 0, y: actionY - 1, width: actionWidth, height: actionHeight + 1)
                    continue
                }
                action.restorationIdentifier = "cancel_\(index)"
                continue
                
            default: continue
            }
        }
    }
    
    private func animation(_ values: Array<Any>?) {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        keyFrameAnimation.duration = 0.25
        keyFrameAnimation.values = values
        keyFrameAnimation.isCumulative = false
        keyFrameAnimation.isRemovedOnCompletion = false
        backView.layer.add(keyFrameAnimation, forKey: "Scale")
    }
    
    private func dismiss() {
        
        animation([1.2, 1, 0.8, 0.6, 0])
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.alpha = 0.1
        }) { [weak self] (finished) in
            self?.removeFromSuperview()
        }
    }
    
    @objc private func popAction(_ button: ZSPopAction) {
        dismiss()
        guard button.popAction != nil else { return }
        button.popAction!()
    }
    
    public func alert(title: String? = nil, message: String? = nil) {
        
        let backX = (toastDevice.isPad ? 220 : 45) * toastWidthUnit
        let labelX = 31 * toastWidthUnit
        let labelW = toastDevice.width - (backX + labelX) * 2
        let textSize = CGSize(width: labelW, height: CGFloat(MAXFLOAT))
        
        var messageAttribute: NSAttributedString?
        
        if message != nil {
            messageAttribute = NSAttributedString(string: message!, attributes: getMessageAttribute(message!, textMaxSize: textSize))
        }
        
        let titleHeight: CGFloat = title?.boundingRect(with: textSize, options: .usesLineFragmentOrigin, attributes: [.font : titleLabel.font ?? toastFont(0)], context: nil).size.height ?? 0
        
        let msgAttributeHeight: CGFloat = messageAttribute?.boundingRect(with: textSize, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height ?? 0
        
        let textSpace = 32 * toastHeightUnit
        
        let actionHeight = (toastDevice.isPad ? 50 : 40) * toastHeightUnit * CGFloat(actions?.count != 2 ? (actions?.count ?? 0) : 1)
        
        let space = textSpace * (titleHeight > 0 ? (msgAttributeHeight > 0 ? 2.5 : 2) : (msgAttributeHeight > 0 ? 1.5 : 1))
        
        layoutBackView(backX, backHeight: space + titleHeight + msgAttributeHeight + actionHeight)
        
        titleLabel.frame = CGRect(x: labelX, y: titleHeight > 0 ? textSpace : 0, width: labelW, height: titleHeight)
        titleLabel.text = title
        
        messageLabel.frame = CGRect(x: labelX, y: titleLabel.frame.maxY + textSpace * (msgAttributeHeight > 0 ? 0.5 : 0), width: labelW, height: msgAttributeHeight)
        messageLabel.attributedText = messageAttribute
        
        layoutToView()
        layoutAction()
        animation([0, 1, 1.1, 1])
    }
}



// MARK: - ZSSheetView
@objcMembers public class ZSSheetView: ZSPopBaseView {
    
    public var sheetSpace: CGFloat = 0
    public var sheetActionHeight: CGFloat = (toastDevice.isPad ? 120 : 40) * toastHeightUnit
    
    public func sheet(title: String? = nil) {
        
        let titleLabelX = 20 * toastWidthUnit
        let backWidth = toastDevice.width - 2 * sheetSpace
        let titleWidth = backWidth - 2 * titleLabelX
        
        let titleHeight: CGFloat = title?.boundingRect(with: CGSize(width: titleWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font : titleLabel.font ?? toastFont(0)], context: nil).size.height ?? 0
        
        let textSpace = titleHeight > 0 ? 12 * toastHeightUnit : 0
        
        var actionHeight = sheetActionHeight
        actionHeight *= CGFloat(actions?.count ?? 0)
        
        titleLabel.frame = CGRect(x: titleLabelX, y: textSpace, width: titleWidth, height: titleHeight)
        titleLabel.text = title
        
        layoutToView()
        layoutBackView(sheetSpace, backHeight: titleLabel.frame.maxY + actionHeight + 20 * toastHeightUnit)
        layoutAction()
    }
    
    
    private func layoutBackView(_ backX: CGFloat, backHeight: CGFloat) {
        
        let backH = min(backHeight, 500 * toastHeightUnit)
        let sheetH = backH + toastDevice.homeHeight + (sheetSpace > 0 ? 5 : 0) * toastHeightUnit

        backView.frame = CGRect(x: backX, y: toastDevice.height - sheetH, width: toastDevice.width - 2 * backX, height: sheetH)
        backView.contentSize = CGSize(width: 0, height: backHeight)
        backView.layer.cornerRadius = sheetSpace > 0 ? 15 * toastHeightUnit : 0
        backView.layer.shadowRadius = sheetSpace > 0 ? 15 * toastHeightUnit : 0
    }
    
    private func layoutAction() {
        
        let actionWidth = backView.frame.width
        var actionHeight = sheetActionHeight
        var actionY = titleLabel.frame.maxY + 20 * toastHeightUnit
        
        guard let tempActions = actions else { return }
        
        for (index, action) in tempActions.enumerated() {
            
            action.frame = CGRect(x: 0, y: actionY + actionHeight * CGFloat(index), width: actionWidth, height: actionHeight)
            
            if titleLabel.bounds.height > 0 &&
                index + 1 < (actions?.count ?? 0) {
                
                lineLabel.frame = CGRect(x: 0, y: actionY + actionHeight * CGFloat(index + 1), width: actionWidth, height: 1)
                actionY += 1
                actionHeight -= 1
                continue
            }
            
            action.addTarget(self, action: #selector(popAction(_:)), for: .touchUpInside)
            
            switch action.popType {
            case .done:
                
                action.restorationIdentifier = "done_\(index)"
                continue
                
            case .cancel:
                
                action.restorationIdentifier = "cancel_\(index)"
                continue
                
            default: continue
            }
        }
    }
    
    private func animation(_ values: Array<Any>?) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.alpha = 0.1
            self?.backView.frame.origin.y = toastDevice.height
        }) { [weak self] (finished) in
            self?.removeFromSuperview()
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.alpha = 0.1
            self?.backView.frame.origin.y = toastDevice.height
        }) { [weak self] (finished) in
            self?.removeFromSuperview()
        }
    }
    
    @objc private func popAction(_ button: ZSPopAction) {
        dismiss()
        guard button.popAction != nil else { return }
        button.popAction!()
    }
}




// MARK: - ZSTipView
@objcMembers open class ZSTipView: UIView {
    
    public lazy var tipLabel: UILabel = {
        
        let label = UILabel()
        label.font = toastFont(14)
        label.textAlignment = .center
        label.textColor = toastColor(254, 253, 253, 1)
        label.clipsToBounds = true
        addSubview(label)
        return label
    }()
    
    open class func layoutTipView(title: String,
                                  alpha: CGFloat,
                                  numberOfLines: Int,
                                  spaceHorizontal: CGFloat,
                                  spaceVertical: CGFloat) -> ZSTipView {
        
        let tipView = ZSTipView()
        tipView.alpha = 0
        tipView.isUserInteractionEnabled = false
        
        let titleSize: CGSize = title.boundingRect(with: CGSize(width: toastDevice.width - (20 + spaceHorizontal) * toastWidthUnit, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font : tipView.tipLabel.font ?? toastFont(0)], context: nil).size
        
        let tipSize = CGSize(width: titleSize.width, height: numberOfLines > 0 ? CGFloat(numberOfLines) * 15.0 * toastHeightUnit : titleSize.height)
        
        tipView.frame = CGRect(x: (toastDevice.width - tipSize.width - spaceHorizontal) * 0.5, y: (toastDevice.height - tipSize.height - spaceVertical) * 0.5, width: tipSize.width + spaceHorizontal, height: tipSize.height + spaceVertical)
        
        tipView.tipLabel.frame = tipView.bounds
        tipView.tipLabel.layer.cornerRadius = (tipSize.height > 15 * toastHeightUnit ? 8 * toastWidthUnit : (tipSize.height + spaceVertical) * 0.5)
        tipView.tipLabel.backgroundColor = toastColor(0, 0, 0, alpha)
        tipView.tipLabel.numberOfLines = numberOfLines
        tipView.tipLabel.text = title
        
        return tipView
    }
    
    open class func tip(title: String,
                        alpha: CGFloat = 1,
                        duration: TimeInterval = 2,
                        numberOfLines: Int = 0,
                        spaceHorizontal: CGFloat = 20,
                        spaceVertical: CGFloat = 12) {
        
        let tipView = layoutTipView(title: title, alpha: alpha, numberOfLines: numberOfLines, spaceHorizontal: spaceHorizontal, spaceVertical: spaceVertical)
        
        var controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        
        while (controller?.presentedViewController != nil && !(controller?.presentedViewController is UIAlertController)) {
            controller = controller?.presentedViewController
        }
        controller?.view.addSubview(tipView)
        
        UIView.animate(withDuration: 0.3, animations: { [weak tipView] in
            
            tipView?.alpha = 1
            
        }) { (finished) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
                
                UIView.animate(withDuration: 0.3, animations: { [weak tipView] in
                    
                    tipView?.alpha = 0
                    
                }) { [weak tipView] (finished) in
                    
                    tipView?.removeFromSuperview()
                }
            })
        }
    }
    
    open class func showTip(_ title: String) {
        self.tip(title: title)
    }
    
    open class func showTip(_ title: String,
                            duration: TimeInterval) {
        self.tip(title: title, duration: duration)
    }
    
    open class func showTip(_ title: String,
                            numberOfLines: Int) {
        self.tip(title: title, numberOfLines: numberOfLines)
    }
}




private enum toastDevice {
    
    // MARK: - 屏幕宽高、frame
    static let width: CGFloat = UIScreen.main.bounds.width
    static let height: CGFloat = UIScreen.main.bounds.height
    static let frame: CGRect = UIScreen.main.bounds
    
    // MARK: - 屏幕16:9比例系数下的宽高
    static let width16_9: CGFloat = toastDevice.height * 9.0 / 16.0
    static let height16_9: CGFloat = toastDevice.width * 16.0 / 9.0
    
    // MARK: - 关于刘海屏幕适配
    static let tabbarHeight: CGFloat = toastDevice.aboveiPhoneX ? 83 : 49
    static let homeHeight: CGFloat = toastDevice.aboveiPhoneX ? 34 : 0
    static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: - 设备类型
    static let isPhone: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    static let isPad: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)
    static let aboveiPhoneX: Bool = (Float(String(format: "%.2f", 9.0 / 19.5)) == Float(String(format: "%.2f", toastDevice.width / toastDevice.height)))
}

private let toastWidthUnit: CGFloat = toastDevice.width / (toastDevice.isPad ? 768.0 : 375.0)
private let toastHeightUnit: CGFloat = toastDevice.isPad ? toastDevice.height / 1024.0 : ( toastDevice.aboveiPhoneX ? toastDevice.height16_9 / 667.0 : toastDevice.height / 667.0 )

private func toastFont(_ font: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: font * toastHeightUnit)
}

private func toastColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}
