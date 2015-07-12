//
//  SpeakerTableViewCell.swift
//  HKWPlayer
//
//  Created by Seonman Kim on 4/20/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

func getIconImageForModel(modelName: String) -> UIImage
{
    if modelName == kModelNameOmni10 {
        return UIImage(named: "speaker_fc1")!
    } else if modelName == kModelNameOmni20{
        return UIImage(named: "speaker_fc2")!
    } else if modelName == kModelNameOmniBar {
        return UIImage(named: "speaker_omnibar")!
    }
    else {
        return UIImage(named: "speaker_fca10")!
    }
}

class SpeakerTableViewCell: UITableViewCell {

    var deviceInfo : DeviceInfo!
    
    @IBOutlet var deviceNameLbl: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var activityImageView: UIImageView!
    
    @IBOutlet var volumeSlider: UISlider!
    @IBOutlet var volumeLbl: UILabel!
    @IBOutlet var activeSwitch: UISwitch!
    @IBOutlet var wifiLabel: UILabel!
    @IBOutlet var streamingActivityView: StreamingActivityView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configCell(deviceInfo: DeviceInfo) {
        self.deviceInfo = deviceInfo
        
        iconImageView.image = inverseColor(getIconImageForModel(deviceInfo.modelName))
        deviceNameLbl?.text = deviceInfo.deviceName
        volumeLbl?.text = "\(deviceInfo.volume)"
        volumeSlider.value = Float(deviceInfo.volume)
        wifiLabel?.text = "\(deviceInfo.wifiSignalStrength)dBm"
        if deviceInfo.isPlaying {
            streamingActivityView.startAnimation()
        } else {
            streamingActivityView.stopAnimation()

        }
    }
    
    @IBAction func activeSwitchChanged(sender: AnyObject) {
        if activeSwitch.on {
            HKWControlHandler.sharedInstance().addDeviceToSession(deviceInfo.deviceId)
            
        } else {
            HKWControlHandler.sharedInstance().removeDeviceFromSession(deviceInfo.deviceId)
            
        }
    }
    

    @IBAction func volumeChanged(sender: UISlider) {
        HKWControlHandler.sharedInstance().setVolumeDevice(deviceInfo.deviceId, volume:NSInteger(volumeSlider.value))
        volumeLbl.text = "\(Int(volumeSlider.value))"
    }
    
//    func getWifiImage(value: Int) -> UIImage
//    {
//        var image : UIImage!
//        
//        if value < -90 {
//            image = UIImage(named: "ic_signal_wifi_0_bar_black_48dp")!
//        } else if value < -70 {
//            image = UIImage(named: "ic_signal_wifi_1_bar_black_48dp")!
//        } else if value < -50 {
//            image = UIImage(named: "ic_signal_wifi_2_bar_black_48dp")!
//        } else if value < -30 {
//            image = UIImage(named: "ic_signal_wifi_3_bar_black_48dp")!
//        }
//        else {
//            image = UIImage(named: "ic_signal_wifi_4_bar_black_48dp")!
//        }
//        
//        return image
//    }
    
    func inverseColor(image: UIImage) -> UIImage {
        var coreImage: CIImage = CIImage(CGImage: image.CGImage)
        var filter: CIFilter = CIFilter(name: "CIColorInvert")
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        var result: CIImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
        return UIImage(CIImage: result)!
    }
}
