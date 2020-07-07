//
//  ZSPhoneField.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/1/15.
//

import UIKit

@objcMembers open class ZSPhoneField: ZSNumberField {
    
    public var tempText: String = ""
    
    func shouldDeleteBlank(range: NSRange, fieldString: String) -> Bool {
    
        guard range.location > 0 else { return false }
        
        guard let spaceRange = Range(range, in: fieldString) else { return false }
        
        if String(fieldString[spaceRange]) == " " {
            return true
        }
        
        let space = NSRange(location: range.location - 1, length: 1)
                   
        guard let _spaceRange_ = Range(space, in: fieldString) else { return false }
                   
        if String(fieldString[_spaceRange_]) == " " {
            return true
        }
        
        return false
    }
    
    func shouldInsertBlank(range: NSRange, fieldString: String) -> Bool {
        
        guard range.location > 0 else { return false }
        
        let space = NSRange(location: range.location + range.length - 1, length: 1)
        
        guard let spaceRange = Range(space, in: fieldString) else { return false }
        
        if String(fieldString[spaceRange]) == " " {
            return true
        }
        
        return false
    }
    
    func zs_phoneText(from newValue: String) -> String {
        
        var value = newValue
        
        if value.count > 3 {
            value.insert(" ", at: value.index(value.startIndex, offsetBy: 3))
        }
        
        if value.count > 7 {
            value.insert(" ", at: value.index(value.startIndex, offsetBy: 8))
        }
        
        if value.count > 13 {
            
            let endIndex = value.index(value.startIndex, offsetBy: 13)
            
            value = String(value[..<endIndex])
        }
        
        return value
        
    }
    
    open override func zs_filedText(from newValue: String) -> String {
        
        let text = zs_phoneText(from: super.zs_filedText(from: newValue))
        
        tempText = zs_phoneText(from: newValue)
        
        return text
    }
    
    public override func zs_textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let _ = delegate?.zs_textField?(self, shouldChangeCharactersIn: range, replacementString: string)

        if string == "\n" {
            
            endEditing(true)
            
            return false
        }
        
        var text: String = String(tempText)
        
        if string == "" {

            if shouldDeleteBlank(range: range, fieldString: text) {
                
                guard let subRange = Range(NSRange(location: range.location - 1, length: range.length + 1), in: text) else { return true }

                text.removeSubrange(subRange)
                self.text = text.replacingOccurrences(of: " ", with: "")
                
                let start = textField.position(from: textField.beginningOfDocument, offset: range.location - 1)
                textField.selectedTextRange = textField.textRange(from: start!, to: start!)
                
                return false
            }
        }
        
        if tempText.count >= 13 && string != "" { return false }
        
        if let indexRange = Range(range, in: text) {
            text.replaceSubrange(indexRange, with: string)
        } else {
            text.append(string)
        }
        
        self.text = text.replacingOccurrences(of: " ", with: "")
        
        let length = range.location + string.count
        
        let offset = shouldInsertBlank(range: NSRange(location: range.location, length: string.count), fieldString: textField.text!) ? 1 : 0

        let start = textField.position(from: textField.beginningOfDocument, offset: offset + (length > 13 ? 13 : length))
        textField.selectedTextRange = textField.textRange(from: start!, to: start!)
        
        return false
    }
}
