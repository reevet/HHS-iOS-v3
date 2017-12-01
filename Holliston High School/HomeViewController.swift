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
 * controls the data in the Home screen
 */
class HomeViewController: UIViewController, SWRevealViewControllerDelegate {

    // the hamburger menu button
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
    
    var debugNewsFirst = false
    
    var pushNewsIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets the menu button to open the side menu
        setSWRevealFor(button: menuButton)
        
        if self.pushNewsIndex >= 0 {
            self.performSegue(withIdentifier: "homeNewsPush", sender: self)
        }
        
        /* set up News section */
        
        // set the news article source
        let newsStore = ArticleStore(type: ArticleStore.StoreType.NEWS)
        // set the function that will fire when an asynchronous data download is finished
        newsStore.onDataUpdate = { [weak self] (list: [Article]) in
            self?.receiveNewsUpdate(list: list)
        }
        // query and load data into the correct places
        receiveNewsUpdate(list: newsStore.queryArticles(limit: 2))
        
        /* set up the Today section */
        
        // set up Today source
        let scheduleStore = ArticleStore(type: ArticleStore.StoreType.SCHEDULES)
        //set the function that will fire when an asychronous data download is finished
        scheduleStore.onDataUpdate = { [weak self] (list: [Article]) in
            self?.receiveSchedUpdate(list: list)
        }
        // query and load data into the correct places
        receiveSchedUpdate(list: scheduleStore.queryArticlesStarting(date: today()))
        
        /* set the Tomorrow source */
        
        // set up Tomorrow section
        let lunchStore = ArticleStore(type: ArticleStore.StoreType.LUNCH)
        // set the function that will fire when an asychronous data download is finished
        lunchStore.onDataUpdate = { [weak self] (list: [Article]) in
            self?.receiveLunchUpdate(list: list)
        }
        // query and load data into the correct places
        receiveLunchUpdate(list: lunchStore.queryArticlesStarting(date: today()))
        
        /* set up the Daily Announcement section */
        
        // set up the daily announcement source
        let dailyannStore = ArticleStore(type: ArticleStore.StoreType.DAILY_ANN)
        // set the function that will fire when an asychronous data download is finished
        dailyannStore.onDataUpdate = { [weak self] (list: [Article]) in
            self?.receiveDailyannUpdate(list: list)
        }
        // query and load data into the correct places
        receiveDailyannUpdate(list: dailyannStore.queryArticles(limit: 1))
    }
    
    // set up the menu button to trigger the side menu
    func setSWRevealFor(button: UIBarButtonItem) {
        if self.revealViewController() != nil {
            button.target = self.revealViewController()
            button.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    // a simple function to get today's date, but with the time set to 00:00:00
    func today() -> Date {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = cal.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        return cal.date(from: components) as Date!
    }
    
    /* fills data in the news section views */
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
    
    /* fills data in the today section */
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
    
    /* fills date into the tomorrow section */
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
    
    /* chooses an image for the icon, based on the first letter of the provided string */
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
    
    /* reacts to notice that some type of data download occurred */
    func receiveUpdate(storeType: ArticleStore.StoreType, list: [Article]) {
        if storeType == ArticleStore.StoreType.NEWS {
            receiveNewsUpdate(list: list)
        } else if storeType == ArticleStore.StoreType.DAILY_ANN {
            receiveDailyannUpdate(list: list)
        }  else if storeType == ArticleStore.StoreType.LUNCH {
            receiveLunchUpdate(list: list)
        } else if storeType == ArticleStore.StoreType.SCHEDULES {
            receiveSchedUpdate(list: list)
        }
    }
    
    /* reacts to notice that a news data download has occurred */
    func receiveNewsUpdate(list: [Article]) {
        
        // either accept the first article and show it, or hide the news section
        if list.count >= 1 {
            newsArticle = list[0]
            
            // TODO: Remove this debug code
            if debugNewsFirst == true {
                newsArticle = list[1]
                debugNewsFirst = false;
            }
            // END debug code */
            
            newsView.isHidden = false
            fillNewsInfo()
        } else {
            newsView.isHidden = true
        }
    }
    
    /* reacts to notice that a schedule data download has occurred */
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
    
    /* reacts to notice that a lunch data download has occurred */
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
    /* reacts to notice that a daily announcements data download has occurred */
    func receiveDailyannUpdate(list: [Article]) {
        
        // if there is at least one daily announcement post, keep it
        guard list.count > 0 else {
            return
        }
        todayDailyannArticle = list[0]
        fillTodayInfo()
    }
    
    /* determines if the most recent daily announcement post belongs with the
       schedule being shown in the today section */
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeNewsPush" {
            let controller = segue.destination as! NewsDetailViewController
            if self.pushNewsIndex >= 0 {
                controller.pushNewsIndex = self.pushNewsIndex
                self.pushNewsIndex = -1
            } else {
                controller.article = newsArticle
            }
            controller.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == "homeDailyannPush" {
            let controller = segue.destination as! DailyannDetailViewController
            //article not set. Use default (most current post)
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    /* formats the dates */
    func formatDate(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMMM d, YYYY"
        return df.string(from: date)
    }
}
