//
//  XmlGoogleSitesParser.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/24/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import Foundation
import Fuzi  // used to convert XML into a DOM model

/**
 Parses JSON data received from the Google Sites XHTML
 */
public class XmlGoogleSitesParser {
    
    /**
     These are the names of the "tags" in the XML data.
     That is, the XML data should look like this:
     ```swift
       <feed>
         <entry>
             <title>Announcements for Nov. 12, 2017</title>
             <published>2017-11-12T07:30:00-04:00</published>
             <content>
                <div>
                    <h1>Announcements for Nov. 12, 2017</h1>
                    <p>The next open house will be... etc
             etc.
     */
    struct FeedTags {
        static let feed = "feed"
        static let entry = "entry"
        static let title = "title"
        static let details = "content"
        static let date = "published"
        static let url = "link"
        static let urlRel = "alternate"
    }
    // the storage list of articles (posts)
    var articleList = [Article]()
    
    /**
     Parses the provided data, one entry at a time, to get individual articles.

     **NOTE:** one "article" is a day's worth of announcements, which are all poted together. For example, one "article" for October 15 would have a details sections containg all of the day's announcements, including a club meeting time, sports registration, etc.
     - Parameter data: the downloaded data to parse
     - Returns: an array of articles
     */
    func parse(data: Data) -> [Article] {
        
        //set holders for data
        var title: String = ""
        var details: String = ""
        var date: Date?
        var url: String = ""
        
        do {
            // convert the data into a DOM object
            let document = try XMLDocument(data: data)
            
            // the obejct is formatted properly...
            if let root = document.root {
                document.definePrefix("atom", defaultNamespace: "http://www.w3.org/2005/Atom")
                
                // ... get the array of entries...
                let entries = root.children(tag: FeedTags.entry)
                
                // ... and loop through the entries one at a time
                for entry in entries {
                    
                    // collect the article's title
                    title = entry.firstChild(tag: FeedTags.title)!.stringValue
                    
                    // collect the article's publish date
                    date = parseDate(item: entry.firstChild(tag: FeedTags.date)!.stringValue)
                    
                    // collect the article's url
                    url = parseLinks(links: entry.children(tag: FeedTags.url))
                    
                    // collect the article's details (HTML content)
                    if let htmlDoc = entry.firstChild(tag: FeedTags.details) {
                        details = htmlDoc.rawXML
                    }
                        
                    // check for a required valid data. All others can go in as "" blank
                    if let date = date {
                        // make this an article and add it to the list
                        let article = Article.init(title: title, date: date as Date, url: url, details: details, imgSrc: "")
                        articleList.append(article)
                    }
                }
            }
        } catch {
            //error
        }
        
        // send back the array of newly parsed articles
        return articleList
    }
    
    /**
     Special instructions for parsing the url.This cycles through all urls, and keeps the one with rel="alternate"
     - Parameter links: an array of link elements
     - Returns: a string url for the article's post
     */
    func parseLinks(links: [XMLElement]) -> String
    {
        for link in links {
            let rel = link.attr("rel")
            if (rel == FeedTags.urlRel) {
                if let urlOpt = link.attr("href") {
                    return urlOpt
                }
            }
        }
        return ""
    }
    
    /**
     Special instructions for parsing the date. This converts a string into a Date object
     - Parameter item: the date as a formatted string
     - Returns: a Date object*/
    func parseDate(item: String) -> Date? {
        
        // expected format: 2017-10-12T09:14:00.610Z
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.date(from: item)
    }
}
