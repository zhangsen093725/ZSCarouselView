//
//  ZSPlayerView.swift
//  ZSPlayerView
//
//  Created by 张森 on 2019/8/16.
//  Copyright © 2019 张森. All rights reserved.
//

import UIKit
import AVKit

@objc public enum ZSPlayerStatus: Int {
    case loading = 1, playing, prepare, stop, pasue, end
}

@objc public protocol ZSPlayerViewDelegate {
    
    /// 错误状态，播放出错
    /// - Parameters:
    ///   - playerView: playerView
    ///   - error: 错误原因
    @objc optional func zs_palyer(_ playerView: ZSPlayerView, didOccur error: Error?)
    
    /// 准备状态，播放缓冲完成，可以播放，若 isAutoStartPlayEnable = false 时需要手动调用 play
    /// - Parameter playerView: playerView
    @objc optional func zs_playerReadyToPlay(_ playerView: ZSPlayerView)
    
    /// 未知状态，播放源出现未知错误
    /// - Parameter playerView: playerView
    @objc optional func zs_playerUnknown(_ playerView: ZSPlayerView)
    
    /// 结束状态，播放完毕，若 isLoopEnable = true 时将从头开始重新播放
    /// - Parameter playerView: playerView
    @objc optional func zs_playerToEnd(_ playerView: ZSPlayerView)
    
    /// 跳转状态，准备进入播放
    /// - Parameter playerView: playerView
    @objc optional func zs_playerJumped(_ playerView: ZSPlayerView)
    
    /// 闲置状态，加载中
    /// - Parameter playerView: playerView
    @objc optional func zs_playerStalle(_ playerView: ZSPlayerView)
    
    /// 当前播放时长监测
    /// - Parameters:
    ///   - playerView: playerView
    ///   - second: 当前正在播放的播放时长，单位秒
    @objc optional func zs_player(_ playerView: ZSPlayerView, currentTime second: TimeInterval)
    
    /// 播放状态改变
    /// - Parameters:
    ///   - playerView: playerView
    ///   - status: 当前播放状态
    @objc optional func zs_player(_ playerView: ZSPlayerView, didChangePaly status: ZSPlayerStatus)
    
    /// App进入后台
    /// - Parameter playerView: playerView
    @objc optional func zs_playerEnterBackground(_ playerView: ZSPlayerView)
    
    /// App进入前台
    /// - Parameter playerView: playerView
    @objc optional func zs_playerEnterForeground(_ playerView: ZSPlayerView)
}

@objcMembers public class ZSPlayerView: UIView {
    
    /// 播放地址String
    public var urlString: String?
    
    /// 播放地址URL
    public var url: URL?
    
    /// 播放代理
    public weak var delegate: ZSPlayerViewDelegate?
    
    /// 是否开启循环播放
    public var isLoopEnable: Bool = false
    
    /// 是否开启自动播放，当播放器处于preparePlay时，自动开始播放
    public var isAutoStartPlayEnable: Bool = false
    
    /// 视频填充的方式
    public var videoGravity: AVLayerVideoGravity = .resizeAspect {
        
        willSet {
            av_playerLayer.videoGravity = newValue
        }
    }
    
    /// 播放器
    public var player: AVPlayer? {
        
        return av_playerLayer.player
    }
    
    /// 播放状态
    private var _playStatus_: ZSPlayerStatus = .loading {
        didSet {
            delegate?.zs_player?(self, didChangePaly: playStatus)
        }
    }
    public var playStatus: ZSPlayerStatus {
        
        return _playStatus_
    }
    
    /// 媒体总时长
    public var totalTimeValue: TimeInterval {
        
        guard let av_playerItem = av_playerLayer.player?.currentItem else { return 0 }
        return CMTimeGetSeconds(av_playerItem.asset.duration)
    }
    
    private var isSeekToTime: Bool = false
    
    private lazy var av_playerLayer: AVPlayerLayer = {
        
        let av_playerLayer = AVPlayerLayer()
        layer.insertSublayer(av_playerLayer, at: 0)
        
        return av_playerLayer
    }()
    
    private var av_playerTimeObserver: Any?
    
    private var timer: Timer?
    private var reloadCount: Int = 5
    private var currentReloadCount: Int = 0
    private var reloadTime: TimeInterval = 0
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        av_playerLayer.frame = bounds
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addNotification()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stop()
        NotificationCenter.default.removeObserver(self)
    }
}


// TODO: 播放加载失败重试
@objc public extension ZSPlayerView {
    
