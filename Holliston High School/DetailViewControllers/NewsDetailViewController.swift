//
//  NewsDetailViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/26/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit
import Kingfisher

/**
 The View Controller for showing a single News post */
class NewsDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    // the webview element to be filled
    @IBOutlet weak var detailsWebView: UIWebView!
    @IBOutlet weak var newsImage: UIImageView!
    
    // the article to display
    var article: Article? {
        didSet {
            configureView()
        }
    }
    
    var pushNewsIndex = -1
    
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
            let store = ArticleStore(type: .NEWS)
            let articles = store.queryArticles(limit: 1)
            if articles.count > 0 {
                if self.pushNewsIndex >= 0 {
                    self.article = articles[self.pushNewsIndex]
                    self.pushNewsIndex = -1
                } else {
                    self.article = articles[0]
                }
            }
        }
        
        if let tl = titleLabel {
            tl.text = article?.title
        }
        
        if let newsImage = newsImage {
            let imgURL = URL(string: (article?.imgSrc)!)
            newsImage.kf.setImage(with: imgURL)
        }
        
        // sets the content of the article into the webview
        
        if let webview = detailsWebView {
            
            // adds styling for consistent experience (whoever posts the
            // news might not worry about format)
            let style = "<style>*{font-size:18px !important; font-family: Helvetica !important;}</style>"
            let detailHtml =  style + (article?.details)!
            
            // sets the content into the webview
            webview.loadHTMLString(detailHtml, baseURL: nil)
        }
    }
}
