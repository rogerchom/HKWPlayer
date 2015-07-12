//
//  SpeakerInfoTVC.swift
//  HKWPlayer
//
//  Created by Seonman Kim on 6/20/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

class SpeakerInfoTVC: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate {
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
        HKWControlHandler.sharedInstance().setDeviceName(uniqueId, deviceName:tfDeviceName.text);
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
        
        HKWControlHandler.sharedInstance().setDeviceGroupName(uniqueId, groupName:newGroupName)
        self.navigationController?.popViewControllerAnimated(true )
        
    }
    
    
    
    @IBAction func removeDeviceFromGroup(sender: AnyObject) {
        println("removeDeviceFromGroup")
        
        HKWControlHandler.sharedInstance().removeDeviceFromGroup(uniqueId)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
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
