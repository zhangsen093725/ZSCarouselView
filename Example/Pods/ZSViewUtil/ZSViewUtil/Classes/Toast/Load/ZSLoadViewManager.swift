//
//  ZSLoadViewManager.swift
//  Kingfisher
//
//  Created by 张森 on 2020/4/15.
//

import UIKit

@objcMembers open class ZSLoadViewManager: NSObject {

    private static let `defult` = ZSLoadViewManager()
    
    private lazy var loadingView: ZSLoadingView  = {
        
        let loadingView = ZSLoadingView()
        return loadingView
    }()
    
    open func startAnimation(to view: UIView? = nil,
                                size: CGSize,
                                backgroundColor: UIColor) {

        if view == nil {
            
            loadingView.frame = CGRect(x: (UIScreen.main.bounds.width - size.width) * 0.5, y: (UIScreen.main.bounds.height - size.height) * 0.5, width: size.width, height: size.height)
            
            var controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
            
            while (controller?.presentedViewController != nil && !(controller?.presentedViewController is UIAlertController)) {
                controller = controller?.presentedViewController
            }
            controller?.view.addSubview(loadingView)
            
        }else{
            
            let viewWidth = view!.frame.width
            let viewHeight = view!.frame.height
            
            let width = viewWidth > 0 ? size.width : 0
            let height = viewHeight > 0 ? size.width : 0
            
            loadingView.frame = CGRect(x: (viewWidth - width) * 0.5, y: (viewHeight - height) * 0.5, width: width, height: height)
            
            view?.addSubview(loadingView)
        }
        
        loadingView.alpha = 1
        loadingView.backgroundColor = backgroundColor
        loadingView.configLoadView()
//        loadingView.startAnimation()
    }
    
    open func stopAnimation() {
        
        loadingView.stopAnimation()
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.loadingView.alpha = 0
        }) { [weak self] (finished) in
            self?.loadingView.removeFromSuperview()
        }
    }
    
    @discardableResult
    public class func startAnimation(
        to view: UIView? = nil,
        size: CGSize = CGSize(width: 80, height: 80),
        backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7)) -> ZSLoadViewManager {
        
        ZSLoadViewManager.defult.startAnimation(to: view, size: size, backgroundColor: backgroundColor)
        return ZSLoadViewManager.defult
    }
    
    public class func stopAnimation() {
        ZSLoadViewManager.defult.stopAnimation()
    }
}
