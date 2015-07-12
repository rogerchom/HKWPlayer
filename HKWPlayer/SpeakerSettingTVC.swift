//
//  SpeakerSettingTVC.swift
//  FCPlayer
//
//  Created by Seonman Kim on 12/23/14.
//  Copyright (c) 2014 Harman International. All rights reserved.
//

import UIKit

class SpeakerSettingTVC: UITableViewController, HKWDeviceEventHandlerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        HKWDeviceEventHandlerSingleton.sharedInstance().delegate = self


        self.tableView.reloadData()

        HKWControlHandler.sharedInstance().startRefreshDeviceInfo()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        HKWControlHandler.sharedInstance().stopRefreshDeviceInfo()
        println("####################################  viewDidDisappear")

    }
    
    @IBAction func showMenu(sender: AnyObject) {
        // Dismiss keyboard (optional)
        self.view.endEditing(true )
        self.frostedViewController.view.endEditing(true )
        
        // Present the view controller
        self.frostedViewController.presentMenuViewController()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return HKWControlHandler.sharedInstance().getGroupCount()

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HKWControlHandler.sharedInstance().getDeviceCountInGroupIndex(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Speaker_Cell", forIndexPath: indexPath) as! SpeakerTableViewCell

        
        //let cell = UITableViewCell(frame: CGRectZero)
        // Configure the cell...
        cell.selectionStyle = UITableViewCellSelectionStyle.None   //remove highlight

        var deviceInfo: DeviceInfo = HKWControlHandler.sharedInstance().getDeviceInfoByGroupIndexAndDeviceIndex(indexPath.section, deviceIndex: indexPath.row)
        
        cell.configCell(deviceInfo)

        println("----------------------------------")
        println("deviceName: \(deviceInfo.deviceName)")
        println("zoneName: \(deviceInfo.zoneName)")
        println("groupName: \(deviceInfo.groupName)")
        println("groupId: \(deviceInfo.groupId)")
        println("volume: \(deviceInfo.volume)")
        println("deviceId: \(deviceInfo.deviceId)")
        println("deviceActive: \(deviceInfo.active)")
        println("modelName: \(deviceInfo.modelName)")
        println("----------------------------------")

        
        if deviceInfo.active {
            cell.activeSwitch.on = true
        } else {
            cell.activeSwitch.on = false
        }
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        
        var header = HKWControlHandler.sharedInstance().getDeviceGroupNameByIndex(section)
        var groupIdStr = String(format: " (%llu)", HKWControlHandler.sharedInstance().getDeviceGroupIdByIndex(section))
        header = header + groupIdStr

        return header
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SpeakerInfo_TVC" {
            if let indexPathTemp = self.tableView.indexPathForSelectedRow() {
                var indexPath: NSIndexPath = indexPathTemp

                var deviceInfo: DeviceInfo = HKWControlHandler.sharedInstance().getDeviceInfoByGroupIndexAndDeviceIndex(indexPath.section, deviceIndex: indexPath.row)
                
                let destVC = segue.destinationViewController as! SpeakerInfoTVC
                destVC.uniqueId = deviceInfo.deviceId
                destVC.deviceName = deviceInfo.deviceName
                destVC.groupName = deviceInfo.groupName
                destVC.modelName = deviceInfo.modelName
                destVC.active = deviceInfo.active
                destVC.volume = Float(deviceInfo.volume)
                destVC.wifiStrength = deviceInfo.wifiSignalStrength
                destVC.version = deviceInfo.version
                destVC.ipAddress = deviceInfo.ipAddress
                destVC.speakerSettingTVC = self
            }

        }
        
    }
    
    func hkwDeviceStateUpdated(deviceid: Int64, withReason reason: Int) {
        println("hkwDeviceStateUpdated")
        self.tableView.reloadData()
    }

    func hkwErrorOccurred(errorCode: Int, withErrorMessage errorMesg: String!) {
        println("Error occured: errorCode:\(errorCode), mesg:\(errorMesg)")
        g_alert = UIAlertController(title: "Error", message: errorMesg, preferredStyle: .Alert)
        g_alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(g_alert, animated: true, completion: nil)
    }
}
