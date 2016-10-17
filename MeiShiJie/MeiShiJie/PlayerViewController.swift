//
//  PlayerViewController.swift
//  MeiShiJie
//
//  Created by 李童 on 2016/10/16.
//  Copyright © 2016年 李童. All rights reserved.
//

import UIKit
import AVFoundation
class PlayerViewController: UIViewController {
    @IBOutlet weak var carrentLab:UILabel!
    @IBOutlet weak var endLab:UILabel!
    @IBOutlet weak var progress:UISlider!
    @IBOutlet weak var controBtn:UIButton!
    
    var helper:AudioHelper!
    
    var urlSource:[String] = ["http://mapi-test.huitupiaowu.com/discoverer/data/file/20160826/b63da2db85ffb6fccc9c59dfbae14a7d.mp3","http://mapi-test.huitupiaowu.com/discoverer/data/file/20160826/8f4b19e3c234d4394500e32207c99c64.mp3","http://mapi-test.huitupiaowu.com/discoverer/data/file/20160826/edf34ca5934bf00881242e8fcf7992ba.mp3","sound2.caf"]
    var source:[URL] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for urlString in urlSource{
            var url:URL!
            if urlString == "sound2.caf"{
                url = URL(fileURLWithPath: Bundle.main.path(forResource: "sound2", ofType: "caf")!)
            }else{
                url = URL(string: urlString)
            }
            source.append(url)
        }
        //初始化播放
        helper = AudioHelper(source: source)
        //打开循环播放
        helper.isLoop = true
        //设置播放进度回调
        helper.progressBlock(progress: updateProgress)
        //设置代理对下岗
        helper.delegate = self
        // Do any additional setup after loading the view.
    }
    //播放进度回调
    func updateProgress(value:Float)->Swift.Void{
        self.progress.value = value
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //播放或暂停
    @IBAction func controSwitch(){
        if controBtn.isSelected {
            helper.pause()
            
        }else{
            helper.play()
        }
        controBtn.isSelected = !controBtn.isSelected
        
    }
    //下一首
    @IBAction func next()->Void{
        helper.next()
    }
    //上一首
    @IBAction func prev()->Void{
        helper.prev()
    }
    //UISlider的valueChanged事件，请把UISlider的isContinuous属性设为false
    @IBAction func seekToProgerss(){
        helper.seekToProgerss(self.progress.value)
        helper.progressBlock(progress: updateProgress)
    }
    //UISlider的touchDown事件，需要在touchDown事件中将进度回调方法置nil，不然UISlider会出现跳动
    @IBAction func touchDownOnProgerss(){
        helper.progressBlock(progress: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
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
