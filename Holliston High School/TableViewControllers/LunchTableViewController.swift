//
//  LunchTableViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/22/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

/**
 The TableView Controller that displays the list of lunch menus
 */
class LunchTableViewController: BaseTableViewController {
    
    // the hamburger menu in the top left
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    /**
     Starts the controller
     */
    override func viewDidLoad() {
        
        // sets the header image and gives it scrolling parallax animation
        self.tableView.addParallax(with: #imageLiteral(resourceName: "Art lockers"), andHeight: 160)
        
        // sets the hamburger menu icon to show the side menu
        setSWRevealFor(button: menuButton)
        
        // self.type is defined in the superclass
        // this must be set BEFORE calling super.viewDidLoad()
        self.type = .LUNCH
        
        // run the superclasse's viewDidLoad
        super.viewDidLoad()
    }

    /**
     Groups the articles into sections and rows, so that they will display under headers like "This Week" and "Next week"
     - Parameter list: the array of articles to group
     - Returns: an array of ArticleGroups
     */
    override func groupArticles(list: [Article]) -> [ArticleGroup] {
        
        var groupedList = [ArticleGroup]()  // the list of new sections/rows
        var currentWeek = -1    // the week-of-year number of the current section
        var currentHeader = ""  // the header string of the current section
        
        // get today's week-of-year (e.g. Jan 1 = week 1, May 1 = week 20, etc.)
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let today = Date()
        guard let todayWeek = calendar.dateComponents(in: TimeZone.current, from: today).weekOfYear else {
            print("Error calculating today's week-of-the-year")
            return groupedList
        }
        
        // loop through the articles in the list
        for article in list {
            
            // the date and week-of-year of this article
            let date = article.date
            let week = calendar.dateComponents(in: TimeZone.current, from: date).weekOfYear
            
            // if the article's week is not the current section's week, then
            // create a new section
            if (week != currentWeek) {
                
                // choose This Week, Next Week, Later, or blank
                if (week == todayWeek) {
                    currentHeader = "This Week"
                } else if (week == todayWeek + 1) {
                    currentHeader = "Next Week"
                } else if (week == todayWeek + 2){
                    currentHeader = "Later"
                } else {
                    currentHeader = " "
                }
                
                // add a new blank ArticleGroup to the list, using the newly created header string
                groupedList.append(ArticleGroup(header: currentHeader, articleRows: [ArticleGroup.ArticleRow]()))
                
                // set the current week to the one we just added
                if let currentWeekOpt = week {
                    currentWeek = currentWeekOpt
                }
            }
            // create a new ArticleRow for this section
            let articleRow = ArticleGroup.ArticleRow(article: article, cellType: .ARTICLE)
            
            let groupIndex = groupedList.count - 1   // the index of the last group in the array
            
            // add the row to the current section
            groupedList[groupIndex].articleRows.append(articleRow)
            
            // if the article has details (and it should), add another row with the details.
            // This new row will expand/contract when its article is tapped
            if article.details != "" {
                let detailsRow = ArticleGroup.ArticleRow(article: article, cellType: .DETAIL)
                groupedList[groupIndex].articleRows.append(detailsRow)
            }
        }
        
        // return the newly grouped list
        return groupedList
    }
}

