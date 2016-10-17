# <a name:"head">AudioHelper</a>

AudioHelper是一个简单的播放器，可以播放本地和远程的音频资源。

***

### 功能介绍
- 使用简单，只需传入资源地址（本地或者远程URL）
- 提供上一首和下一首切换功能
- 提供循环播放功能
- 提供播放进度回调
- 跳转到指定位置功能

***

### 使用方法
- 下载AudioHelper.swift文件
- 导入到项目中
- 在需要的地方导入AVFoundation

***

### 使用说明
- 初始化
``` swift
	import AVFoundation
	//初始化播放
    helper = AudioHelper(source: source)
    //打开循环播放
    helper.isLoop = true
    //设置播放进度回调
    helper.progressBlock(progress: updateProgress)
    //设置代理对下岗
    helper.delegate = self

```
- 设置播放回调
``` swift

	func updateProgress(value:Float)->Swift.Void{
        self.progress.value = value
    }

```
- 切换歌曲
``` swift

	//下一首
    @IBAction func next()->Void{
        helper.next()
    }
    //上一首
    @IBAction func prev()->Void{
        helper.prev()
    }

```
- 跳转到指定位置
``` swift

	//UISlider的valueChanged事件，请把UISlider的isContinuous属性设为false
    @IBAction func seekToProgerss(){
        helper.seekToProgerss(self.progress.value)
        helper.progressBlock(progress: updateProgress)
    }
    //UISlider的touchDown事件，需要在touchDown事件中将进度回调方法置nil，不然UISlider会出现跳动
    @IBAction func touchDownOnProgerss(){
        helper.progressBlock(progress: nil)
    }

```
- 设置代理方法
``` swift

	extension PlayerViewController:AudioHelperDelegate{
    internal func player(current item: AVPlayerItem, status: AVPlayerItemStatus) {
        switch status {
        case .unknown:
            print("unknown")
        case .readyToPlay:
            print("readyToPlay")
        case .failed:
            print("网络出错")
        }

    }
    func didPlayToEnd(with item: AVPlayerItem) {
        print("当前歌曲播放完毕")
    }
}

```
[返回顶部](#head)


