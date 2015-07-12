//
//  MenuTVC.swift
//  FCPlayer
//
//  Created by Seonman Kim on 12/19/14.
//  Copyright (c) 2014 Harman International. All rights reserved.
//

import UIKit


class MenuTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("tableView: didSelectRowAtIndexPath")
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let navigationController: RootNC = self.storyboard?.instantiateViewControllerWithIdentifier("contentController") as! RootNC
        
        var jumpToNewVC = false
        
        if(indexPath.section == 0 && indexPath.row == 0) {
            
            println("Goto the playlist VC")
            let playlistTVC: PlaylistTVC = self.storyboard?.instantiateViewControllerWithIdentifier("Playlist_TVC") as! PlaylistTVC
            navigationController.viewControllers = [playlistTVC]

            jumpToNewVC = true
            
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            println("Goto the playlist VC, but immediately launch the MediaPicker")

            let playlistTVC: PlaylistTVC = self.storyboard?.instantiateViewControllerWithIdentifier("Playlist_TVC") as! PlaylistTVC
            playlistTVC.launchMediaPicker = true
            navigationController.viewControllers = [playlistTVC]

            jumpToNewVC = true
            
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            
            println("Goto My Streaming Service")
            let myStreamingServiceTVC: MyStreamingServiceTVC = self.storyboard?.instantiateViewControllerWithIdentifier("MyStreamingService_TVC") as! MyStreamingServiceTVC
            navigationController.viewControllers = [myStreamingServiceTVC]
            jumpToNewVC = true
            
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            
            println("Goto MixRadio Service")
            let mixRadioTVC: MixRadioTVC = self.storyboard?.instantiateViewControllerWithIdentifier("MixRadio_TVC") as! MixRadioTVC
            navigationController.viewControllers = [mixRadioTVC]
            jumpToNewVC = true
            
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            
            println("Goto About")
            let aboutVC: AboutVC = self.storyboard?.instantiateViewControllerWithIdentifier("About_VC") as! AboutVC
            navigationController.viewControllers = [aboutVC]
            jumpToNewVC = true
            
        }
                
        if jumpToNewVC {
            self.frostedViewController.contentViewController = navigationController
        }
        self.frostedViewController.hideMenuViewController()
    }

}
