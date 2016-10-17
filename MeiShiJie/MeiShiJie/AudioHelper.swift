//
//  AudioHelper.swift
//  MeiShiJie
//
//  Created by 李童 on 2016/10/13.
//  Copyright © 2016年 李童. All rights reserved.
//

import UIKit
import AVFoundation

/// 代理方法
@objc protocol AudioHelperDelegate{
    
    /// 播放状态
    ///
    /// - parameter item:   当前播放的Item
    /// - parameter status: 当前Item的状态
    @objc optional func player(current item:AVPlayerItem,status:AVPlayerItemStatus)
    
    /// 当前Item播放结束
    ///
    /// - parameter item: 当前播放的Item
    @objc optional func didPlayToEnd(with item:AVPlayerItem)
}
class AudioHelper: NSObject {
    
    /// 播放资源，本地或远程资源
    var source:[URL] = []
    
    /// 当前播放队列的Item
    private var songItems:[AVPlayerItem] = []
    
    /// 当前播放进度，0-1
    var progress:Float = 0
    
    /// 用来保存进度回调闭包
    private var progressBlock:((_ progress:Float)->Swift.Void)?
    
    /// 设置进度回调闭包
    ///
    /// - parameter progress: 回调闭包
    func progressBlock(progress:((_ progress:Float)->Swift.Void)?){
        self.progressBlock = progress
    }
    
    
    /// 播发队列对象
    var queuePlayer:AVQueuePlayer!
    
    /// 播放进度观察者
    private var timeObserver:Any!
    
    /// 是否开启循环播放，默认不开启
    var isLoop:Bool = false
    
    /// 记录当前item的播放状态
    private var itemStatus:AVPlayerItemStatus!
    
    /// 返回当前item的播放状态
    var curretItemStatus: AVPlayerItemStatus{
        return self.itemStatus
    }
    
    /// 代理对象
    weak var delegate:AudioHelperDelegate?

    override init() {
        super.init()
    }
    
    /// 初始化方法
    ///
    /// - parameter source: 传入资源数组
    ///
    /// - returns: <#return value description#>
    convenience init(source:[URL]) {
        self.init()
        self.source = source
        songItems = changeToItem(source: source)
        initQueuePlayer(items: songItems)

    }
    
    /// 初始化播放对象
    ///
    /// - parameter items: 传入当前Item数组
    ///
    /// - returns: <#return value description#>
    private func initQueuePlayer(items:[AVPlayerItem]){
        if queuePlayer != nil{
            removeTimeObserver()
            queuePlayer = nil
        }
        queuePlayer = AVQueuePlayer(items:items )
        timeObserver = addTimeObserver()
    }
    
    /// 当前播放结束的通知回调
    ///
    /// - parameter notific: <#notific description#>
    func playDidEnd(notific:Notification){
        if let item = notific.object as? AVPlayerItem{
            delegate?.didPlayToEnd?(with: item)
        }
        if let currentItem = queuePlayer.currentItem{
            if let assest = currentItem.asset as? AVURLAsset{
                if assest.url == source.last{
                    playNewSource(new: source)
                }
            }
        }
    }
    
    /// 播放
    func play() -> Void {
        queuePlayer.play()
    }
    
    /// 暂停
    func pause() -> Void {
        queuePlayer.pause()
    }
    
    /// 下一首
    func next()->Void{
        queuePlayer.advanceToNextItem()
        if isLoop == true{
            if queuePlayer.currentItem == nil{
                playNewSource(new: source)
            }
        }
    }
    
    /// 上一首
    func prev()->Void{
        if let currentItem = queuePlayer.currentItem{
            if let assest = currentItem.asset as? AVURLAsset{
                if let currentIndex = source.index(of: assest.url){
                    if currentIndex - 1 >= 0{
                        let prevIndex = currentIndex - 1
                        let newSource:[URL] = Array(source[prevIndex..<source.count])
                        self.playNewSource(new: newSource)
                    }
                }
            }
            
        }else{//播放队列已空
            if let last = source.last{
                self.playNewSource(new: [last])
            }
        }
    }
    
    /// 跳转到指定进度
    ///
    /// - parameter progress: 0-1
    func seekToProgerss(_ progress:Float){
        if let total = self.queuePlayer.currentItem?.duration.seconds{
            removeTimeObserver()
            let seekTime = total * Double(progress)
            self.queuePlayer.currentItem?.seek(to: CMTimeMake(Int64(seekTime), Int32(1.0)), completionHandler: { [unowned self](isComple) in
                if isComple {
                    self.timeObserver = self.addTimeObserver()
                }
                })
            
        }
    }
    
    /// 根据新的资源数组来初始化queuePlayer
    ///
    /// - parameter source: 资源数组
    private func playNewSource(new source:[URL]){
        self.removeItemObserver()
        songItems = changeToItem(source: source)
        self.initQueuePlayer(items: songItems)
        self.play()
    }
    
    /// 将URL转化为Item
    ///
    /// - parameter source: 资源
    ///
    /// - returns: 播放对象
    private func changeToItem(source:[URL])->[AVPlayerItem]{
        return source.map({ (model) -> AVPlayerItem in
            var songItem:AVPlayerItem!
            let asset = AVAsset(url: model)
            songItem = AVPlayerItem(asset: asset)
            songItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playDidEnd(notific:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: songItem)
            return songItem
        })
    }
    /// 观察者回调，在这观察当前Item的状态变化
    ///
    /// - parameter keyPath: <#keyPath description#>
    /// - parameter object:  <#object description#>
    /// - parameter change:  <#change description#>
    /// - parameter context: <#context description#>
    internal override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status"{
            if let item = object as? AVPlayerItem{
                itemStatus = item.status
                switch item.status {
                case .unknown:
                    delegate?.player?(current: item, status: item.status)
                case .readyToPlay:
                    delegate?.player?(current: item, status: item.status)
                case .failed:
                    delegate?.player?(current: item, status: item.status)
                }
            }
            
            
        }
    }
    
    /// 移除item的观察者
    func removeItemObserver(){
        for item in songItems{
            item.removeObserver(self, forKeyPath: "status")
        }
    }
    
    /// 添加时间进度的观察者
    ///
    /// - returns: 返回观察者对象
    func addTimeObserver()->Any{
        return queuePlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(Int64(1.0), Int32(1.0)), queue: DispatchQueue.main) { [unowned self](time) in
            let current = time.seconds
            if let total = self.queuePlayer.currentItem?.duration.seconds{
                if total.isNaN == false{
                    self.progress = Float(current / total)
                    self.progressBlock?(self.progress)
                }
            }
        }
    }
    
    /// 移除时间进度观察者
    func removeTimeObserver(){
        if timeObserver != nil{
            queuePlayer.removeTimeObserver(timeObserver)
            timeObserver = nil
        }
    }
    deinit {
        removeTimeObserver()
        removeItemObserver()
    }
}
