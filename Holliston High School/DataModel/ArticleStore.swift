//
//  ArticleStore.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/20/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import Foundation

/**
 A collection of articles of a given type (news, schedules, lunches, etc) and methods for querying and saving
 */
public class ArticleStore {
    
    //===================================================================================================
    // pragma MARK:  PROPERTIES
    //===================================================================================================

    /// the current list of articles
    var articleList: [Article] = []
    
    /// the type of articles to store (schedules, events, etc)
    let type: StoreType
    
    /**
    The types of articles that can be stored.
     - SCHEDULES: daily class rotation schedule, e.g. "A Day"
     - EVENTS: events on the school master calendar, e.g. "Fall Musical 6pm"
     - LUNCH: daily menus on the cafeteria's lunch menu, e.g. "Cheeseburger"
     - DAILY_ANN: daily PA announcements, posted by day, e.g. "October 30, 2017"
     - NEWS: a news article posted on the HHS website, e.g., "HHS Students Receive Writing Award"
     */
    enum StoreType {
        case SCHEDULES, EVENTS, LUNCH, DAILY_ANN, NEWS
    }
    
    /**
    The ways to sort articles.
     - GET_PAST: calls for articles from today and earlier
     - GET_FUTURE: calls for article from today and into the future
     */
    enum SortOrder {
        case GET_PAST, GET_FUTURE
    }
    
    /**
    Set a callback function for completing asynchronous data fetches. When a view controller builds an ArticleStore, it sets this function so the ArticleStore can trigger the controller's update
    */
    var onDataUpdate: ((_ list: [Article]) -> Void)?

    //===================================================================================================
    // pragma MARK:  INITIALIZER
    //===================================================================================================
    
    /**
     Initializes the article store
     */
    init (type: StoreType) {
        
        // sets the type for the store. This determines a whole bunch of other things,
        // like the download url, etc.
        self.type = type
        
        //get articles from the local storage, if available
        let list = loadStoreFromCache()
        if list != nil {
            self.articleList = list as [Article]!
        } else {
            downloadArticles()
        }
    }
    
    //===================================================================================================
    // pragma MARK:  ACCESSORS (sort of)
    //===================================================================================================

    /**
    Gets the urls and api keys for each store type. These are stored in a separate class that is NOT shared on GitHub, to keep the embedded API keys private
     */
    static func getFeedStringFor(storeType: StoreType) -> String {
        return FeedUrls.getFeedStringFor(storeType: storeType)
    }
    
    /**
    Gets the sortOrder associated with a store type
     */
    static func getSortOrderFor(storeType: StoreType) -> SortOrder{
        switch (storeType) {
        case ArticleStore.StoreType.SCHEDULES,
             ArticleStore.StoreType.LUNCH,
             ArticleStore.StoreType.EVENTS:
            // looks for articles from now into the future
            return ArticleStore.SortOrder.GET_FUTURE
            
        case ArticleStore.StoreType.DAILY_ANN,
             ArticleStore.StoreType.NEWS:
            // looks for articles from now into the past
            return ArticleStore.SortOrder.GET_PAST
        }
    }
    
    /**
     Provides the string name of a store based on its StoreType
     */
    static func getStoreNameFor(storeType: StoreType) -> String {
        switch storeType {
        case .SCHEDULES:
            return "schedules"
        case .EVENTS:
            return "events"
        case .LUNCH:
            return "lunch"
        case .DAILY_ANN:
            return "dailyann"
        case .NEWS:
            return "news"
        }
    }
    
    
    //===================================================================================================
    // pragma MARK:  QUERIES
    //===================================================================================================

    /**
    Provides the articles of the given store type
     - Returns: an array of articles
     */
    func queryArticles() -> [Article] {
        switch (type) {
            case ArticleStore.StoreType.SCHEDULES,
                 ArticleStore.StoreType.LUNCH,
                 ArticleStore.StoreType.EVENTS:
            return queryArticlesStarting(date: today())
            
            case ArticleStore.StoreType.DAILY_ANN,
                 ArticleStore.StoreType.NEWS:
            return queryArticles(limit: 40)
        }
    }
    
    /**
    Provides all articles on or after a certain date
     - Parameter date: the earliest date for the articles
     - Returns: an array of articles
    */
    func queryArticlesStarting(date: Date) -> [Article] {
        var list = [Article]()
        
        // loops through the list, keeping the articles on or after the date
        for article in articleList {
            let today = Date()
            let todayCal = Calendar(identifier: Calendar.Identifier.gregorian)
            let comparisonResult = todayCal.compare(today, to: article.date, toGranularity: Calendar.Component.day)
            if  comparisonResult == ComparisonResult.orderedSame || comparisonResult == ComparisonResult.orderedAscending {
                list.append(article)
            }
        }
        return list
    }
    
