//
//  ZSUIBaseUtil.swift
//  Pods-ZSBaseUtil_Example
//
//  Created by 张森 on 2019/8/13.
//

import UIKit

// MARK: - UITableViewCell扩展
@objc public extension UITableViewCell {
    
    class var identifier: String {
        return NSStringFromClass(self)
    }
}


// MARK: - UICollectionViewCell扩展
@objc public extension UICollectionViewCell {
    
    class var identifier: String {
        return NSStringFromClass(self)
    }
}


// MARK: - UILabel扩展
@objc extension UILabel {
    
    public var attributedTextTail: NSAttributedString? {
        set {
            attributedText = newValue
            lineBreakMode = .byTruncatingTail
        }
        get {
            return attributedText
        }
    }
}


// MARK: - UITextView扩展
@objc extension UITextView {
    
    public var attributedTextTail: NSAttributedString? {
        set {
            attributedText = newValue
            textContainer.lineBreakMode = .byTruncatingTail
        }
        get {
            return attributedText
        }
    }
}


// MARK: - UIViewController扩展
@objc extension UIViewController {
    
    public func presentRootController(animated: Bool = false,
                                      complete: (()->Void)? = nil) {
        
        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
        {
            presentedViewController.present(self, animated: animated, completion: complete)
        }
        else
        {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: animated, completion: complete)
        }
    }
    
    public func presentViewController(_ controller: UIViewController,
                                      animated: Bool = true,
                                      modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
                                      completion: (() -> Void)? = nil) {
        
        controller.modalPresentationStyle = modalPresentationStyle
        self.present(controller, animated: animated, completion: completion)
        
    }
}


// MARK: - UIView扩展
@objc public extension UIView {
    
    class var zs_currentControllerView: UIView? {
        
        var controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        
        while (controller?.presentedViewController != nil && !(controller?.presentedViewController is UIAlertController)) {
            controller = controller?.presentedViewController
        }
        return controller?.view
    }
    
    func addSubviewToControllerView() {
        UIView.zs_currentControllerView?.addSubview(self)
    }
    
    func addSubviewToRootControllerView() {
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(self)
    }
}
