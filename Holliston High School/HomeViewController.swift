//
//  HomeViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/27/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit
import SWRevealViewController
import SwiftSoup

/**
 * Controls the data in the Home screen
 */
class HomeViewController: UIViewController, SWRevealViewControllerDelegate {

    //===================================================================================================
    // pragma MARK:  PROPERTIES
    //===================================================================================================
    
    /// the hamburger menu button
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // items in the News section
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var newsDateLabel: UILabel!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsSnippetLabel: UILabel!
    @IBOutlet weak var newsThumbnailImage: UIImageView!
    
    // items in the first scheduled section (nicknamed "Today"),
    // although it might not really be today
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var todaySched: UILabel!
    @IBOutlet weak var todayLunch: UILabel!
    @IBOutlet weak var todayIconImage: UIImageView!
    @IBOutlet weak var todayDailyannView: UIView!
    
    // items in the second schedule section (nicknamed "Tomorrow"),
    // although it might not really be tomorrow
    @IBOutlet weak var tomorrowView: UIView!
    @IBOutlet weak var tomorrowDate: UILabel!
    @IBOutlet weak var tomorrowSched: UILabel!
    @IBOutlet weak var tomorrowLunch: UILabel!
    @IBOutlet weak var tomorrowIconImage: UIImageView!

    // the articles to be displayed (see class DataModel...Article)
    var newsArticle: Article? = nil
    var todaySchedArticle: Article? = nil
    var todayLunchArticle: Article? = nil
    var tomorrowSchedArticle: Article? = nil
    var tomorrowLunchArticle: Article? = nil
    var todayDailyannArticle: Article? = nil
    
    /// a tracker to know which news article to be pushed through to the detailview. Usually used in response to a cloud notification. The value represents the index position in the news article array, where 0 = most recent article. -1 represents "no article being pushed."
    var pushNewsIndex = -1
    
    //===================================================================================================
    // pragma MARK:  SETUP
    //===================================================================================================
    
    /**
     Sets up the Home display
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets the menu button to open the side menu
        setSWRevealFor(button: menuButton)
        
        if self.pushNewsIndex >= 0 {
            self.performSegue(withIdentifier: "homeNewsPush", sender: self)
        }
        
        /* set up News section */
        
        // set the news article source
        let newsStore = ArticleStore(type: .NEWS)
        // set the function that will fire when an asynchronous data download is finished
        newsStore.onDataUpdate = { [weak self] (list: [Article]) in
            self?.receiveNewsUpdate(list: list)
        }
        // query and load data into the correct places
        receiveNewsUpdate(list: newsStore.queryArticles(limit: 2))
        
        /* set up the Today section */
        
        // set up Today source
        let scheduleStore = ArticleStore(type: .SCHEDULES)
        //set the function that will fire when an asychronous data download is finished
        scheduleStore.onDataUpdate = { [weak self] (list: [Article]) in
            self?.receiveSchedUpdate(list: list)
        }
        // query and load data into the correct places
        receiveSchedUpdate(list: scheduleStore.queryArticlesStarting(date: today()))
        
        /* set the Tomorrow source */
        
        // set up Tomorrow section
        let lunchStore = ArticleStore(type: .LUNCH)
        // set the function that will fire when an asychronous data download is finished
        lunchStore.onDataUpdate = { [weak self] (list: [Article]) in
            self?.receiveLunchUpdate(list: list)
        }
        // query and load data into the correct places
        receiveLunchUpdate(list: lunchStore.queryArticlesStarting(date: today()))
        
        /* set up the Daily Announcement section */
        
