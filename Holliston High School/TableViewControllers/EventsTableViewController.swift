//
//  EventsTableViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/23/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

/* the tablecontroller that displays the list of school events */
class EventsTableViewController: BaseTableViewController {
    
    // the hamburger icon in the top left
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    /* starts the controller */
    override func viewDidLoad() {
        
        // sets the header image and gives it scrolling parallax animation
        self.tableView.addParallax(with: #imageLiteral(resourceName: "Singers"), andHeight: 160)
        
        // sets the hamburger menu icon to show the side menu
        setSWRevealFor(button: menuButton)
        
        // self.type is defined in the superclass
        // this must be set BEFORE calling super.viewDidLoad()
        self.type = ArticleStore.StoreType.EVENTS
        
        // run the superclasse's viewDidLoad
        super.viewDidLoad()
    }
    
    /* groups the articles into sections and rows, so that they will
     display under headers like "Today" and "Tomorrow"  */
    override func groupArticles(list: [Article]) -> [ArticleGroup] {
        
        var groupedList = [ArticleGroup]()  // the list of new sections/rows
        var currentDay = -1      // the day of the current section
        var currentHeader = ""   // the header string of the current section
        
        // gets today's date (e.g. 22 for Nov. 22)
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let today = Date()
        guard let todayDay = calendar.dateComponents(in: TimeZone.current, from: today).day else {
            print("Error calculating today's date")
            return groupedList
        }
        
        //loops through the articles in the list
        for article in list {
            
            // gets the date of the article
            let date = article.date
            let day = calendar.dateComponents(in: TimeZone.current, from: date).day
            
            // if the article's date is not the current sections's date,
            // then create a new section
            if (day != currentDay) {
                
                // choose Today, Tomorrow, or a formatted date
                if (day == todayDay) {
                    currentHeader = "Today"
                } else if (day == todayDay + 1) {
                    currentHeader = "Tomorrow"
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEEE, MMMM d"
                    currentHeader = dateFormatter.string(from: date)
                }
                
                // add a new blank ArticleGroup to the list, using the newly created header string
                groupedList.append(ArticleGroup(header: currentHeader, articleRows: [ArticleGroup.ArticleRow]()))
                
                // set the current week to the one we just added
                if let currentDayOpt = day {
                    currentDay = currentDayOpt
                }
            }
            
            let groupIndex = groupedList.count - 1   // the index of the last group in the array
            
            // create a new ArticleRow for this section
            groupedList[groupIndex].articleRows.append(
                ArticleGroup.ArticleRow(article: article, cellType: ArticleGroup.ArticleRow.CellType.ARTICLE))
            
            // if the article has details (and it should), add another row with the details.
            // This new row will expand/contract when its article is tapped
            if article.details != "" {
                groupedList[groupIndex].articleRows.append(
                    ArticleGroup.ArticleRow(article: article, cellType: ArticleGroup.ArticleRow.CellType.DETAIL))
            }
        }
        
        // return the newly grouped list
        return groupedList
    }
    
}


