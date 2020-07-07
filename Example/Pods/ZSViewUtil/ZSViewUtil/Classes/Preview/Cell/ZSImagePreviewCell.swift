//
//  ZSImagePreviewCell.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/4/8.
//

import UIKit

@objcMembers open class ZSImagePreviewCell: ZSMediaPreviewCell {
    
    public lazy var imageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.addObserver(self, forKeyPath: "image", options: .new, context: nil)
        zoomScrollView.addSubview(imageView)
        return imageView
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let width = zoomScrollView.frame.width
        
        let height = imageView.image == nil ? contentView.frame.height : (width / imageView.image!.size.width * imageView.image!.size.height)
        
        let x = abs(width - zoomScrollView.frame.width) * 0.5
        let y = (height - zoomScrollView.frame.height) > 0 ? 0 : abs(height - zoomScrollView.frame.height) * 0.5
        
        imageView.frame = CGRect(x: x, y: y, width: width, height: height)
        zoomScrollView.contentSize = CGSize(width: width, height: height)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        customLoadingView?.isHidden = (imageView.image != nil)
    }
    
    override func getCustomLoadingView() {
        super.getCustomLoadingView()
        customLoadingView?.isHidden = (imageView.image != nil)
    }
    
    deinit {
        imageView.removeObserver(self, forKeyPath: "image")
    }
}


@objc extension ZSImagePreviewCell {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "image" {
            customLoadingView?.isHidden = true
            layoutSubviews()
        }
    }
}



@objc extension ZSImagePreviewCell {

    open override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