        // set up the daily announcement source
        let dailyannStore = ArticleStore(type: .DAILY_ANN)
        // set the function that will fire when an asychronous data download is finished
        dailyannStore.onDataUpdate = { [weak self] (list: [Article]) in
            self?.receiveDailyannUpdate(list: list)
        }
        // query and load data into the correct places
        receiveDailyannUpdate(list: dailyannStore.queryArticles(limit: 1))
    }
    
    /**
     Sets up the menu button to trigger the side menu
     */
    func setSWRevealFor(button: UIBarButtonItem) {
        if self.revealViewController() != nil {
            button.target = self.revealViewController()
            button.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    /**
     Sets a date for today, but with time 00:00:00.
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
    
    //===================================================================================================
    // pragma MARK:  DATA POPULATION
    //===================================================================================================

    /**
     Fills data in the news section views
     */
    func fillNewsInfo() {
        
        // hide the news section if there's no article or date
        guard let date = newsArticle?.date else {
            newsView.isHidden = true
            return
        }
        
        // set date, title, and details
        newsDateLabel.text = formatDate(date: date)
        newsTitleLabel.text = newsArticle?.title
        
        
        do {
            if let details = newsArticle?.details {
                
                // strip HTML for the snippet
                let doc: Document = try SwiftSoup.parse(details)
                let strippedDetails = try doc.text()
                newsSnippetLabel.text = strippedDetails
            }
        }
        catch {
            print("Error: details not parsed properly")
        }
        // if an image is available, show it
        if let imgSrc = newsArticle?.imgSrc {
            let newsImgUrl = URL(string: imgSrc)
            newsThumbnailImage.kf.setImage(with: newsImgUrl)
        }
        
        // refresh the view to show the new data
        newsView.setNeedsDisplay()
    }
    
    /**
     Fills data in the today section
     */
    func fillTodayInfo() {
        
        // hide the today section is there's no article or date
        guard let date = todaySchedArticle?.date else {
            todayView.isHidden = true
            return
        }
        
        // set title, date, lunch
        todayDate.text = formatDate(date: date)
        todaySched.text = todaySchedArticle?.title
        todayLunch.text = todayLunchArticle?.title
        
        // set the icon, based on the first letter of the schedule title
        todayIconImage.image = getIcon(title: (todaySchedArticle?.title)!)
        
        // if today's daily announcements are posted, show the icon
        if dailyannIsPosted() == true {
            todayDailyannView.isHidden = false
        } else {
            todayDailyannView.isHidden = true
        }
        
        // refresh the view to show the new data
        todayView.setNeedsDisplay()
    }
    
    /**
     Fills date into the tomorrow section
     */
    func fillTomorrowInfo() {
        
        // hide the tomorrow section if there's no article or date
        guard let date = tomorrowSchedArticle?.date else {
            tomorrowView.isHidden = true
            return
        }
        
        // set title, date, lunch
        tomorrowDate.text = formatDate(date: date)
        tomorrowSched.text = tomorrowSchedArticle?.title
        tomorrowLunch.text = tomorrowLunchArticle?.title
        
        //set the icon, based on the first letter of the schedule title
        tomorrowIconImage.image = getIcon(title: (tomorrowSchedArticle?.title)!)
        
        // refresh the view to show the new data
        tomorrowView.setNeedsDisplay()
    }
    
    /**
     Chooses an image for the icon, based on the first letter of the provided string
     */
    func getIcon(title: String) -> UIImage {
        
        //create an index from the start, one letter long
        let index = title.index(title.startIndex, offsetBy: 1)
        let initial = title[..<index]
        
        // choose the appropriate image
        switch initial {
        case "A":
            return #imageLiteral(resourceName: "A Day")
        case "B":
            return #imageLiteral(resourceName: "B Day")
        case "C":
            return #imageLiteral(resourceName: "C Day")
        case "D":
            return #imageLiteral(resourceName: "D Day")
        default:
            return #imageLiteral(resourceName: "Star")
        }
    }
    
    /**
     Determines if the most recent daily announcement post belongs with the
     schedule being shown in the today section
     - Returns: TRUE if the post's publish date matches "today's" schedule date
     */
    func dailyannIsPosted() -> Bool {
        guard let article = todayDailyannArticle else {
            return false
        }
        guard let schedArticle = todaySchedArticle else {
            return false
        }
        //get the dates of the dailyann post and the schedule post
        let schedDate = schedArticle.date
        let dailyannDate = article.date
        
        //determine if they are the same (down to the day level "granularity")
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let comparisonResult = cal.compare(schedDate, to:dailyannDate, toGranularity:Calendar.Component.day)
        
        // return the result
        if comparisonResult == ComparisonResult.orderedSame {
            return true
        } else {
            return false
        }
    }
    
    //===================================================================================================
    // pragma MARK:  DOWNLOAD RESPONSE
    //===================================================================================================

    /**
     Responds to notice that some type of data download occurred
     - Parameter storeType: the type of articles received
     - Parameter list: the list of articles
     */
    func receiveUpdate(storeType: ArticleStore.StoreType, list: [Article]) {
        if storeType == .NEWS {
            receiveNewsUpdate(list: list)
            
        } else if storeType == .DAILY_ANN {
            receiveDailyannUpdate(list: list)
            
        }  else if storeType == .LUNCH {
            receiveLunchUpdate(list: list)
            
        } else if storeType == .SCHEDULES {
            receiveSchedUpdate(list: list)
            
        }
    }
    
    /**
     Responds to notice that a news data download has occurred
     - Parameter list: the list of articles
     */
    func receiveNewsUpdate(list: [Article]) {
        
        // either accept the first article and show it, or hide the news section
        if list.count >= 1 {
            newsArticle = list[0]
            
            newsView.isHidden = false
            fillNewsInfo()
        } else {
            newsView.isHidden = true
        }
    }
    
    /**
     Responds to notice that a schedule data download has occurred
     - Parameter list: the list of articles
     */
    func receiveSchedUpdate(list: [Article]) {
        
        // either accept the first article for today and show it, or hide the section
        if list.count >= 1 {
            todaySchedArticle = list[0]
            todayView.isHidden = false
            fillTodayInfo()
        } else {
            todayView.isHidden = true
        }
        
        // either accept the second article for tomorrow and show it, or hide the section
        if list.count >= 2 {
            tomorrowSchedArticle = list[1]
            tomorrowView.isHidden = false
            fillTomorrowInfo()
        } else {
            tomorrowView.isHidden = true
        }
    }
    
    /**
     Responds to notice that a lunch data download has occurred
     - Parameter list: the list of articles
     */
    func receiveLunchUpdate(list: [Article]) {
        
        // either accept the first article and show it, or hide the section
        if list.count >= 1 {
            todayLunchArticle = list[0]
            todayLunch.isHidden = false
            fillTodayInfo()
        } else {
            todayLunch.isHidden = true
        }
        
        // either accept the second article and show it, or hide the section
        if list.count >= 2 {
            tomorrowLunchArticle = list[1]
            tomorrowLunch.isHidden = false
            fillTomorrowInfo()
        }
    }
    /**
     Responds to notice that a dailyann data download has occurred
     - Parameter list: the list of articles
     */
    func receiveDailyannUpdate(list: [Article]) {
        
        // if there is at least one daily announcement post, keep it
        guard list.count > 0 else {
            return
        }
        todayDailyannArticle = list[0]
        fillTodayInfo()
    }
    
    //===================================================================================================
    // pragma MARK:  HELPERS AND FORMATTERS
    //===================================================================================================
    
    /**
     Prepare data transfer when pushing to another view
     - Parameter segue: the segue to be performed
     - Parameter sender: the class that triggered the function
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // if pushing to a news DetailView...
        if segue.identifier == "homeNewsPush" {
            let controller = segue.destination as! NewsDetailViewController
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            // if there is an article ready, push it. Otherwise, push the most recent article
            if self.pushNewsIndex >= 0 {
                controller.pushNewsIndex = self.pushNewsIndex
                self.pushNewsIndex = -1
            } else {
                controller.article = newsArticle
            }

        // else if pushing to the daily announcements DetailView...
        } else if segue.identifier == "homeDailyannPush" {
            let controller = segue.destination as! DailyannDetailViewController
            controller.navigationItem.leftItemsSupplementBackButton = true
            //article not set. Use default (most current post)
        }
    }
    
    /**
     Formats the date
     */
    func formatDate(date: Date) -> String {
        let df = DateFormatter()
        
        // e.g. Monday, December 4, 2017
        df.dateFormat = "EEEE, MMMM d, YYYY"
        return df.string(from: date)
    }
}
