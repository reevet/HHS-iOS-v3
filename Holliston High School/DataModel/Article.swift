//
//  Article.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/20/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import Foundation

/**
 This is the basic class of a single post. It holds one calendar event, one schedule, one news post, etc.
 */
public class Article: NSObject, NSCoding {
    
    //===================================================================================================
    // pragma MARK:  PROPERTIES
    //===================================================================================================

    /// the title of the post, or name of the calendar event
    let title: String
    
    /// the published date of a news item, or the start date of the event
    let date: Date
    
    /// the url to the post or event
    let url: String
    
    /// the url of the first image within the post (applies only to news posts)
    let imgSrc: String
    
    /// the content of the post, or the description section of the event
    let details: String
    
    /// a formatted version of the date
    var formattedDate: String = ""
    
    /// a unique key, which is usually just the URL for the post
    var key: String {
        get {
            guard url != "" else {
                return "\(title)\(date)"
            }
            return url
        }
    }
    
    //===================================================================================================
    // pragma MARK:  INITIALIZER
    //===================================================================================================

    /**
    Creates a new article instance
     - Parameter title: the title of the article
     - Parameter date: the start date or published date (required)
     - Parameter url: the url to the article online
     - Parameter details: the article content or description
     - Parameter imgSrc: the article's first image
     */
    init(title: String, date:Date, url: String, details: String, imgSrc: String ) {
        self.title = title
        self.date = date
        self.url = url
        self.details = details
        self.imgSrc = imgSrc
    }
    
    //===================================================================================================
    // pragma MARK:  ENCODING
    //===================================================================================================
    
    /**
    The encoding structure so the article can be cached to local storage
     -Parameter aCoder: the coder
    */
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(details, forKey: "details")
        aCoder.encode(imgSrc, forKey: "imgSrc")
    }
    
    /**
    The decoding structure so the article can be retrieved from local storage
     - Parameter: the decoder
     */
    public required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as! String
        date = aDecoder.decodeObject(forKey: "date") as! Date
        url = aDecoder.decodeObject(forKey: "url") as! String
        details = aDecoder.decodeObject(forKey: "details") as! String
        imgSrc = aDecoder.decodeObject(forKey: "imgSrc") as! String
    }
    
    //===================================================================================================
    // pragma MARK:  HELPERS
    //===================================================================================================

    /**
    Compares this article to another, so see if their information is the same
     - Parameter article: the second article, to which the instance is compared
     - Returns: true is the information is the same, false if anything if different
     */
    func equals(article: Article) -> Bool {
        let titleMatches = (self.title == article.title)
        let dateMatches = (self.date == article.date)
        let detailMatches = (self.details == article.details)
        let urlMatches = (self.url == article.url)
        let imgSrcMatches = (self.imgSrc == article.imgSrc)
        
        if titleMatches && dateMatches && detailMatches && urlMatches && imgSrcMatches {
            return true
        }
        return false
    }
}

