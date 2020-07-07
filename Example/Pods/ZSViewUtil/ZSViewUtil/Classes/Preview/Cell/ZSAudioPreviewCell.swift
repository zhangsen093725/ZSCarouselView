//
//  ZSAudioPreviewCell.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/4/8.
//

import UIKit

@objcMembers open class ZSAudioPreviewCell: ZSPlayerPreviewCell {
    
    public lazy var animationLayer: ZSAudioAnimationLayer = {
        
        let replicatorLayer = ZSAudioAnimationLayer()
        
        // 设置复制层里面包含子层的个数
        replicatorLayer.instanceCount = 5
        
        // 设置子层相对于前一个层的偏移量
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(20, 0, 0)
        
        // 设置子层相对于前一个层的延迟时间
        replicatorLayer.instanceDelay = 0.1

        playerView.layer.insertSublayer(replicatorLayer, at: 0)
        return replicatorLayer
    }()
    
    public lazy var textLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "纯音频"
        label.font = .boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        playerView.insertSubview(label, at: 0)
        return label
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        animationLayer.frame = CGRect(x: (playerView.frame.width - 100) * 0.5, y: (playerView.frame.height - 120) * 0.5, width: 100, height: 120)
        textLabel.frame = CGRect(x: 0, y: animationLayer.frame.maxY + 5, width: playerView.frame.width, height: 20)
    }
}



@objc extension ZSAudioPreviewCell {
    
    open override func zs_movieChangePalyStatus(_ playerView: ZSPlayerView, status: ZSPlayerStatus) {
        
        super.zs_movieChangePalyStatus(playerView, status: status)
        
        switch status {
        case .playing:
            animationLayer.beginAnimation()
        default:
            animationLayer.endAnimation()
        }
    }
}





@objcMembers public class ZSAudioAnimationLayer: CAReplicatorLayer {
    
    lazy var columnarLayer: CALayer = {
        
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.masksToBounds = true
        
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        addSublayer(layer)
        return layer
    }()
    
    override public func layoutSublayers() {
        super.layoutSublayers()
        columnarLayer.frame = CGRect(x: 0, y: (frame.height - 2) * 0.5, width: 15, height: 2)
    }
    
    open func beginAnimation() {
        let basicAnimation = CABasicAnimation.init(keyPath: "transform.scale.y")
        basicAnimation.toValue = 60
        basicAnimation.duration = 0.25
        // 动画结束时是否执行逆动画
        basicAnimation.autoreverses = true
        basicAnimation.repeatCount = MAXFLOAT
        basicAnimation.isRemovedOnCompletion = false
        
        columnarLayer.add(basicAnimation, forKey: "scale")
    }
    
    open func endAnimation() {
        columnarLayer.removeAllAnimations()
    }
}
