//
//  MyStreamingServiceTVC.swift
//  HKWPlayer
//
//  Created by Seonman Kim on 6/19/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

class MyStreamingServiceTVC: UITableViewController {
    let serverUrlPrefix = "http://seonman.github.io/music/";

    var songList = ["ec-faith.wav",
                    "hyolyn.mp3"]
    
    @IBAction func showMenu(sender: AnyObject) {
        // Dismiss keyboard (optional)
        self.view.endEditing(true )
        self.frostedViewController.view.endEditing(true )
        
        // Present the view controller
        self.frostedViewController.presentMenuViewController()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return songList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StreamingSongCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = songList[indexPath.row]

        return cell
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NowStreaming_VC" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let index = indexPath?.row
            
            let destVC: NowStreamingVC  = segue.destinationViewController as! NowStreamingVC
            destVC.songTitle = songList[index!]
            destVC.songUrl = serverUrlPrefix + songList[index!]
            destVC.serverUrl = serverUrlPrefix
        }

    }

}
