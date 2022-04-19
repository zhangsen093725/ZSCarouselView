//
//  JDNumberFiled.swift
//  JadeKing
//
//  Created by 张森 on 2019/10/29.
//  Copyright © 2019 张森. All rights reserved.
//

import UIKit

@objcMembers open class ZSNumberField: ZSTextField {
    
    open override func zs_configField() -> UITextField {
        
        let _textFiled_ = super.zs_configField()
        _textFiled_.keyboardType = .numberPad
        return _textFiled_
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = bounds
    }
    
    open override func zs_textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "\n" {
            
            endEditing(true)
            
            return false
        }
        
        if string == "" {
            
            return true
        }
        
        return delegate?.zs_textField?(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    // TODO: InputAccessoryAction
    @objc private func cancelAction() {
        text = ""
    }
    
    @objc private func doneAction() {
        endEditing(true)
    }
}

fileprivate extension UIColor {
    
    func filed_dark(_ color: UIColor) -> UIColor {
        
        if #available(iOS 13.0, *) {
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
        } else {
            return self
        }
    }
}
