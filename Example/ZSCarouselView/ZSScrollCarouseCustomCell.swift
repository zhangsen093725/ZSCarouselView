//
//  ZSScrollCarouseCustomCell.swift
//  ZSCarouselView_Example
//
//  Created by Josh on 2020/7/7.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ZSCarouselView

class ZSScrollCarouseCustomCell: ZSScrollCarouseCell {
    
    public lazy var label: UILabel = {
       
        let label = UILabel()
        label.textAlignment = .center
        contentView.addSubview(label)
        return label
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
}
