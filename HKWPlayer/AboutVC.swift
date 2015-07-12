//
//  AboutVC.swift
//  FCPlayer
//
//  Created by Seonman Kim on 12/23/14.
//  Copyright (c) 2014 Harman International. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
