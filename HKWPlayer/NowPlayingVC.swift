//
//  NowPlayingVC.swift
//  fcsample-ios
//
//  Created by Seonman Kim on 12/16/14.
//  Copyright (c) 2014 Seonman Kim. All rights reserved.
//

import UIKit

//var g_duration: Double = 0.0

class NowPlayingVC: UIViewController, HKWPlayerEventHandlerDelegate {
    
    var playlistTVC: PlaylistTVC!
    var viewLoadByCellSelection = false
    var isPlaying = false
    var curVolume: Float = 50.0
    var musicDuration: Double = 0.0
    
    var currentItem: Playlist!
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var artistAlbumLbl: UILabel!

    @IBOutlet var btnPlayStop: UIButton!
    @IBOutlet var sliderVolume: UISlider!
    @IBOutlet var sliderPlaybackTime: UISlider!
    @IBOutlet var labelStartTime: UILabel!
    @IBOutlet var labelEndTime: UILabel!
    @IBOutlet var labelAverageVolume: UILabel!
    @IBOutlet var artworkImageView: UIImageView!
    @IBOutlet var muteBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HKWPlayerEventHandlerSingleton.sharedInstance().delegate = self
        
        setGUIByCurrentIndex()
        
        createBorder(artworkImageView)

        
        if viewLoadByCellSelection {
            playCurrentIndex()
            playlistTVC.startActivityAnimation(g_selectedIndex)
            
        } else {
            btnPlayStop.selected = isPlaying
        }
        
        println("SetAvgVolume as CurVolume: \(curVolume)")
        sliderVolume.value = curVolume
        labelAverageVolume.text = "Average Volume: \(Int(curVolume))"
        if HKWControlHandler.sharedInstance().isMuted() {
            muteBtn.setTitle("Unmute", forState: UIControlState.Normal)
        } else {
            muteBtn.setTitle("Mute", forState: UIControlState.Normal)
        }
        
