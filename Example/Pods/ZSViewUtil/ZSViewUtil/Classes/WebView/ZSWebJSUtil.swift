//
//  ZSWebJSUtil.swift
//  test
//
//  Created by 张森 on 2019/10/9.
//  Copyright © 2019 张森. All rights reserved.
//

import WebKit

@objc public protocol ZSWebJSToolDelegate {
    func zs_userContentController(_ function: String, params: [String: Any])
    func zs_userContentController(_ function: String, array: [Any])
    func zs_userContentController(_ function: String, content: String)
    func zs_userContentController(_ function: String, number: NSNumber)
    func zs_userContentController(_ function: String)
    @objc optional func zs_userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
}

@objcMembers public class ZSWebJSTool: NSObject, WKScriptMessageHandler {
    
    public class func evaluateJavaScriptFunction(_ function: String, webView: WKWebView?, params: String) {
        
        webView?.evaluateJavaScript(function + "(" + params + ")") { (obj, error) in
            print("-----------evaluateJavaScript Begin-------------")
            print("function: \(function)")
            print("params:  \(params)")
            print(obj ?? "null")
            print(error ?? "无错误信息")
            print("-----------evaluateJavaScript End-------------")
        }
    }
    
    public weak var delegate: ZSWebJSToolDelegate?
    
    public var isAlreadyFuncs: Bool = false
    
    public func addScriptMessageHandler(_ webView: WKWebView, funcNames: [String]) {
        
        isAlreadyFuncs = true
        
        let userContentController = webView.configuration.userContentController
        
        for funcName in funcNames {
            userContentController.add(self, name: funcName)
        }
    }
    
    public func removeScriptMessageHandler(_ webView: WKWebView, funcNames: [String]) {
        
        isAlreadyFuncs = false
        
        let userContentController = webView.configuration.userContentController
        
        for funcName in funcNames {
            userContentController.removeScriptMessageHandler(forName: funcName)
        }
    }
    
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.zs_userContentController?(userContentController, didReceive: message)
        
        if let array = message.body as? [Any] {
            delegate?.zs_userContentController(message.name, array: array)
            return
        }
        
        if let params = message.body as? [String: Any] {
            delegate?.zs_userContentController(message.name, params: params)
            return
        }
        
        if let number = message.body as? NSNumber {
            delegate?.zs_userContentController(message.name, number: number)
            return
        }
        
        if let content = message.body as? String {
            
            let data = Data(content.utf8)
            
            if let object = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                
                if let params = object as? [String : Any] {
                    delegate?.zs_userContentController(message.name, params: params)
                    return
                }
                
                if let array = object as? [Any] {
                    delegate?.zs_userContentController(message.name, array: array)
                    return
                }
            }
            delegate?.zs_userContentController(message.name, content: content)
            return
        }
        
        delegate?.zs_userContentController(message.name)
    }
}
