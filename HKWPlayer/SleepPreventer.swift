//
//  SleepPreventer.swift
//  HKWPlayer
//
//  Created by Seonman Kim on 2/17/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit
import AVFoundation


class SleepPreventer: NSObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer!

    
    func startPreventSleep() {
        
        var nsWavPath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Tornado Siren-45s.mp3")
        var assetUrl = NSURL(fileURLWithPath: nsWavPath)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var error: NSError?
            
            self.audioPlayer = AVAudioPlayer(contentsOfURL: assetUrl, error: &error)
            
            if let player = self.audioPlayer {
                player.delegate = self
                
                if player.prepareToPlay() && player.play() {
                    println("Successfully started playing")
//                    self.g_audioPlaying = true
                } else {
                    println("failed to play")
//                    self.g_audioPlaying = false
                }
            } else {
                println("failed to instantiate AVAudioPlayer")
            }
        })
        
    }
   
    func stopPreventSleep() {
        audioPlayer.stop()
    }
    
    func handleInterruption(notification: NSNotification){
        /* Audio Session is interrupted. The player will be paused here */
        
        let interruptionTypeAsObject =
        notification.userInfo![AVAudioSessionInterruptionTypeKey] as NSNumber
        
        let interruptionType = AVAudioSessionInterruptionType(rawValue:
            interruptionTypeAsObject.unsignedLongValue)
        
        if let type = interruptionType{
            if type == .Ended{
                
                /* resume the audio if needed */
                
            }
        }
        
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!,
        successfully flag: Bool){
            
            println("Finished playing the song")
            
            /* The flag parameter tells us if the playback was successfully
            finished or not */
            if player == audioPlayer{
                audioPlayer = nil
            }
            
    }
}
