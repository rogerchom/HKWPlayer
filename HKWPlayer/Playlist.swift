//
//  Playlist.swift
//  FCPlayer
//
//  Created by Seonman Kim on 12/19/14.
//  Copyright (c) 2014 Harman International. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MediaPlayer
import AVFoundation


@objc(Playlist)
class Playlist: NSManagedObject {

    @NSManaged var item_persistentID: String

    var item_url: String!
    var item_title: String!
    var item_artist: String!
    var item_album_title: String!
    var item_duration: Double!
    var mediaItem: MPMediaItem!
    var artworkImageSmall: UIImage!
    var artworkImageBig: UIImage!

}
