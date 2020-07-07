//
//  ZSTabCell.swift
//  JadeToB
//
//  Created by 张森 on 2020/1/13.
//  Copyright © 2020 张森. All rights reserved.
//

import UIKit

@objcMembers open class ZSTabTextCell: ZSTabCell {
    
    public lazy var titleLabel: UILabel = {
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center

        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 16)
        
        titleLabel.text = "标题"
        
        contentView.addSubview(titleLabel)
        return titleLabel
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = contentView.bounds
    }
}
