//
//  JsonParser.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/20/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import Foundation
import SwiftSoup // used to strip any HTML tags in the details section

/**
 * parses JSON data received from the Google Calendar API
 */
public class JsonGoogleCalendarParser {
    
    /* these are the names of the "tags" in the JSON data
       i.e. the JSON data should look like this:
       {
         [item: {
                   summary: "A Day",
                   description: "7:30 - 8:42  A block etc",
                   start: {
                        date: "2017-10-12"
                            }
                    etc.
     */
    struct FeedTags {
        static let feed = ""
        static let entry = "items"
        static let title = "summary"
        static let details = "description"
        static let date = "start"
        static let dateDate = "date"
        static let dateDateTime = "dateTime"
        static let url = "selfLink"
    }
    
    // the storage list of articles (events)
    var articleList = [Article]()
    
    /* parses the provided data, one entry at a time, to get individual articles */
    func parse(data: Data) -> [Article] {
        
        // set holders for data
        var title: String = ""
        var details: String = ""
        var date: Date?
        var url: String = ""
        
        // convert the data into a JSON object
        let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // if the data is formatted properly...
        if let rootDictionary = jsonData as? [String: Any] {
            
            // ... and if there is an array of articles...
            if let items = rootDictionary[FeedTags.entry] as? [Any] {
                
                // loop through each article and get its elements
                for item in items {
                    
                    // if THIS article has elements
                    if let item = item as? [String: Any] {
                        
                        // collect the article's title
                        if let summary = item[FeedTags.title] as? String {
                            title = summary
                        }
                        
                        // collect the article's details/content
                        if let desc = item[FeedTags.details] as? String {
                            details = parseDetails(desc: desc)
                        }
                        
                        // collect the article's start date
                        if let start = item[FeedTags.date] as? [String: Any] {
                            date = parseDate(item: start)
                        }
                        
                        // collect the article's url
                        if let link = item[FeedTags.url] as? String {
                            url = link
                        }
                        
                        // check for a required valid date. All others can go in as "" blank
                        if let date = date {
                            // make this an article and add it to the list
                            let article = Article.init(title: title, date: date as Date, url: url, details: details, imgSrc: "")
                            articleList.append(article)
                        }
                    }
                }
            }
        }
        
        //send back the array of newly parsed articles
        return articleList
    }
    
    // special instructions for parsing the details.
    // this strips out any HTML from the string
    func parseDetails(desc: String) -> String {
        if desc.range(of: "<p>") != nil  {
            do {
                let doc: Document = try SwiftSoup.parse(desc)
                return try doc.text()
            } catch Exception.Error(let type, let message) {
                print("\(message): (type: \(type))")
                return desc
            } catch {
                print("error")
            }
        }
        return desc
    }
    
    // special instructions for parsing the date.
    // this checks the exact date structure and formats appropriately
    func parseDate(item: [String: Any]) -> Date? {
        
        // if the date is "date only" (no time included), e.g. 2013-05-14
        if let startDate = item[FeedTags.dateDate] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
                // 2013-05-14
            return dateFormatter.date(from:startDate)
        }
        // if the date inlcudes a time section, e.g. 2013-05-14T07:30:00-04:00
        else if let startDate = item[FeedTags.dateDateTime] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
            return dateFormatter.date(from: startDate)
        }
        return nil
    }
}
