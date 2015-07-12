//
//  PlaylistTableViewCell.swift
//  HKWPlayer
//
//  Created by Seonman Kim on 4/16/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

    @IBOutlet var albumArtImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var activityView: StreamingActivityView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(titleName: String, artistName: String, albumName: String, duration: String) {
        titleLabel.text = titleName
        artistLabel.text = artistName
        albumLabel.text = albumName
        durationLabel.text = duration
    }

}
