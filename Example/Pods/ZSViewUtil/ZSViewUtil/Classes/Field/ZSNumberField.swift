//
//  JDNumberFiled.swift
//  JadeKing
//
//  Created by 张森 on 2019/10/29.
//  Copyright © 2019 张森. All rights reserved.
//

import Foundation

@objcMembers open class ZSNumberField: ZSTextField {
    
    open lazy var zs_inputAccessoryView: ZSInputAccessoryView = {
        
        let inputAccessoryView = ZSInputAccessoryView()
        inputAccessoryView.backgroundColor = UIColor.white.filed_dark(UIColor(red: 82 / 255, green: 82 / 255, blue: 82 / 255, alpha: 1))
        inputAccessoryView.cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        inputAccessoryView.doneBtn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        inputAccessoryView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        return inputAccessoryView
    }()
    
    open override func zs_configField() -> UITextField {
        
        let _textFiled_ = super.zs_configField()
        _textFiled_.keyboardType = .numberPad
        _textFiled_.inputAccessoryView = zs_inputAccessoryView
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
    
    open override func zs_textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.zs_textFieldDidEndEditing(self)
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
