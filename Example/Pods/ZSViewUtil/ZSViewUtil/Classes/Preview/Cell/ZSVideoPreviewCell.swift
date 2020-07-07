//
//  ZSVideoPreviewCell.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/4/8.
//

import UIKit

@objcMembers open class ZSVideoPreviewCell: ZSPlayerPreviewCell {
    
    public var isZoomEnable: Bool = false
    
    public lazy var imageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        playerView.insertSubview(imageView, at: 0)
        return imageView
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = playerView.bounds
    }
}


@objc extension ZSVideoPreviewCell {

    open override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return isZoomEnable ? playerView : nil
    }
}



@objc extension ZSVideoPreviewCell {
    
    open override func zs_movieChangePalyStatus(_ playerView: ZSPlayerView, status: ZSPlayerStatus) {
        
        super.zs_movieChangePalyStatus(playerView, status: status)
        
        if status == .playing {
            imageView.isHidden = true
        }
        
        if status == .stop {
            imageView.isHidden = false
        }
    }
}

