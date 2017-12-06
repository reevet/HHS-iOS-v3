//
//  RevealViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/29/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit
import SWRevealViewController
import Toast_Swift

/**
 Manages the side slide-out menu. Most of the control is done by the superclass SWRevealVieController, but this subclass is here to facilitate data refreshing, especially when a cloud message notfication tells it to.
 */
class RevealViewController: SWRevealViewController {
    
    /// Tracks when a news article is being requested. If a specific news article is being pushed to the detail view, this number will indicate the array position of the article, where 0 is the most recent article. -1 indicates no article being pushed.
    var pushNewsIndex = -1
    
    override func viewDidLoad() {
        refreshData()
    }
    
    /**
     Requests a data download from each of the five article stores
    */
    func refreshData() {
        refreshArticleStore(storeType: .SCHEDULES)
        refreshArticleStore(storeType: .EVENTS)
        refreshArticleStore(storeType: .LUNCH)
        refreshArticleStore(storeType: .DAILY_ANN)
        refreshArticleStore(storeType: .NEWS)
    }
    
    /**
     Requests a data download from an individual article store. Also sends a brief notification that data was downloaded
     - Parameter storeType: the type of article store (SCHEDULES, NEWS, etc)
     */
    func refreshArticleStore(storeType: ArticleStore.StoreType) {
        
        // sets up a store
        let  store = ArticleStore(type: storeType)
        
        // sets the callback function for the store, to fire when it is done downloading
        store.onDataUpdate = { [weak self] (list: [Article]) in
            if list.count > 0 {
                if let this = self {
                    
                    // gets the controller of the visible screen either TableView or HomeView. (We don't care if it's a DetailView)
                    if let frontViewController = (this.frontViewController as! UINavigationController).visibleViewController as? BaseTableViewController {
                        
                        // tell the TableView to update its data and show a notice
                        if frontViewController.type == storeType {
                            frontViewController.receiveDataUpdate(list: list)
                            this.toastNewData()
                        }
                    } else if let frontViewController = (this.frontViewController as!                   UINavigationController).visibleViewController as? HomeViewController {
                        // tell the HomeView to update its data and show a notice
                        frontViewController.receiveUpdate(storeType: storeType, list: list)
                        this.toastNewData()
                    }
                }
            }
        }
        // triggers the store's download
        store.downloadArticles()
    }
    
    /**
     Checks the NEWS articlestore for a news article with a matching headline. This is usually called by AppDelegate in response to a notification
     - Parameter headline: the title of the news post to find
     */
    func newsArticleIndexFor(headline: String) -> Int {
        // get the store articles
        let store = ArticleStore(type: .NEWS)
        let articles = store.queryArticles()
        
        // loop through, and return the index if found
        for (index, article) in articles.enumerated() {
            if article.title == headline {
                return index
            }
        }
        
        // if not found, return -1
        return -1
    }
    
    
    /**
    Pushes the news article to the NewsDetailView
     - Parameter index: the index in the array for the news article. 0 = most recent article.
     */
    func showNewsArticle(index: Int) {
        // set the index for the most recent article
        self.pushNewsIndex = index
        
        // perform the transition to the DetailView
        self.performSegue(withIdentifier: "sw_front", sender: self)
    }
    
    /**
    Sets data into the DetailView just before performing the segue
     - Parameter segue: the seque to be performed
     - Parameter sender:  the class that calls the function
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.pushNewsIndex >= 0 {
            if segue.identifier == "sw_front" {
                
                // we are actually pushing to the HomeView controller, which will in turn push to the DetailView.
                // This allows the user to tap "back" and return to the HomeView.
                let controller = (segue.destination as! UINavigationController).viewControllers[0] as! HomeViewController
                
                // prevent the user from being able to back out of the HomeView
                controller.navigationItem.leftItemsSupplementBackButton = false
                
                // transfers the article's index number to the HomeView, and clears it here
                controller.pushNewsIndex = self.pushNewsIndex
                self.pushNewsIndex = -1
            }
        }
    }
    
    /**
    Pops up a little view to notify the user that new data was downloaded
     */
    func toastNewData() {
        let frontViewController = self.frontViewController
        frontViewController?.view.makeToast("New data downloaded")
    }
}
