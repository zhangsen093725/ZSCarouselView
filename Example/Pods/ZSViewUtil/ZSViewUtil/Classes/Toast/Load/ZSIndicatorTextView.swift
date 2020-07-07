//
//  ZSIndicatorTextView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/1/15.
//

import UIKit

@objcMembers open class ZSIndicatorTextView: UIView {

    public lazy var loadView: UIActivityIndicatorView = {
        
        let loadView = UIActivityIndicatorView()
        addSubview(loadView)
        return loadView
    }()
    
    public lazy var textLabel: UILabel = {
        
        let textLabel = UILabel()
        addSubview(textLabel)
        return textLabel
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = CGRect(x: 0, y: bounds.height - 35, width: bounds.width, height: 20)
        loadView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: textLabel.frame.origin.y)
    }
    
    open func configLoadView() {
        
        loadView.style = .whiteLarge
        
        textLabel.textAlignment = .center
        textLabel.textColor = .white
        textLabel.font = .systemFont(ofSize: 15)
        layer.cornerRadius = 8
        clipsToBounds = true
    }
}
