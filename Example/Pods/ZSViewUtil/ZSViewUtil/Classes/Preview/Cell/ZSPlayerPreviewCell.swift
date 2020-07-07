//
//  ZSPlayerPreviewCell.swift
//  Kingfisher
//
//  Created by 张森 on 2020/4/14.
//

import UIKit

@objcMembers open class ZSPlayerPreviewCell: ZSMediaPreviewCell, ZSPlayerViewDelegate {
    
    public var isPlayButtonHidden: Bool = false {
        didSet {
            playButton.isHidden = isPlayButtonHidden
        }
    }
    
    public lazy var playerView: ZSPlayerView = {
        
        let playerView = ZSPlayerView()
        playerView.backgroundColor = .clear
        playerView.delegate = self
        playerView.isShouldAutoplay = true
        zoomScrollView.addSubview(playerView)
        return playerView
    }()
    
    public lazy var playButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.tintColor = .clear
        button.contentMode = .scaleAspectFit
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        
        if let resouce = Bundle(for: Self.classForCoder()).url(forResource: "ZSViewUtil", withExtension: "bundle") {
            let image = UIImage(named: "ic_playerPreview_play", in: Bundle(url: resouce), compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
            button.setBackgroundImage(image, for: .normal)
        }
       
        button.addTarget(self, action: #selector(playButtonAction(_:)), for: .touchUpInside)
        playerView.addSubview(button)
        return button
    }()
    
    public var zs_play: (() -> Void)? {
        return { [weak self] in
            self?.play()
        }
    }
    
    public var zs_pause: (() -> Void)? {
        return { [weak self] in
            self?.playerView.pause()
        }
    }
    
    public var zs_seek: ((_ pos: TimeInterval) -> Void)? {
        return { [weak self] pos in
            self?.playerView.seek(to: pos)
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        playerView.frame = zoomScrollView.bounds
        zoomScrollView.contentSize = .zero
        playButton.frame = CGRect(x: (playerView.frame.width - 75) * 0.5, y: (playerView.frame.height - 75) * 0.5, width: 75, height: 75)
        customLoadingView?.frame = playButton.frame
    }
    
    override func getCustomLoadingView() {
        super.getCustomLoadingView()
        customLoadingView?.isHidden = true
    }
    
    open func stop() {
        
        playButton.isHidden = isPlayButtonHidden
        playButton.alpha = 1
        customLoadingView?.isHidden = true
        customLoadingView?.alpha = 0
        
        playerView.stop()
    }
    
    @objc func playButtonAction(_ sender: UIButton) {
        
        play()
        
        sender.alpha = 1
        customLoadingView?.alpha = 0
        customLoadingView?.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            sender.alpha = 0
            self?.customLoadingView?.alpha = 1
        }) { (finished) in
            
        }
    }
    
    func play() {
        
        if playerView.playStatus == .pasue {
            playerView.play()
            return
        }
        
        guard playerView.playStatus != .playing else { return }
        
        playerView.preparePlay()
    }
}




@objc extension ZSPlayerPreviewCell {
    
    open func zs_movieFailed(_ playerView: ZSPlayerView, error: Error?) {
        
        let error: NSError = NSError.init(domain: NSURLErrorDomain, code: 10501, userInfo: [NSLocalizedDescriptionKey : "\(String(describing: error?.localizedDescription))"])
        delegate?.zs_mediaPreviewCellMediaLoadFail(error)
    }
    
    open func zs_movieUnknown(_ playerView: ZSPlayerView) {
        
        let error: NSError = NSError.init(domain: NSURLErrorDomain, code: 10502, userInfo: [NSLocalizedDescriptionKey : "URL资源加载未知错误"])
        delegate?.zs_mediaPreviewCellMediaLoadFail(error)
    }
    
    open func zs_movieCurrentTime(_ playerView: ZSPlayerView, second: TimeInterval) {
        
        delegate?.zs_mediaPreviewCellMediaDidiChangePlayTime(second: second)
    }
    
    open func zs_movieChangePalyStatus(_ playerView: ZSPlayerView, status: ZSPlayerStatus) {
        
        delegate?.zs_mediaPreviewCellMediaDidChangePlay(status: status)
        
        customLoadingView?.isHidden = status != .loading
        
        guard isPlayButtonHidden == false else { return }
        
        if status == .end {
            playerView.seek(to: 0)
        }
        
        switch status {
        case .end, .stop, .pasue:
            playButton.isHidden = false
            break
        default:
            playButton.isHidden = true
            break
        }
    }
}
