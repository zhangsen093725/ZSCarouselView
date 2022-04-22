//
//  ZSScrollCarouseCell.swift
//  Pods-ZSCarouselView_Example
//
//  Created by Josh on 2020/7/3.
//

import UIKit

@objcMembers open class ZSScrollCarouselCell: UICollectionViewCell {
 
    open class var zs_identifier: String { return NSStringFromClass(self) }
    
    var minimumLineSpacing: CGFloat = 0
    var minimumInteritemSpacing: CGFloat = 0
    
    public lazy var imageView: UIImageView = {
       
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        return imageView
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width - minimumInteritemSpacing, height: bounds.height - minimumLineSpacing)
        imageView.frame = contentView.bounds
    }
}