    private func reloadStartTimer() {
        guard timer == nil else { return }
        
        timer = Timer.player_supportiOS_10EarlierTimer(1, repeats: true, block: { [weak self] (timer) in
            self?.reloadRun()
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func reloadStopTimer() {
        timer?.invalidate()
        timer = nil
        reloadTime = 0
        currentReloadCount = 0
    }
    
    private func reloadRun() {
        
        if Int(reloadTime) == currentReloadCount {
            play()
            reloadTime = 0
            currentReloadCount += 1
        }
        
        reloadTime += 1
        
        if currentReloadCount >= reloadCount {
            reloadStopTimer()
            let error: Error? = av_playerLayer.player?.currentItem?.error
            delegate?.zs_palyer?(self, didOccur: error == nil ? av_playerLayer.player?.error : error)
        }
    }
}


// TODO: - Player配置
@objc public extension ZSPlayerView {
    
    func preparePlay() {
        
        var playUrl: URL? = url
        
        if playUrl == nil
        {
            guard urlString != nil else {
                
                let error: NSError = NSError.init(domain: "未设置资源的url", code: 404, userInfo: [NSLocalizedDescriptionKey : "URL资源加载错误"])
                delegate?.zs_palyer?(self, didOccur: error)
                return
            }
            
            let predcate: NSPredicate = NSPredicate(format: "SELF MATCHES%@", #"http[s]{0,1}://[^\s]*"#)
            playUrl = predcate.evaluate(with: urlString) ? URL(string: urlString!) : URL(fileURLWithPath: urlString!)
        }
        
        guard playUrl != nil else { return }
        
        _playStatus_ = .loading
        av_playerLayer.player = AVPlayer(url: playUrl!)
        
        addPlayerTimeObserver()
        addPlayerItemObserver()
    }
    
    func play() {
        av_playerLayer.player?.play()
        _playStatus_ = .playing
    }
    
    func pause() {
        av_playerLayer.player?.pause()
        _playStatus_ = .pasue
    }
    
    func stop() {
        
        _playStatus_ = .stop
        
        av_playerLayer.player?.pause()
        av_playerLayer.player?.rate = 0
        av_playerLayer.player?.currentItem?.asset.cancelLoading()
        
        reloadStopTimer()
        removePlayerTimeObserver()
        removePlayerItemObserver()
        
        av_playerLayer.player = nil
    }
    
    func seek(to pos: TimeInterval, isAccurate: Bool = true) {
        isSeekToTime = true
        pause()
        let time: CMTime = CMTime(value: CMTimeValue(totalTimeValue * pos), timescale: CMTimeScale(1))
        
        if isAccurate {
            av_playerLayer.player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { [unowned self] (finished) in
                self.play()
                self.isSeekToTime = false
            })
        }else{
            av_playerLayer.player?.seek(to: time, completionHandler: { [unowned self] (finished) in
                self.play()
                self.isSeekToTime = false
            })
        }
    }
}




// TODO: - 事件观察和通知
@objc public extension ZSPlayerView {
    
    private func addPlayerItemObserver() {
        av_playerLayer.player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        av_playerLayer.player?.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        av_playerLayer.player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
    }
    
    private func removePlayerItemObserver() {
        av_playerLayer.player?.currentItem?.removeObserver(self, forKeyPath: "status")
        av_playerLayer.player?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        av_playerLayer.player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
    }
    
    private func addPlayerTimeObserver() {
        av_playerTimeObserver = av_playerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 100), queue: nil, using: { [unowned self] (time) in
            
            guard !self.isSeekToTime else { return }
            
            self.delegate?.zs_player?(self, currentTime: Double(time.value * 1) / Double(time.timescale))
        })
    }
    
    private func removePlayerTimeObserver() {
        
        if av_playerTimeObserver != nil {
            av_playerLayer.player?.removeTimeObserver(av_playerTimeObserver!)
        }
    }
    
    private func addNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(movieToEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movieJumped(notification:)), name: .AVPlayerItemTimeJumped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movieStalle(notification:)), name: .AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // TODO: 通知#selector方法
    @objc private func movieToEnd(notification: Notification) {
        
        guard av_playerLayer.player?.currentItem?.currentTime().seconds == totalTimeValue else { return }
        
        _playStatus_ = .end
        
        delegate?.zs_playerToEnd?(self)
        
        isLoopEnable ? seek(to: 0) : nil
    }
    
    @objc private func movieJumped(notification: Notification) {
        delegate?.zs_playerJumped?(self)
    }
    
    @objc private func movieStalle(notification: Notification) {
        _playStatus_ = .loading
        delegate?.zs_playerStalle?(self)
    }
    
    @objc private func enterBackground(notification: Notification) {
        
        delegate?.zs_playerEnterBackground?(self)
    }
    
    @objc private func enterForeground(notification: Notification) {
        
        delegate?.zs_playerEnterForeground?(self)
    }
    
    
    // TODO: 观察者实现方法
    private func observeStatus() {
        
        guard let status: AVPlayerItem.Status = av_playerLayer.player?.currentItem?.status else { return }
        
        switch status {
            
        case .readyToPlay:
            _playStatus_ = .prepare
            
            reloadStopTimer()
            
            delegate?.zs_playerReadyToPlay?(self)
            
            isAutoStartPlayEnable ? play() : nil
            
            break
            
        case .unknown:
            delegate?.zs_playerUnknown?(self)
            break
            
        case .failed:
            reloadStartTimer()
            break
            
        default:
            break
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath {
        case "status":
            observeStatus()
            break
            
        case "loadedTimeRanges":
            
            break
            
        case "playbackBufferEmpty":
            
            break
            
        default:
            break
        }
    }
}


// MARK: - 定时器，失败自动重新加载
private extension Timer {
    
    class func player_supportiOS_10EarlierTimer(_ interval: TimeInterval, repeats: Bool, block: @escaping (_ timer: Timer) -> Void) -> Timer {
        
        if #available(iOS 10.0, *) {
            return Timer.init(timeInterval: interval, repeats: repeats, block: block)
        } else {
            return Timer.init(timeInterval: interval, target: self, selector: #selector(player_runTimer(_:)), userInfo: block, repeats: repeats)
        }
    }
    
    @objc private class func player_runTimer(_ timer: Timer) -> Void {
        
        guard let block: ((Timer) -> Void) = timer.userInfo as? ((Timer) -> Void) else { return }
        
        block(timer)
    }
}
