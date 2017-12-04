//
//  DailyannDetailViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/24/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

/**
 The View Controller for showing a single Daily Announcement post */
class DailyannDetailViewController: UIViewController {

    // the webview element to be filled
    @IBOutlet weak var detailsWebView: UIWebView!
    
    // the article to display
    var article: Article? {
        didSet {
            configureView()
        }
    }
    
    /**
     Starts the controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    /**
     Retrieves and displays the necessary article
     */
    func configureView() {
        
        // if article isn't set, uses the first article in the article store
        if article == nil {
            let store = ArticleStore(type: ArticleStore.StoreType.DAILY_ANN)
            let articles = store.queryArticles(limit: 1)
            if articles.count > 0 {
                self.article = articles[0]
            }
        }
        
        // sets the content of the article into the webview
        if let detail = article {
            if let webview = detailsWebView {
                
                // adds styling for consistent experience (whoever posts the
                // daily announcements might not worry about format)
                let detailHtml = "<style>*{font-size:18px !important}</style>" + detail.details
                
                // sets the content into the webview
                webview.loadHTMLString(detailHtml, baseURL: nil)
            }
            
            // sets the navbar title to the article's title
            self.title = detail.title
        }
    }
}
