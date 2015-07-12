//
//  SpeakerRowController.swift
//  HKWPlayer
//
//  Created by Seonman Kim on 5/8/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit
import WatchKit

class SpeakerRowController: NSObject {
   
    @IBOutlet var speakerImage: WKInterfaceImage!
    @IBOutlet var speakerNameLabel: WKInterfaceLabel!
    @IBOutlet var speakerGroupName: WKInterfaceLabel!
    @IBOutlet var speakerSwitch: WKInterfaceSwitch!
    @IBOutlet var speakerVolumeSlide: WKInterfaceSlider!
    var deviceIdStr : String!
    
    var speakerWKIC : SpeakerWKIC!
    
    @IBAction func speakerSwitchChanged(value: Bool) {
        speakerWKIC.changeSwitch(deviceIdStr, value: value)
    }
    
    @IBAction func speakeVolumeChanged(value: Float) {
        speakerWKIC.changeVolume(deviceIdStr, value: value)
    }
}
