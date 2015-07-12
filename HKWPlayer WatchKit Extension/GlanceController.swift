//
//  GlanceController.swift
//  HKWPlayer WatchKit Extension
//
//  Created by Seonman Kim on 5/6/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import WatchKit
import Foundation
import MediaPlayer


class GlanceController: WKInterfaceController {

    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    @IBOutlet var artistLabel: WKInterfaceLabel!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    
    @IBOutlet var artworkImage: WKInterfaceImage!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        WKInterfaceController.openParentApplication(["getCurrentItem": ""], reply: {(reply, error) -> Void in
            if let retValue = reply["getCurrentItem"] as? String {
                println("getCurrentItem: \(retValue)")
                
                if retValue != "N/A" {
                    let query = MPMediaQuery.songsQuery()
                    
                    let predicate = MPMediaPropertyPredicate(value: retValue,
                        forProperty: MPMediaItemPropertyPersistentID)
                    query.addFilterPredicate(predicate)
                    let item = query.items.first as? MPMediaItem
                    self.titleLabel.setText(item!.title)
                    self.artistLabel.setText(item!.artist)
                    
                    var itemArtwork = item!.artwork
                    if let artwork = itemArtwork {
                        self.artworkImage.setImage(artwork.imageWithSize(CGSizeMake(48.0, 48.0)))
                    } else {
                        let tmpImage = UIImage(named: "ic_audiotrack_white_48dp")
                        self.artworkImage.setImage(imageWithImage(tmpImage!, CGSizeMake(48.0, 48.0)))
                    }
                } else {
                    self.titleLabel.setText("Title: N/A")
                    self.artistLabel.setText("Artist: N/A")
                    let tmpImage = UIImage(named: "ic_audiotrack_white_48dp")
                    self.artworkImage.setImage(imageWithImage(tmpImage!, CGSizeMake(48.0, 48.0)))
                }
                
            }
        })
        
        
        WKInterfaceController.openParentApplication(["getIsPlaying": ""], reply: {(reply, error) -> Void in
            if let retValue = reply["getIsPlaying"] as? NSNumber {
                var isPlaying = retValue.boolValue
                println("current isPlaying: \(retValue.boolValue)")
                if isPlaying {
                    self.statusLabel.setText("Playing")
                } else {
                    self.statusLabel.setText("Stopped")
                }
            }
        })
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
