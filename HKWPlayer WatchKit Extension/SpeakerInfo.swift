//
//  SpeakerInfo.swift
//  HKWPlayer
//
//  Created by Seonman Kim on 5/8/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import Foundation

class SpeakerInfo: NSObject, NSCoding {
    var speakerName : String!
    var groupName: String!
    var modelName: String!
    var isActive: Bool = false
    var volume: Int = 0
    
    init(speakerName: String, groupName: String, modelName: String, isActive: Bool, volume: Int) {
        self.speakerName = speakerName
        self.groupName = groupName
        self.modelName = modelName
        self.isActive = isActive
        self.volume = volume
        
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        speakerName = aDecoder.decodeObjectForKey("speakerName") as! String
        groupName = aDecoder.decodeObjectForKey("groupName") as! String
        modelName = aDecoder.decodeObjectForKey("modelName") as! String
        isActive = aDecoder.decodeBoolForKey("isActive")
        volume = aDecoder.decodeIntegerForKey("volume")
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(speakerName, forKey: "speakerName")
        aCoder.encodeObject(groupName, forKey: "groupName")
        aCoder.encodeObject(modelName, forKey: "modelName")
        aCoder.encodeBool(isActive, forKey: "isActive")
        aCoder.encodeInteger(volume, forKey: "volume")
    }
}

struct ModelIconName {
    static let SpeakerIconOmni10 = "Omni 10"
    static let SpeakerIconOmni20 = "Omni 20"
    static let SpeakerIconOmniAdapt = "Omni Adapt"
    static let SpeakerIconOmniBar = "Omni Bar"
}