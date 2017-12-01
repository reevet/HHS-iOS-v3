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

/** manages the side slide-out menu. Most of the control is done by the
 *  superclass SWRevealVieController, but this subclass is here to facilitate
 * data refreshing, especially when a cloud message notficition tells it to.
 */
class RevealViewController: SWRevealViewController {
    
    var pushNewsIndex = -1
    
    func refreshData() {
        refreshArticleStore(storeType: ArticleStore.StoreType.SCHEDULES)
        refreshArticleStore(storeType: ArticleStore.StoreType.EVENTS)
        refreshArticleStore(storeType: ArticleStore.StoreType.LUNCH)
        refreshArticleStore(storeType: ArticleStore.StoreType.DAILY_ANN)
        refreshArticleStore(storeType: ArticleStore.StoreType.NEWS)
    }
    
    func refreshArticleStore(storeType: ArticleStore.StoreType) {
        let  store = ArticleStore(type: storeType)
        store.onDataUpdate = { [weak self] (list: [Article]) in
            if list.count > 0 {
                if let this = self {
                    if let frontViewController = (this.frontViewController as! UINavigationController).visibleViewController as? BaseTableViewController {
                        if frontViewController.type == storeType {
                            frontViewController.receiveDataUpdate(list: list)
                            this.toastNewData()
                        }
                    } else if let frontViewController = (this.frontViewController as! UINavigationController).visibleViewController as? HomeViewController {
                        frontViewController.receiveUpdate(storeType: storeType, list: list)
                        this.toastNewData()
                    }
                }
            }
        }
        store.downloadArticles()
    }
    
    /* checks the News articlestore for a news article with a matching headline.
     This is usually called by AppDelegate in response to a notification */
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
    
    func showNewsArticle(index: Int) {
        self.pushNewsIndex = index
        self.performSegue(withIdentifier: "sw_front", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.pushNewsIndex >= 0 {
            if segue.identifier == "sw_front" {
                let controller = (segue.destination as! UINavigationController).viewControllers[0] as! HomeViewController
                controller.pushNewsIndex = self.pushNewsIndex
                controller.navigationItem.leftItemsSupplementBackButton = false
                self.pushNewsIndex = -1
            }
        }
    }
    
    func toastNewData() {
        let frontViewController = self.frontViewController
        frontViewController?.view.makeToast("New data downloaded")
    }
}
