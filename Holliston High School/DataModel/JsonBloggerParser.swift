//
//  JsonBloggerParser.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/24/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import Foundation
import SwiftSoup

/**
 Parses JSON data received from the Blogger API
 */
public class JsonBloggerParser {

    /**
     These are the names of the "tags" in the JSON data.
     That is, the JSON data should look like this:
     ````swift
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
        static let title = "title"
        static let details = "content"
        static let date = "published"
        static let url = "selfLink"
    }

    /// the storage list of articles (posts)
    var articleList = [Article]()

    /**
     Parses the provided data, one entry at a time, to get individual articles
     - Parameter data: the downloaded data to parse
     - Returns: an array of articles
     */
    func parse(data: Data) -> [Article] {
        
        // set holders for data
        var title: String = ""
        var details: String = ""
        var date: Date?
        var url: String = ""
        var imgSrc: String = ""
        
        // convert the data into a JSON object
        let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // if the data is formatted properly...
        if let rootDictionary = jsonData as? [String: Any] {
            
            // ...and if there is an array of articles...
            if let items = rootDictionary[FeedTags.entry] as? [Any] {
                
                // loop through each article and get its elements
                for item in items {
                    
                    // if THIS article has elements
                    if let item = item as? [String: Any] {
                        
                        // collect the article's title
                        if let summary = item[FeedTags.title] as? String {
                            title = summary
                        }
                        
                        // collect the article's details/content and image URL
                        if let desc = item[FeedTags.details] as? String {
                            details = parseDetails(desc: desc)
                            imgSrc = parseImgSrc(desc: desc)
                        }
                        
                        // collect the article's published date
                        if let start = item[FeedTags.date] as? String {
                            date = parseDate(string: start)
                        }
                        
                        //collect the article's URL link
                        if let link = item[FeedTags.url] as? String {
                            url = link
                        }
                        
                        // check for a required valied date. All others can go in as "" blank
                        if let date = date {
                            
                            // make this an article and add it to the list
                            let article = Article.init(title: title, date: date as Date, url: url, details: details, imgSrc: imgSrc)
                            articleList.append(article)
                        }
                    }
                }
            }
        }
        // send back the array of newly parsed articles
        return articleList
    }
    
    /**
     Special instructions for parsing the image URL source. This finds the first <img> tag and returns its "src" attribute
     - Parameter desc: the description string to parse
     - Returns: a string url for the first image in the desc, or "" if not found
     */
    func parseImgSrc(desc: String) -> String {
        var imgSrc = ""
        
        // if there is an <img> tag....
        if desc.range(of: "<img") != nil  {
            
            // convert the details into a DOM and take the first img's src
            do {
                let doc: Document = try SwiftSoup.parse(desc)
                let images: Elements = try doc.select("img")
                let image = images.first()
                if let href = try image?.attr("src") {
                    imgSrc = href
                }
            } catch Exception.Error(let type, let message) {
                print("\(message): (type: \(type))")
            } catch {
                print("error")
            }
        }
        return imgSrc
    }
    
    /**
     Special instructions for parsing the details. This finds the first <img> tag removes it (the first image will be cached and displayed natively, not via web call
     - Parameter desc: the description text of the item
     - Returns: the same HTML string, without the img tag
     */
    func parseDetails(desc: String) -> String {
        // if there is an <img> tag....
        if desc.range(of: "<img") != nil  {
            
            // convert the details into a DOM and take the first img's src
            do {
                let doc: Document = try SwiftSoup.parse(desc)
                let images: Elements = try doc.select("img")
                try images.first()?.remove()
                return try doc.html()
            } catch Exception.Error(let type, let message) {
                print("\(message): (type: \(type))")
            } catch {
                print("error")
            }
        }
        return desc
    }

    /**
     Special instructions for parsing the date. This converts the string into a data object
     - Parameter string: the date as a formatted string
     - Returns: a Date object
     */
    func parseDate(string: String) -> Date? {
        
        // expected format: 2013-05-14T07:30:00-04:00
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
        let dateStr = dateFormatter.date(from: string)
        return dateStr
    }
}
