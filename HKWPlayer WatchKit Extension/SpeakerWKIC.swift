//
//  SpeakerWKIC.swift
//  HKWPlayer
//
//  Created by Seonman Kim on 5/8/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import WatchKit
import Foundation

func getIconImageForModel(modelName: String) -> UIImage
{
    if modelName == ModelIconName.SpeakerIconOmni10 {
        return UIImage(named: "speaker_fc1")!
    } else if modelName == ModelIconName.SpeakerIconOmni20 {
        return UIImage(named: "speaker_fc2")!
    } else if modelName == ModelIconName.SpeakerIconOmniAdapt {
        return UIImage(named: "speaker_fca10")!
    }
    else {
        return UIImage(named: "speaker_omnibar")!
    }
}

class SpeakerWKIC: WKInterfaceController {
    @IBOutlet var table: WKInterfaceTable!

    var deviceList: NSMutableArray!
    var speakerList: [SpeakerInfo]!

    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
                
        println("SpekaerWKIC - awakeWithContext")
        // Configure interface objects here.
        
        WKInterfaceController.openParentApplication(["getSpeakerCount": NSNumber(integer: 0)], reply: {(reply, error) -> Void in
            if let retVal = reply["getSpeakerCount"] as? NSNumber {
                println("speaker count: \(retVal.integerValue)")
            }
        })

        g_wormhole.listenForMessageWithIdentifier("speakerList", listener: {
            (messageObject: AnyObject!) -> Void in
            self.deviceList = messageObject.valueForKey("speakerList") as! NSMutableArray
            println("speakerList: \(self.deviceList)")
            for device in self.deviceList {
                var str = device as! String
                println("device: \(str)")
            }
            
            self.updateDeviceList()
        })

        var messageObject: AnyObject! = g_wormhole.messageWithIdentifier("speakerList")
        deviceList = messageObject.valueForKey("speakerList") as! NSMutableArray
        updateDeviceList()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        println("SpekaerWKIC - willActivate")
        
        updateDeviceList()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        println("SpekaerWKIC - didDeactivate")
        g_wormhole.stopListeningForMessageWithIdentifier("speakerList")

    }
    
    
    private func updateDeviceList() {
        println("updateDeviceList()")
        var persistentID :String?
        
        println("deviceList.count: \(self.deviceList.count)")
        
        self.speakerList = [SpeakerInfo]()
        
        self.table?.setNumberOfRows(self.deviceList.count, withRowType: "SpeakerInfoRow")
        
        
        for (index, item) in enumerate(self.deviceList) {
            println("device: \(item)")
            var infoList = item as! String
            var tempArray = infoList.componentsSeparatedByString(":")
            let deviceName = tempArray[0]
            let groupName = tempArray[1]
            let modelName = tempArray[2]
            let isActive = tempArray[3] == "true" ? true : false
            let volume = tempArray[4].toInt()
            let deviceIdStr = tempArray[5]
            
            let cell = self.table?.rowControllerAtIndex(index) as! SpeakerRowController
            cell.speakerNameLabel?.setText(deviceName)
            cell.speakerGroupName?.setText("@\(groupName)")
            cell.speakerSwitch?.setOn(isActive)
            cell.speakerVolumeSlide?.setValue(Float(volume!))
            cell.deviceIdStr = deviceIdStr
            
            var speakerImage = getIconImageForModel(modelName)
            cell.speakerImage?.setImage(speakerImage)
            
            cell.speakerWKIC = self
        }        
    }
    
    func changeSwitch(deviceIdStr: String, value: Bool) {
        var param = "\(deviceIdStr):\(value)"
        println("changeSwitch: param:\(param)")
        WKInterfaceController.openParentApplication(["setActive": param], reply: {(reply, error) -> Void in
            if let eventCreated = reply["setActive"] as? NSNumber {
                
            }
        })
    }

    func changeVolume(deviceIdStr: String, value: Float) {
        var param = "\(deviceIdStr):\(Int(value))"
        WKInterfaceController.openParentApplication(["setVolumeDevice": param], reply: {(reply, error) -> Void in
            if let eventCreated = reply["setVolumeDevice"] as? NSNumber {
                
            }
        })
    }
    
}
