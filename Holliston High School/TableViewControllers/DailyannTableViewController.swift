//
//  DailyannTableViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/24/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

/* the tablecontroller that displays the list of schedules */
class DailyannTableViewController: BaseTableViewController {
    
    // the hamburger icon in the top left
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    /* starts the controller */
    override func viewDidLoad() {
        
        // sets the header image and gives it scrolling parallax animation
        self.tableView.addParallax(with: #imageLiteral(resourceName: "Theatre"), andHeight: 160)
        
        // sets the hamburger menu icon to show the side menu
        setSWRevealFor(button: menuButton)
        
        // self.type is defined in the superclass
        // this must be set BEFORE calling super.viewDidLoad()
        self.type = ArticleStore.StoreType.DAILY_ANN
        
        // run the superclasse's viewDidLoad
        super.viewDidLoad()
    }
    
    /* groups the articles into sections and rows, so that they will
     display under headers like "This Week" and "Next week"  */
    override func groupArticles(list: [Article]) -> [ArticleGroup] {
        
        var groupedList = [ArticleGroup]()  // the list of new sections/rows
        var currentWeek = -1    // the week-of-year number of the current section
        var currentHeader = ""  // the header string of the current section
        
        // gets today's week-of-year (e.g. Jan 1 = week 1, May 1 = week 20, etc.)
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        guard let todayWeek = calendar.dateComponents(in: TimeZone.current, from: Date()).weekOfYear else {
            print("Error calculating today's week-of-the-year")
            return groupedList
        }
        
        // loop through the articles in the list
        for article in list {
            
            // gets the date and week-of-year of this article
            let date = article.date
            let week = calendar.dateComponents(in: TimeZone.current, from: date).weekOfYear
            
            // if the article's week is not the current section's week, then
            // create a new section
            if (week != currentWeek) {
                
                // choose This Week, Last Week, Earlier, or blank
                if (week == todayWeek) {
                    currentHeader = "This Week"
                } else if (week == todayWeek - 1) {
                    currentHeader = "Last Week"
                } else if (week == todayWeek - 2){
                    currentHeader = "Earlier"
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
            let articleRow = ArticleGroup.ArticleRow(article: article,
                                                     cellType: ArticleGroup.ArticleRow.CellType.ARTICLE)
            
            let groupIndex = groupedList.count - 1   // the index of the last group in the array
            
            // add the row to the current section
            groupedList[groupIndex].articleRows.append(articleRow)
            
        }
        
        // return the newly grouped list
        return groupedList
    }

    /* when a row is clicked, this tells the soon-to-open detail screen
       which article to show */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DailyannDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                // get the article in the selected cell
                let selectedArticle = groupedArticles[indexPath.section].articleRows[indexPath.row].article
                // set the article into the detailViewController
                let controller = segue.destination as! DailyannDetailViewController
                controller.article = selectedArticle
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}
