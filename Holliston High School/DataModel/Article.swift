//
//  Article.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/20/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import Foundation

/** this is the basic class of a single post. It holds one calendar event, one schedule,
 * one news post, etc.
 */
public class Article: NSObject, NSCoding {
    
    // properties of an article
    let title: String   // the title of the post, or name of the calendar event
    let date: Date      // the published date of a news item, or the start date of the event
    let url: String     // the url to the post or event
    let imgSrc: String  // the url of the first image within the post (applies only to news posts)
    let details: String // the content of the post, or the description section of the event
    var formattedDate: String = ""
    
    var key: String {   // a unique key, which is usually just the URL for the post
        get {
            guard url != "" else {
                return "\(title)\(date)"
            }
            return url
        }
    }
    
    // create a new article instance
    init(title: String, date:Date, url: String, details: String, imgSrc: String ) {
        self.title = title
        self.date = date
        self.url = url
        self.details = details
        self.imgSrc = imgSrc
    }
    
    // the encoding structure so the article can be cached to local storage
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(details, forKey: "details")
        aCoder.encode(imgSrc, forKey: "imgSrc")
    }
    
    // the decoding structure so the article can be retrieved from local storage
    public required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as! String
        date = aDecoder.decodeObject(forKey: "date") as! Date
        url = aDecoder.decodeObject(forKey: "url") as! String
        details = aDecoder.decodeObject(forKey: "details") as! String
        imgSrc = aDecoder.decodeObject(forKey: "imgSrc") as! String
    }
}

