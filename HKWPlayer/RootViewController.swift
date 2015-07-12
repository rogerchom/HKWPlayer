//
//  RootViewController.swift
//  FCPlayer
//
//  Created by Seonman Kim on 12/19/14.
//  Copyright (c) 2014 Harman International. All rights reserved.
//

import UIKit

class RootViewController: REFrostedViewController {

    override func awakeFromNib () {
        self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("contentController") as! UINavigationController
        self.menuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("menuController") as! UINavigationController
    }

}
