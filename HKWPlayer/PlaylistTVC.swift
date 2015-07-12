//
//  PlaylistTVC.swift
//  fcsample-ios
//
//  Created by Seonman Kim on 12/15/14.
//  Copyright (c) 2014 Seonman Kim. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import CoreData


var g_alert: UIAlertController!
var g_selectedIndex = -1

let g_licenseKey = "2FA8-2FD6-C27D-47E8-A256-D011-3751-2BD6"
var g_playList = [Playlist]()


func loadPlaylistItems() {
    
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let context: NSManagedObjectContext = appDel.managedObjectContext!
    
    let req = NSFetchRequest(entityName: "Playlist")
    
    g_playList = context.executeFetchRequest(req, error: nil)! as! [Playlist]
    
    for item in g_playList {
        configureItem(item)
    }
}

func configureItem(playList: Playlist) {
    // Configure the cell...
    var data: NSManagedObject = playList as NSManagedObject
    let mediaItemPersistentID = data.valueForKey("item_persistentID") as? String
    
    // query the media library
    let query = MPMediaQuery.songsQuery()
    
    let predicate = MPMediaPropertyPredicate(value: mediaItemPersistentID,
        forProperty: MPMediaItemPropertyPersistentID)
    query.addFilterPredicate(predicate)
    if let item = query.items.first as? MPMediaItem {
        playList.mediaItem = item
    
        playList.item_url = item.assetURL.absoluteString
        if playList.item_url == nil {
            playList.item_url = ""
        }
        
        playList.item_title = item.title
        if playList.item_title == nil {
            playList.item_title = "Unknown"
        }
        
        playList.item_artist = item.artist
        if playList.item_artist == nil {
            playList.item_artist = "Unknown"
        }
        
        playList.item_album_title = item.albumTitle
        if playList.item_album_title == nil {
            playList.item_album_title = "Unknown"
        }
        
        playList.item_url = item.assetURL.absoluteString
        playList.item_title = item.title
        playList.item_artist = item.artist
        playList.item_album_title = item.albumTitle
        playList.item_duration = item.playbackDuration
        
        var itemArtwork = item.artwork
        if let artwork = itemArtwork {
            playList.artworkImageSmall = artwork.imageWithSize(CGSizeMake(60.0, 60.0))
            playList.artworkImageBig = artwork.imageWithSize(CGSizeMake(240.0, 240.0))
        } else {
            playList.artworkImageSmall = UIImage(named: "ic_audiotrack_black_48dp")
            playList.artworkImageBig = UIImage(named: "ic_audiotrack_black_48dp")
        }
    } else {
        println("configureItem: mediaItem is nil")
    }
}


class PlaylistTVC: UITableViewController, MPMediaPickerControllerDelegate, AVAudioPlayerDelegate, HKWPlayerEventHandlerDelegate, HKWDeviceEventHandlerDelegate {
    
//    var fileCoordinator = NSFileCoordinator()
    var itemList: NSMutableArray!
    

    var mediaPicker: MPMediaPickerController?
    var launchMediaPicker = false
    var nowPlayingVC: NowPlayingVC!
    
    var warningInAddingSongTitle = false
    var warningMesg: String!

    @IBOutlet var btnNowPlaying: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if launchMediaPicker {
            displayMediaPicker()
            return
        }

        
        if g_selectedIndex >= 0 {
            btnNowPlaying.enabled = true
        }

//        HKWControlHandler.debugPrintOn(true)
        
        if !HKWControlHandler.sharedInstance().isInitialized() {
            // show the network initialization dialog
            println("show dialog")
            g_alert = UIAlertController(title: "Initializing", message: "If this dialog does not disappear, please check if any other HK WirelessHD App is running on the phone and kill it. Or, your phone is not in a Wifi network.", preferredStyle: .Alert)
            
            self.presentViewController(g_alert, animated: true, completion: nil)
        }
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("viewDidAppear")
        HKWPlayerEventHandlerSingleton.sharedInstance().delegate = self
        HKWDeviceEventHandlerSingleton.sharedInstance().delegate = self

        if g_playList.count == 0 {
            loadPlaylistItems()
        }
        
        
        tableView.reloadData()
        
        // save item_persistentID list for watch app
        saveItemListWormhole()
    

