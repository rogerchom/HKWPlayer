//
//  SpeakerInfoVC.swift
//  FCPlayer
//
//  Created by Seonman Kim on 12/29/14.
//  Copyright (c) 2014 Harman International. All rights reserved.
//

import UIKit

class SpeakerInfoVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {
    
    var speakerSettingTVC: SpeakerSettingTVC!
    
    var uniqueId: CLongLong = 0
    var deviceName: String = ""
    var groupName: String = ""
    var active: Bool = false
    var volume: Float = 0.0
    var modelName: String = ""
    var groupNameSelected: String!
    var wifiStrength = 0
    var version: String = ""
    var ipAddress: String = ""
    
    var roomTypes = ["Custom", "Balcony", "Basement", "Bathroom", "Bedroom", "Deck", "Dining Room", "Garage", "Gargen", "Hallway", "Kitchen", "Living Room", "Loft", "Lounge", "Patio", "Pool", "Study"]

    @IBOutlet var labelDeviceID: UILabel!
    @IBOutlet var tfDeviceName: UITextField!
    
    @IBOutlet var tfGroupName: UITextField!
    
    
    @IBOutlet var labelModelName: UILabel!
    
    @IBOutlet var pickerGroupName: UIPickerView!
    
    @IBOutlet var labelWifiStrength: UILabel!
    
    @IBOutlet var labelVersion: UILabel!
    
    @IBOutlet var labelIPAddress: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        labelDeviceID.text = "\(uniqueId)"
        tfDeviceName.text = deviceName
        tfGroupName.text = ""
        labelModelName.text = modelName
        labelVersion.text = "v\(version)"
        labelIPAddress.text = ipAddress
        
        labelWifiStrength.text = "\(wifiStrength)"
        
        // Do any additional setup after loading the view.
        self.pickerGroupName.delegate = self
        
        var groupIndex = findGroupName(groupName)
        if groupIndex != -1 {
            pickerGroupName.selectRow(groupIndex, inComponent: 0, animated: true)
        }
        else {
            // set to Customer
            pickerGroupName.selectRow(0, inComponent: 0, animated: true)
            tfGroupName.enabled = true
            tfGroupName.text = groupName

        }
    }

    func findGroupName(groupName: String) -> Int {
        for var i = 0; i < roomTypes.count; i++ {
            if roomTypes[i] == groupName {
                return i
            }
        }
        return -1
    }
    
    @IBAction func saveSpeakerInfo(sender: AnyObject) {
        g_HWControlHandler.setDeviceName(uniqueId, deviceName:tfDeviceName.text);
        //CiosEventHandlerWrapper.refreshDevices();
        
        //self.dismissViewControllerAnimated(true , completion: nil)
        self.navigationController?.popViewControllerAnimated(true )
    }
    
    @IBAction func saveSpeakerGroup(sender: AnyObject) {
        var pickerSelectedIndex = pickerGroupName.selectedRowInComponent(0)
        var newGroupName: String!
        if pickerSelectedIndex != 0 {
            newGroupName = roomTypes[pickerSelectedIndex]
        } else {
            newGroupName = tfGroupName.text
        }
        
        if newGroupName == "" {
            return
        }
        
        g_HWControlHandler.setDeviceGroupName(uniqueId, groupName:newGroupName)
        self.navigationController?.popViewControllerAnimated(true )

    }
    

    
    @IBAction func removeDeviceFromGroup(sender: AnyObject) {
        println("removeDeviceFromGroup")
        
        g_HWControlHandler.removeDeviceFromGroup(uniqueId)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // IOS Touch functions
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // UITextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roomTypes.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return roomTypes[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        groupNameSelected = roomTypes[row];
        println("GroupName selected: \(groupNameSelected)")
        
        if groupNameSelected == "Custom" {
            tfGroupName.enabled = true
        } else {
            tfGroupName.enabled = false
        }
    }


}
