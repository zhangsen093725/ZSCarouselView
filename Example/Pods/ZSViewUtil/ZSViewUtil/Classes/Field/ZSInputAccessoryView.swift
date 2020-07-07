//
//  ZSInputAccessoryView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/1/15.
//

import UIKit

@objcMembers open class ZSInputAccessoryView: UIView {
    
    public lazy var cancelBtn: UIButton = {
        
        let cancelBtn = createBtn()
        cancelBtn.setTitle("撤销", for: .normal)
        return cancelBtn
    }()
    
    public lazy var doneBtn: UIButton = {
        
        let doneBtn = createBtn()
        doneBtn.setTitle("完成", for: .normal)
        return doneBtn
    }()
    
    private func createBtn() -> UIButton {
        
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(UIColor.systemBlue.filed_dark(UIColor(red: 82 / 255, green: 82 / 255, blue: 82 / 255, alpha: 1)), for: .normal)
        addSubview(button)
        return button
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        cancelBtn.frame = CGRect(x: 8, y: 0, width: 60, height: bounds.height)
        doneBtn.frame = CGRect(x: bounds.width - 68, y: 0, width: 60, height: bounds.height)
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
