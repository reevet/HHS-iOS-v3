//
//  MenuViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/20/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* reponds to Sports Schedules button */
    @IBAction func goToSports(_ sender: Any) {
        if let url = URL(string: "http://hhsathletics.holliston.k12.ma.us/schedules") {
            UIApplication.shared.openURL(url)
        }
    }
    
    /* reponds to HHS Website button */
    @IBAction func goToWebsite(_ sender: Any) {
        if let url = URL(string: "http://hhs.holliston.k12.ma.us") {
            UIApplication.shared.openURL(url)
        }
    }
    
    /* responds to Refresh Data button */
    @IBAction func refreshData(_ sender: Any) {
        if let revealViewController = self.revealViewController() as? RevealViewController {
            revealViewController.refreshData()
            revealViewController.revealToggle(animated: true)
        }
    }
    
    
}


