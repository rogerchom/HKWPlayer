//
//  NowStreamingVC.swift
//  HKWPlayer
//
//  Created by Seonman Kim on 6/20/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

class NowStreamingVC: UIViewController, HKWPlayerEventHandlerDelegate {
    var songTitle: String!
    var songUrl : String!
    var serverUrl: String!
    var curVolume: Float = 50.0


    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var albumTitleLabel: UILabel!
    
    @IBOutlet var volumeSlider: UISlider!
    
    @IBOutlet var playBtn: UIButton!
    
    @IBOutlet var volumeLabel: UILabel!
    
    @IBAction func volumeChanged(sender: AnyObject) {
        println("volumeValueChanged")
        println("volumeValueChanged: \(volumeSlider.value)")
        HKWControlHandler.sharedInstance().setVolume(Int(volumeSlider.value))
        curVolume = volumeSlider.value
        volumeLabel.text = "Volume: \(Int(curVolume))"
    }
    
    @IBAction func playPausePressed(sender: AnyObject) {
        if playBtn.selected {
            HKWControlHandler.sharedInstance().stop()
            playBtn.selected = false
            
        }
        else {
            self.playBtn.selected = true

            playStreaming()
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        HKWControlHandler.debugPrintOn(true)
        
        titleLabel.text = songTitle
        albumTitleLabel.text = serverUrl
        
        let vol = HKWControlHandler.sharedInstance().getVolume()
        curVolume = Float(vol)
        println("SetAvgVolume as CurVolume: \(curVolume)")
        volumeSlider.value = curVolume
        volumeLabel.text = "Volume: \(Int(curVolume))"
        
        println("songUrl: " + songUrl)
        self.playBtn.selected = true
        playStreaming()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        HKWPlayerEventHandlerSingleton.sharedInstance().delegate = self

    }
    
    func playStreaming() {
        HKWControlHandler.sharedInstance().playStreamingMedia(songUrl, withCallback: {(bool result) -> Void in
            if result == false {
                println("playStreamingMedia: failed")
                self.playBtn.selected = false
                
                g_alert = UIAlertController(title: "Warning", message: "Playing streaming media failed. Please check the Internet connection or check if the meida URL is correct.", preferredStyle: .Alert)
                g_alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(g_alert, animated: true, completion: nil)
            } else {
                println("playStreamingMedia: successful")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    @IBAction func volumeDown(sender: AnyObject) {
        volumeSlider.value -= 3
        curVolume = volumeSlider.value
        HKWControlHandler.sharedInstance().setVolume(Int(volumeSlider.value))
        volumeLabel.text = "Volume: \(Int(curVolume))"
    }
    
    @IBAction func volumeUp(sender: AnyObject) {
        volumeSlider.value += 3
        curVolume = volumeSlider.value
        HKWControlHandler.sharedInstance().setVolume(Int(volumeSlider.value))
        volumeLabel.text = "Volume: \(Int(curVolume))"
    }

    func hkwPlayEnded() {
        println("Streaming music play ended.")
        playBtn.selected = false
    }

}