        playlistTVC.nowPlayingVC = self;

    }
    
    func createBorder(imageView: UIImageView!) {
        var borderLayer = CALayer()
        var borderFrame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)
        borderLayer.backgroundColor = UIColor.clearColor().CGColor
        borderLayer.frame = borderFrame
        borderLayer.cornerRadius = 0.0
        borderLayer.borderWidth = 1.0
        borderLayer.borderColor = UIColor.lightGrayColor().CGColor
        imageView.layer.addSublayer(borderLayer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func volumeDown(sender: AnyObject) {
        sliderVolume.value -= 3
        curVolume = sliderVolume.value
        HKWControlHandler.sharedInstance().setVolume(Int(sliderVolume.value))
        labelAverageVolume.text = "Average Volume: \(Int(curVolume))"
        
        muteBtn.setTitle("Mute", forState: UIControlState.Normal)

    }
    
    @IBAction func volumeUp(sender: AnyObject) {
        sliderVolume.value += 3
        curVolume = sliderVolume.value
        HKWControlHandler.sharedInstance().setVolume(Int(sliderVolume.value))
        labelAverageVolume.text = "Average Volume: \(Int(curVolume))"
        
        muteBtn.setTitle("Mute", forState: UIControlState.Normal)

    }
    
    @IBAction func mutePressed(sender: AnyObject) {
        if HKWControlHandler.sharedInstance().isMuted() {
            HKWControlHandler.sharedInstance().unmute()
            muteBtn.setTitle("Mute", forState: UIControlState.Normal)
        } else {
            HKWControlHandler.sharedInstance().mute()
            muteBtn.setTitle("Unmute", forState: UIControlState.Normal)

        }
    }
    
    
    @IBAction func skipPrevious(sender: AnyObject) {
        
        playlistTVC.stopActivityAnimation(g_selectedIndex)
        
        if g_timeElapsed < 1 {
            let count = g_playList.count
            g_selectedIndex--
            if g_selectedIndex < 0 {
                g_selectedIndex = count - 1
            }
        }

        setGUIByCurrentIndex()
        
        if btnPlayStop.selected {
            playCurrentIndex()
            playlistTVC.startActivityAnimation(g_selectedIndex)
        }
    }
    

    
    @IBAction func skipNext(sender: AnyObject) {
        playlistTVC.stopActivityAnimation(g_selectedIndex)

        let count = g_playList.count
        g_selectedIndex++
        if g_selectedIndex == count {
            g_selectedIndex = 0
        }

        setGUIByCurrentIndex()
        
        if btnPlayStop.selected {
            playCurrentIndex()
            playlistTVC.startActivityAnimation(g_selectedIndex)
        }
    }
    
    @IBAction func volumeValueChanged(sender: AnyObject) {
        println("volumeValueChanged")
        println("volumeValueChanged: \(sliderVolume.value)")
        HKWControlHandler.sharedInstance().setVolume(Int(sliderVolume.value))
        curVolume = sliderVolume.value
        labelAverageVolume.text = "Average Volume: \(Int(curVolume))"
        
        muteBtn.setTitle("Mute", forState: UIControlState.Normal)
    }
    
    
    @IBAction func playAndStop(sender: AnyObject) {
        if btnPlayStop.selected {
            
            HKWControlHandler.sharedInstance().pause()
            btnPlayStop.selected = false
            playlistTVC.stopActivityAnimation(g_selectedIndex)

        }
        else {
            let urlString = currentItem.item_url
            println("URLString: \(urlString)")
            let assetUrl = NSURL(string: urlString)
            // or, let assetUrl = NSURL(string: urlString)
            
            let songName = currentItem.item_title
            let duration = currentItem.item_duration
            
            HKWControlHandler.sharedInstance().playCAF(assetUrl, songName: songName, resumeFlag: true)
            g_playInitiatedByWatch = false

            btnPlayStop.selected = true
            playlistTVC.startActivityAnimation(g_selectedIndex)

        }
    }
    
    @IBAction func playbackTimeChanged(sender: UISlider) {
        let urlString = currentItem.item_url
        println("URLString: \(urlString)")
        let assetUrl = NSURL(string: urlString)
        
        let songName = currentItem.item_title
        let duration = currentItem.item_duration
        
        var startTime = Int(sliderPlaybackTime.value)
        HKWControlHandler.sharedInstance().playCAFFromCertainTime(assetUrl, songName: songName, startTime: startTime)
        g_playInitiatedByWatch = false

    }
    
    
    func setGUIByCurrentIndex() {
        currentItem = g_playList[g_selectedIndex] as Playlist
        titleLbl.text = currentItem.item_title
        artistAlbumLbl.text = "\(currentItem.item_artist) - \(currentItem.item_album_title)"
        musicDuration = currentItem.item_duration
        println("currentItem.title: \(currentItem.item_title)")
        
        artworkImageView.image = currentItem.artworkImageBig
        
        sliderPlaybackTime.minimumValue = 0.0
        sliderPlaybackTime.maximumValue = Float(musicDuration)
        
    }
    
    func playCurrentIndex() {
        
        HKWControlHandler.sharedInstance().stop()
        
        let urlString = currentItem.item_url
        println("URLString: \(urlString)")
        let assetUrl = NSURL(string: urlString)
        // or, let assetUrl = NSURL(string: urlString)

        let songName = currentItem.item_title
        musicDuration = currentItem.item_duration
        sliderPlaybackTime.minimumValue = 0.0
        sliderPlaybackTime.maximumValue = Float(musicDuration)
        sliderPlaybackTime.value = 0.0
        
        labelStartTime.text = "0:00"
        labelEndTime.text = "0:00"
        

        if HKWControlHandler.sharedInstance().playCAF(assetUrl, songName: songName, resumeFlag: false) {
            btnPlayStop.selected = true
            g_timeElapsed = 0
            g_playInitiatedByWatch = false

        }
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
    }
    */

    func hkwDeviceVolumeChanged(deviceId: Int64, deviceVolume: Int, withAverageVolume avgVolume: Int) {
        println("##########################################################")
        println("SetAvgVolume: devieId: \(deviceId) new volume: \(deviceVolume), avgVolumee: \(avgVolume)")
        self.sliderVolume.value = Float(avgVolume)
        curVolume = self.sliderVolume.value
        labelAverageVolume.text = "Average Volume: \(Int(curVolume))"
        println("##########################################################")
    }
    
    func hkwPlaybackTimeChanged(timeElapsed: Int) {
        self.sliderPlaybackTime.value = Float(timeElapsed)
        g_timeElapsed = timeElapsed
        
        var min = timeElapsed / 60
        var sec = timeElapsed % 60
        var formatStr: String = String(format: "%d:%02d", min, sec)
        self.labelStartTime.text = formatStr
        
        let remainingTime = Int(self.musicDuration) - timeElapsed
        min = remainingTime / 60
        sec = remainingTime % 60
        formatStr = String(format: "-%d:%02d", min, sec)
        self.labelEndTime.text = formatStr
        
        g_wormhole.passMessageObject(["timeElapsed": timeElapsed], identifier: "playbackTimer")

    }
    
    func hkwPlaybackStateChanged(playState: Int) {
        println("+++++++++++++++++++ PlaybackStateChanged: \(playState)")


    }
    
    func hkwPlayEnded() {
        HKWControlHandler.sharedInstance().stop()
        playlistTVC.stopActivityAnimation(g_selectedIndex)

        
        let count = g_playList.count
        g_selectedIndex++
        if g_selectedIndex == count {
            g_selectedIndex = 0
        }
        
        setGUIByCurrentIndex()
        
        if btnPlayStop.selected {
            playCurrentIndex()
            playlistTVC.startActivityAnimation(g_selectedIndex)
        }
        
        // notify Watch of PlayEnded and also the new item to play
        g_wormhole.passMessageObject(["playStartedByPhone": g_selectedIndex], identifier: "playbackEvent")
        println("hkwPlayEnded() in NowPlayingVC")

    }
}