    /**
    Provides a limited number of articles
     - Parameter limit: the maximum number of articles to return
     - Returns: an array of articles
    */
    func queryArticles(limit: Int) -> [Article] {
        
        // if the articleList has fewer articles than "limit", then this won't try to append more articles than that
        let last = min(limit, articleList.count)
        
        // loops through and adds the required number of articles (stops at end or at limit)
        var returnList = [Article]()
        for i in 0..<last {
            returnList.append(articleList[i])
        }
        // returns the limited list
        return returnList
    }
    
    
    //===================================================================================================
    // pragma MARK:  CACHING
    //===================================================================================================

    /**
     Gets the filename and path of the archive file for this store
     -Returns: the path to the file
     */
    func articleArchivePath() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let storeName = ArticleStore.getStoreNameFor(storeType: type)
        let pathComponent = "articles-\(storeName).archive"
        return (documentDirectory + pathComponent)
    }
    
    /**
     Retreives the article list from local cache storage
     - Returns: an array of articles
     */
    func loadStoreFromCache() -> [Article]? {
        let path = articleArchivePath()
        let list = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Article]
        return list
    }
    
    /**
     Stores the article list to local cache storage
     */
    func saveStore() {
        
        let path = articleArchivePath()
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: path)
        
        let success = NSKeyedArchiver.archiveRootObject(articleList, toFile: path)
        let name = ArticleStore.getStoreNameFor(storeType: type)
        
        print("Results of saveStore for \(name): \(success)")
    }

    //===================================================================================================
    // pragma MARK:  DOWNLOADING
    //===================================================================================================

    /**
     Triggers a function to start a download, based on the store type
     */
    func downloadArticles() {
        switch (self.type) {
        case ArticleStore.StoreType.SCHEDULES,
             ArticleStore.StoreType.LUNCH,
             ArticleStore.StoreType.EVENTS:
            getArticlesFromGoogleCalendar()
            
        case ArticleStore.StoreType.DAILY_ANN:
            self.getArticlesFromGoogleSites()
            
        case ArticleStore.StoreType.NEWS:
            self.getArticlesFromBlogger()
        }
    }
    
    /**
     Sets up an asynchronous download of data using the Google Calendar API
     */
    func getArticlesFromGoogleCalendar() {
        // create a string of the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'00:00:00xxx"
        let today = Date()
        let todayString = dateFormatter.string(from: today)
        
        // get the url string for this store
        let baseFeedString = ArticleStore.getFeedStringFor(storeType: type)
        
        // add the date to the url to query only items today and later
        let feedUrlString = "\(baseFeedString)&timeMin=\(todayString)"
        
        // create a task that will run in a separate background thread,
        // without slowing down the UI
        let url = URL(string: feedUrlString)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            /* Begin definition async task function */
            
            //create the parser
            let parser = JsonGoogleCalendarParser()
            
            // if data was returned...
            if let data = data {
                // parse the data
                let list = parser.parse(data: data)
                self.processNewData(list: list)
            }
            /* End definition async task function */
        }
        
        // run the async task
        task.resume()
    }
    /**
     Sets up an asynchronous download of data using the Google Sites RSS feed
     */
    func getArticlesFromGoogleSites() {
        
        // get the url string for this store
        let url = URL(string: ArticleStore.getFeedStringFor(storeType: type))
        
        // create a task that will run in a separate background thread,
        // without slowing down the UI
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            /* Begin definition async task function */
            
            //create the parser
            let parser = XmlGoogleSitesParser()
            
            // if data was returned
            if let data = data {
                // parse the data
                let list = parser.parse(data: data)
                self.processNewData(list: list)
            }
            /* End definition async task function */

        }
        
        // run the async task
        task.resume()
    }
    
    /**
     Sets up an asynchronous download of data using the Blogger API
     */
    func getArticlesFromBlogger() {
        
        // get the url string for this store
        let baseFeedString = ArticleStore.getFeedStringFor(storeType: type)
        
        // create a task that will run in a separate background thread,
        // without slowing down the UI
        let url = URL(string: baseFeedString)
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            /* Begin definition async task function */
            
            //create the parser
            let parser = JsonBloggerParser()
            
            // if data was returned...
            if let data = data {
                // parse the data
                let list = parser.parse(data: data)
                self.processNewData(list: list)
            }
            /* End definition async task function */
        }
        
        // run the async task
        task.resume()
    }
    
    /**
     Saves the newly downloaded data, and notifies the store's owner
     */
    func processNewData(list: [Article]) {
        // ensure that at least one article was parsed
        guard list.count > 0 else {
            return
        }
        //store the new articles
        self.articleList = list
        
        // on the main UI thread, send the new articles to the store's owner
        DispatchQueue.main.async(execute: {
            self.onDataUpdate?(list)
        })
        
        print("Items downloaded for \(ArticleStore.getStoreNameFor(storeType: self.type))")
        // cache the store
        self.saveStore()
    }
    
    //===================================================================================================
    // pragma MARK:  FORMATTER
    //===================================================================================================

    /**
    A simple function to get today's date, but with the time set to 00:00:00
     - Returns: a date with the time set to 00:00:00
     */
    func today() -> Date {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = cal.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        return cal.date(from: components) as Date!
    }
}
