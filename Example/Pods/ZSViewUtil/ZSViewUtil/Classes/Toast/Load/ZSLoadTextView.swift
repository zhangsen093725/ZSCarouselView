//
//  ZSLoadTextView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/1/15.
//

import UIKit

@objcMembers open class ZSLoadTextView: UIView {
    
    public lazy var loadView: ZSLoadingView = {
        
        let loadView = ZSLoadingView()
        loadView.backgroundColor = .clear
        addSubview(loadView)
        return loadView
    }()
    
    public lazy var textLabel: UILabel = {
        
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.textColor = .white
        textLabel.font = .systemFont(ofSize: 15)
        addSubview(textLabel)
        return textLabel
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.frame = CGRect(x: 0, y: bounds.height - 35, width: bounds.width, height: 20)
        loadView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: textLabel.frame.origin.y)
    }
    
    open func configLoadView() {
        
        textLabel.textAlignment = .center
        textLabel.textColor = .white
        textLabel.font = .systemFont(ofSize: 15)
        layer.cornerRadius = 8
        clipsToBounds = true
    }
}