        if !HKWControlHandler.sharedInstance().initializing() && !HKWControlHandler.sharedInstance().isInitialized() {
            println("initializing in PlaylistTVC")

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if HKWControlHandler.sharedInstance().initializeHKWirelessController(g_licenseKey) != 0 {
                    println("initializeHKWirelessControl failed : invalid license key")
                    return
                }
                println("initializeHKWirelessControl - OK");

                // dismiss the network initialization dialog
                if g_alert != nil {
                    g_alert.dismissViewControllerAnimated(true, completion: nil)
                }
                
            })
        }
        
    }
    
    
    private func saveItemListWormhole() {
        self.itemList = NSMutableArray()
        
        for item in g_playList {
            self.itemList.addObject(item.item_persistentID)
        }
        println("passMessageObject")
        g_wormhole.passMessageObject(["itemList": self.itemList], identifier: "itemList")
        println("passMessageObject-done")

    }
    

    
    func startActivityAnimation(indexRow: Int) {
        var indexPath = NSIndexPath(forRow: indexRow, inSection: 0)
        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! PlaylistTableViewCell
        cell.activityView.startAnimation()
    }
    
    func stopActivityAnimation(indexRow: Int) {
        var indexPath = NSIndexPath(forRow: indexRow, inSection: 0)
        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! PlaylistTableViewCell
        cell.activityView.stopAnimation()
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return g_playList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Title_Cell", forIndexPath: indexPath) as! PlaylistTableViewCell

        cell.titleLabel?.text = g_playList[indexPath.row].item_title
        cell.artistLabel?.text = g_playList[indexPath.row].item_artist
        cell.albumLabel?.text = g_playList[indexPath.row].item_album_title
        let duration = Int(g_playList[indexPath.row].item_duration)
        var min = duration / 60
        var sec = duration % 60
        var formatStr: String = String(format: "%d:%02d", min, sec)
        println("duration: \(formatStr)")
        cell.durationLabel?.text = formatStr
        cell.albumArtImageView.image = g_playList[indexPath.row].artworkImageSmall
        
        if HKWControlHandler.sharedInstance().isInitialized() {
            if HKWControlHandler.sharedInstance().isPlaying() && indexPath.row == g_selectedIndex {
                cell.activityView?.startAnimation()
            }
        }

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        if editingStyle == .Delete {
            //    context.deletedObject(myList[indexPath!.row] as NSManagedObject)
            context.deleteObject(g_playList[indexPath.row] as NSManagedObject)
            g_playList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            
            var error: NSError? = nil
            if !context.save(&error) {
                abort()
            }
            
            if HKWControlHandler.sharedInstance().isPlaying() {
                println("Stop the current playback for resetting the song index")
                HKWControlHandler.sharedInstance().stop()
            }
            
            // reflect the change to the watch app
            saveItemListWormhole()
        }
    }

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


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "NowPlaying_VC" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let index = indexPath?.row
            
            let destTVC: NowPlayingVC = segue.destinationViewController as! NowPlayingVC
            destTVC.playlistTVC = self
            
            println("index: \(index!)")
            println("g_selectedIndex: \(g_selectedIndex)")
            if index! == g_selectedIndex {
                println("go to the current title")
                
                destTVC.viewLoadByCellSelection = false
                destTVC.isPlaying = HKWControlHandler.sharedInstance().isPlaying()
                destTVC.musicDuration = g_playList[g_selectedIndex].item_duration
                
            } else {
                println("change the  title")

                // stop current playing animation
                if g_selectedIndex >= 0 {
                    stopActivityAnimation(g_selectedIndex)
                }
                
                g_selectedIndex = index!
                destTVC.viewLoadByCellSelection = true
                btnNowPlaying.enabled = true
            }
            
            destTVC.musicDuration = g_playList[g_selectedIndex].item_duration
            let vol = HKWControlHandler.sharedInstance().getVolume()
            destTVC.curVolume = Float(vol)

        }
        else if segue.identifier == "NowPlaying_BBI" {

        }
    }

    // MARK: - Media Picker
    func displayMediaPicker(){
        
        if let picker = MPMediaPickerController(mediaTypes: .AnyAudio) {
            
            println("Successfully instantiated a media picker")
            picker.delegate = self
            picker.allowsPickingMultipleItems = true
            picker.showsCloudItems = true
            picker.prompt = "Pick songs to add"
            view.addSubview(picker.view)
            
            presentViewController(picker, animated: true, completion: nil)
            
        } else {
            println("Could not instantiate a media picker")
        }
        
    }

    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        
        for thisItem in mediaItemCollection.items as! [MPMediaItem] {
            let isCloudItem = thisItem.valueForProperty(MPMediaItemPropertyIsCloudItem) as! Bool
            if isCloudItem {
                println("this music item is in the cloud")
                let itemTitle = thisItem.valueForProperty(MPMediaItemPropertyTitle) as? String
                if let title = itemTitle {
                    warningMesg = "'\(title)' has not been added to the PlayList, because it is not on the device (The song is in iTunes Match)."
                }
                warningInAddingSongTitle = true
                println("mesg: \(warningMesg)")
                continue
            } else {
                println("This music item is located locally")
            }
            
            if thisItem.assetURL == nil {
                let itemTitle = thisItem.valueForProperty(MPMediaItemPropertyTitle) as? String
                if let title = itemTitle {
                    warningMesg = "'\(title)' is not available from Music Library. This item may be from Apple Music."
                }
                else {
                    warningMesg = "The item you chose is not available from Music Library. This item may be from Apple Music."
                }
                
                warningInAddingSongTitle = true
                
            } else {
                
                // Save to Core Data
                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                // Reference ManagedObjectContext
                let context: NSManagedObjectContext = appDel.managedObjectContext!
                let entity = NSEntityDescription.entityForName("Playlist", inManagedObjectContext: context)
                
                // TODO: check for duplicated item
                
                // Create instance of our data model and initialize
                var playItem = Playlist(entity: entity!, insertIntoManagedObjectContext: context)
                
                let persistentID = String(thisItem.persistentID)
                println("Item persistentID: \(persistentID)")
                
                
                playItem.setValue(persistentID, forKey: "item_persistentID")
                
                var error: NSError?
                if !context.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                    abort()
                }
            }
            
        }
        
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
        
        if warningInAddingSongTitle {
            g_alert = UIAlertController(title: "Warning", message: warningMesg, preferredStyle: .Alert)
            g_alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(g_alert, animated: true, completion: nil)
            
            warningInAddingSongTitle = false
        }
        
        loadPlaylistItems()
    }
    
    /**
    media picker has been cancelled
    */
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func hkwPlaybackStateChanged(playState: Int) {
        println("StateChange::: need to be implemented here: ==> \(playState)")

    }
    
    func hkwPlaybackTimeChanged(timeElapsed: Int) {
        g_wormhole.passMessageObject(["timeElapsed": timeElapsed], identifier: "playbackTimer")
        
    }

    func hkwPlayEnded() {
        HKWControlHandler.sharedInstance().stop()
        if !g_playInitiatedByWatch {
            stopActivityAnimation(g_selectedIndex)
        }

        println("PlayEnd::: Play the next song")
        g_selectedIndex++
        if g_selectedIndex >= g_playList.count {
            g_selectedIndex = 0
        }
        
        let currentItem = g_playList[g_selectedIndex] as Playlist
        let urlString = currentItem.item_url
        println("URLString: \(urlString)")
        let assetUrl = NSURL(string: urlString)
        
        let songName = currentItem.item_title
        let duration = currentItem.item_duration
        
        HKWControlHandler.sharedInstance().playCAF(assetUrl, songName: songName, resumeFlag:false)

        startActivityAnimation(g_selectedIndex)

        
        // Update the information of the title being played
        if (self.nowPlayingVC != nil) {
            self.nowPlayingVC.musicDuration = duration
            self.nowPlayingVC.setGUIByCurrentIndex()
        }
        
        // notify Watch of PlayEnded and also the new item to play
        g_wormhole.passMessageObject(["playStartedByPhone": g_selectedIndex], identifier: "playbackEvent")
        println("hkwPlayEnded() in PlaylistTVC")

    }
    
    func hkwErrorOccurred(errorCode: Int, withErrorMessage errorMesg: String!) {
        println("Error occured: errorCode:\(errorCode), mesg:\(errorMesg)")
        g_alert = UIAlertController(title: "Error", message: errorMesg, preferredStyle: .Alert)
        g_alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(g_alert, animated: true, completion: nil)
    }
    
    func hkwDeviceStateUpdated(deviceid: Int64, withReason reason: Int) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.saveDeviceList()
    }
}
