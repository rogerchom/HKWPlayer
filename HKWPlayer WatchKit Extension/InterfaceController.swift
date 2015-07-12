//
//  InterfaceController.swift
//  HKWPlayer WatchKit Extension
//
//  Created by Seonman Kim on 5/6/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import WatchKit
import Foundation
import MediaPlayer
import AVFoundation

let kAppGroupName = "group.com.logicaldimension.HKWPlayer"


func inverseColor(image: UIImage) -> UIImage {
    var coreImage: CIImage = CIImage(CGImage: image.CGImage)
    var filter: CIFilter = CIFilter(name: "CIColorInvert")
    filter.setValue(coreImage, forKey: kCIInputImageKey)
    var result: CIImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
    return UIImage(CIImage: result)!
}

func imageWithImage(image: UIImage, newSize: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
    var newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}

var g_currentIndex = -1
var g_playList = [Playlist]()
var g_sameItem = false
var g_wormhole = MMWormhole(applicationGroupIdentifier: kAppGroupName, optionalDirectory: "wormhole")
var g_nowPlayingWKIC: NowPlayingWKIC!

class InterfaceController: WKInterfaceController, MPMediaPickerControllerDelegate {

    @IBOutlet weak var table: WKInterfaceTable!
    var itemList: NSMutableArray!

    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let defaults = NSUserDefaults(suiteName: kAppGroupName)
        println(defaults?.objectForKey("test"))
        
        g_wormhole.listenForMessageWithIdentifier("playbackEvent", listener: {
            (messageObject: AnyObject!) -> Void in
            var number = messageObject.valueForKey("playStartedByPhone") as! NSNumber
            var newIndex = number.integerValue
            
            if newIndex != g_currentIndex {
                self.updateTitleColor()
                g_currentIndex = newIndex
                var playItem = g_playList[g_currentIndex]
                if g_nowPlayingWKIC != nil {
                    g_nowPlayingWKIC.configureUI(playItem)
                }
            }

        })
        
        g_wormhole.listenForMessageWithIdentifier("playbackTimer", listener: {
            (messageObject: AnyObject!) -> Void in
            var number = messageObject.valueForKey("timeElapsed") as! NSNumber
            var timeElapsed = number.integerValue
            
            if g_nowPlayingWKIC != nil {
                g_nowPlayingWKIC.updateTimeElapsed(timeElapsed)
            }
            
        })
        
        g_wormhole.listenForMessageWithIdentifier("itemList", listener: {
            (messageObject: AnyObject!) -> Void in
            self.itemList = messageObject.valueForKey("itemList") as! NSMutableArray
            
            self.updateItemList()
        })
        
        let messageObject: AnyObject! = g_wormhole.messageWithIdentifier("itemList")
//        if messageObject != nil {
//            itemList = messageObject.valueForKey("itemList") as! NSMutableArray
//            updateItemList()
//        }
        itemList = messageObject.valueForKey("itemList") as! NSMutableArray
        updateItemList()
        println("after itemList")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        updateTitleColor()
        
        g_nowPlayingWKIC = nil
    }
    
    func updateTitleColor() {
        for var i = 0; i < g_playList.count; i++ {
            if g_currentIndex == i {
                g_playList[i].rowController.itemTitle.setTextColor(UIColor.orangeColor())
            } else {
                g_playList[i].rowController.itemTitle.setTextColor(UIColor.whiteColor())
            }
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        g_sameItem = g_currentIndex == rowIndex ? true : false
        g_currentIndex = rowIndex
        
        return g_playList[rowIndex]
    }
    

    private func updateItemList() {
        var persistentID :String?
        
        g_playList = [Playlist]()
        self.table?.setNumberOfRows(self.itemList.count, withRowType: "SongRow")
        
        for var i = 0; i < self.itemList.count; i++ {
            self.configureItem(self.itemList[i] as! String)
            let cell = self.table?.rowControllerAtIndex(i) as! SongRowController
            
            var value = g_playList[i]
            cell.itemTitle?.setText(value.item_title)
            cell.itemArtist?.setText(value.item_artist)
            cell.itemImage?.setImage(value.artworkImageSmall)
            
            value.rowController = cell
        }
    }
    
    
    func configureItem(mediaItemPersistentID: String) {
        var playItem = Playlist()

        // query the media library
        let query = MPMediaQuery.songsQuery()
        
        let predicate = MPMediaPropertyPredicate(value: mediaItemPersistentID,
            forProperty: MPMediaItemPropertyPersistentID)
        query.addFilterPredicate(predicate)
        let item = query.items.first as? MPMediaItem
        playItem.mediaItem = item
        
        playItem.item_url = item!.assetURL.absoluteString
        playItem.item_title = item!.title
        playItem.item_artist = item!.artist
        playItem.item_album_title = item!.albumTitle
        playItem.item_duration = item!.playbackDuration
        playItem.item_persistentID = mediaItemPersistentID
        
        var itemArtwork = item!.artwork
        if let artwork = itemArtwork {
            playItem.artworkImageSmall = artwork.imageWithSize(CGSizeMake(32.0, 32.0))
        } else {
            let tmpImage = UIImage(named: "ic_audiotrack_white_48dp")
            playItem.artworkImageSmall = imageWithImage(tmpImage!, CGSizeMake(32.0, 32.0))

        }
        
        g_playList.append(playItem)
    }
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()

    }
}
