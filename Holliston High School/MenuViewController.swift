//
//  MenuViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/20/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

/**
 The class that controls the items in the side-menu. Most of the actual transitioning is set up in either the RevealViewController or the Main.storyboard, but some of the buttons require extra directions.
 */
class MenuViewController: UIViewController {
    
    /**
     Responds to Sports Schedules button
     - Parameter sender: the class that triggered the function
     */
    @IBAction func goToSports(_ sender: Any) {
        if let url = URL(string: "http://hhsathletics.holliston.k12.ma.us/schedules") {
            UIApplication.shared.openURL(url)
        }
    }
    
    /**
     Responds to HHS Website button
     - Parameter sender: the class that triggered the function
     */
    @IBAction func goToWebsite(_ sender: Any) {
        if let url = URL(string: "http://hhs.holliston.k12.ma.us") {
            UIApplication.shared.openURL(url)
        }
    }
    
    /**
     Responds to Refresh Data button
     - Parameter sender: the class that triggered the function
     */
    @IBAction func refreshData(_ sender: Any) {
        if let revealViewController = self.revealViewController() as? RevealViewController {
            revealViewController.refreshData()
            revealViewController.revealToggle(animated: true)
        }
    }
}


