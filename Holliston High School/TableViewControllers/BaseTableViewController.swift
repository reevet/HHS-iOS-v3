//
//  TableViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/22/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit
import APParallaxHeader
import SWRevealViewController

/**
 The superclass for most of the tableview controllers in this app.
 */
class BaseTableViewController: UITableViewController, APParallaxViewDelegate, SWRevealViewControllerDelegate {
    
    //===================================================================================================
    // pragma MARK:  PROPERTIES
    //===================================================================================================

    /// the type of ArticleStore.  Default = SCHEDULES, but subclasses should ALWAYS declare their own type
    var type = ArticleStore.StoreType.SCHEDULES
    
    /** The list of organized articles, grouped with headers (one per week) and with cellType and visibility. Each row is either the main row (ARTICLE) or a DETAIL row, which appears when the main row is clicked
    
    See: ArticleGroup at the end of this file */
    var groupedArticles = [ArticleGroup]()
    
    /// the ArticleStore that holds the table's data
    var articleStore: ArticleStore?
    
    //===================================================================================================
    // pragma MARK:  SETUP
    //===================================================================================================

    /**
     Starts the controller
     */
    override func viewDidLoad() {
        
        // gets articles from the store
        let articles = getArticlesFromStore()
        
        // groups the articles into sections (by week or by day, depending
        // on the subclass
        groupedArticles = groupArticles(list: articles)
        
        // run the superclasse's viewDidLoad
        super.viewDidLoad()
    }
    
    /**
     Sets the hamburger menu button to show the side menu
     - Parameter button: the button to set
     */
    func setSWRevealFor(button: UIBarButtonItem) {
        if self.revealViewController() != nil {
            button.target = self.revealViewController()
            button.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    //===================================================================================================
    // pragma MARK:  DATA
    //===================================================================================================

    /**
     Gets the articles from the store
     -Returns: an array of articles
     */
    func getArticlesFromStore() ->  [Article] {
        
        // create the article store for this table
        articleStore = ArticleStore.init(type: self.type)
        
        //ensure that the store was created
        guard let store = articleStore else {
            print("Error creating articleStore")
            return [Article]()
        }
        
        // set the callback for the store, so any async downloads
        // can notify this tableviewcontroller
        store.onDataUpdate = { [weak self] (list: [Article]) in
            self?.receiveDataUpdate(list: list)
        }
        
        // query the store for articles
        let articles = store.queryArticles()
        
        // return the newly obtained article array
        return articles
    }
    
    /**
     Groups the articles into sections and rows, so that they will
     display under headers like "This Week" and "Next week."
     
     CAN BE OVERRIDDEN BY SUBCLASS -
     This superclass version simply drops all articles into one group
     - Parameter list: an array of articles
     - Returns: an array of ArticleGroups
     */
    func groupArticles(list: [Article]) -> [ArticleGroup] {
        
        var articleRows = [ArticleGroup.ArticleRow]()
        
        for article in list {
            let newRow = ArticleGroup.ArticleRow(article: article, cellType: .ARTICLE)
            articleRows.append(newRow)
        }
        
        var groupedList = [ArticleGroup]()
        let firstGroup = ArticleGroup(header: "", articleRows: articleRows)
        groupedList.append(firstGroup)
        
        return groupedList
    }
    
    /**
     Responds to notification that a data download just finished
     - Parameter list: the newly downloaded articles
     */
    func receiveDataUpdate(list: [Article]) {
        if list.count > 0 {
            self.groupedArticles = groupArticles(list: list)
            self.tableView.reloadData()
        }
    }
    
    /**
     Gets the article associated with the given index path (section# and row#).
     - Parameter indexPath: the index path containing the section and row numbers
     - Returns: an article, or nil if not found
     */
    func getArticleFor(indexPath: IndexPath) -> Article? {
        let s = indexPath.section
        let r = indexPath.row
        
        // as long as s and r are valid, get the article
        if s < groupedArticles.count  {
            let group = groupedArticles[s]
            let rows = group.articleRows
            if r < rows.count {
                return rows[r].article
            }
        }
        print("Error: can't find article section=\(s) row=\(r)")
        return nil
    }
    
    /**
     Gets the cell type for the given index path (section number and row number). This determines whether a row is an article row or a collapsable detail row
     - Parameter indexPath: the index path containing the section and row numbers
     - Returns the CellType, either .ARTICLE or .DETAIL
     */
     func getCellTypeFor(indexPath: IndexPath) -> ArticleGroup.ArticleRow.CellType? {
        let s = indexPath.section
        let r = indexPath.row
        
        // as long as s and r are valid, get the cell type
        if s < groupedArticles.count {
            let group = groupedArticles[s]
            let rows = group.articleRows
            if r < rows.count {
                return rows[r].cellType
            }
        }
        print("Error: can't find cellType section=\(s) row=\(r)")
        return nil
    }
    
    /**
     Gets the cellIdentifier for a given index path. The cell identifier tells the tableView which type of row is to be built.
     - Parameter cellType: the CellType of the row (.ARTICLE or .DETAIL)
     - Returns: a string with the cell's reuse identifier label (e.g. "ScheduleCell" etc.)
     */
    func getIdentifier(cellType: ArticleGroup.ArticleRow.CellType) -> String {
        switch cellType {
        case .ARTICLE:
            switch self.type {
            case .SCHEDULES:
                return "SchedulesCell"
            case .LUNCH :
                return "LunchCell"
            case .EVENTS:
                return "EventsCell"
            case .DAILY_ANN:
                return "DailyannCell"
            case .NEWS:
                return "NewsCell"
            }
        case .DETAIL:
            switch self.type {
            case .SCHEDULES:
                return "SchedulesDetailsCell"
            case .LUNCH :
                return "LunchDetailsCell"
            case .EVENTS:
                return "EventsDetailsCell"
            case .DAILY_ANN:
                return "ERROR"
            case .NEWS:
                return "ERROR"
            }
        }
    }
    
    //===================================================================================================
    // pragma MARK:  TABLEVIEW
    //===================================================================================================

    /**
     Tells the tableView the number of sections to show
     - Parameter tableVIew: the tableView
     - Returns: the number of sections
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.groupedArticles.count
    }
    
    /**
     Tells the tableView how to fill in the section header text.
     - Parameter tableVIew: the tableView
     - Parameter section: the section number
     - Returns: the string to go into the header
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.groupedArticles[section].header
    }
    
    /**
     Tells the tableView the number of rows in a given section
     - Parameter tableVIew: the tableView
     - Paramter section: the section number
     - Returns: the number of rows in the section
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupedArticles[section].articleRows.count
    }
    
    
    /**
     Tells the tableView how to create and fill in a row.
     - Parameter tableVIew: the tableView
     - Parameter indexPath: the index path of the cell
     - Returns the filled-in cell
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get the article and row type
        let article = getArticleFor(indexPath: indexPath)
        let cellType = getCellTypeFor(indexPath: indexPath)
        
        // create either an ARTICLE row or a DETAIL row
        let cellIdentifier = getIdentifier(cellType: cellType!)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! BaseTableViewCell
        cell.fillCellWith(article: article!)
        
        return cell
    }
    
    /**
     Provides the row height of cells. This is used to shrink and grow expandable detail cell rows if appropriate.
     - Parameter tableVIew: the tableView
     - Parameter: the index path of the row
     - Return: the row height
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = self.groupedArticles[indexPath.section].articleRows[indexPath.row].cellType
        
        // if this is a detail row, base the height on whether or not the row is hidden
        if cellType == .DETAIL {
            let visible = self.groupedArticles[indexPath.section].articleRows[indexPath.row].visible
            if visible {
                return UITableViewAutomaticDimension
            } else {
                return 0.0
            }
        }
        
        // all other rows are auto-height
        return UITableViewAutomaticDimension
    }
    
    /**
     Formats the section header text.
     - Parameter tableVIew: the tableView
     - Parameter view: the view for the header
     - Parameter section: the section number
     */
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let view = view as! UITableViewHeaderFooterView
        view.textLabel?.textColor = UIColor.white
    }
    
    /**
     Formats the section header background.
     - Parameter tableVIew: the tableView
     - Parameter section: the section number
     - Returns: the header view
     */
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 200))
        view.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.contentView.backgroundColor = UIColor(red: (181/255.0), green: (30/255.0), blue:(18/255.0), alpha: 1.0)
        return view
    }

    
    /**
     Responds to a click in a row. This controls the expand/contract motion of detail rows.
     
     This function CAN be OVERRIDDEN to remove the expand/contract is desired
     - Parameter tableView: the tableView
     - Parameter indexPath: the index path of the clicked row
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get the cell type (ARTICLE or DETAIL) of the clicked row
        let cellType = groupedArticles[indexPath.section].articleRows[indexPath.row].cellType
        
        let rowNum = indexPath.row
        var articleRowNum = -1   // will hold the row number of the article
        var detailRowNum = -1    // will hold the row number of the detail (if any, usually articleRowNum+1)
        
        // base calculations on whether it was the ARTICLE or the DETAIL that was clicked
        switch cellType {
        case .ARTICLE:
            
            // since the clicked row is an article, the articleRowNum = THIS row, and
            // (possibly) the detailRowNum will be the NEXT row
            articleRowNum = rowNum
            
            // check to make sure that a detail row exists immediately following this article
            if articleRowNum + 1 < groupedArticles[indexPath.section].articleRows.count &&
                groupedArticles[indexPath.section].articleRows[articleRowNum + 1].cellType == .DETAIL {
                
                //if so, set the detailRowNumber to the NEXT row
                detailRowNum = articleRowNum + 1
            }
            
        case .DETAIL:
            
            // since the clicked row is a detail, the articleRowNum = PREVIOUS row, and
            // the detailRowNum will be THIS row
            articleRowNum = rowNum - 1
            detailRowNum = rowNum
        }
        
        // if there is a detail row...
        if detailRowNum >= 0 {
            
            // toggle the detail row's visiblility
            groupedArticles[indexPath.section].articleRows[detailRowNum].visible = !groupedArticles[indexPath.section].articleRows[detailRowNum].visible
            
            let articleIndexPath = IndexPath(row: articleRowNum, section: indexPath.section)
            let detailIndexPath = IndexPath(row: detailRowNum, section: indexPath.section)
            
            // refresh the show/hide of the detail row
            tableView.reloadRows(at: [detailIndexPath], with: UITableViewRowAnimation.automatic)
            
            // spin the disclosure icon arrow ^
            animateDisclosure(tableView: tableView, indexPath: articleIndexPath)
        }
    }
    
    /**
     Animates the disclosure icon when expanding/contracting the details row
     */
    func animateDisclosure(tableView: UITableView, indexPath: IndexPath) {
        
        switch (self.type) {
        case .SCHEDULES, .LUNCH, .EVENTS:
            let cell = tableView.cellForRow(at: indexPath) as! BaseTableViewCell
            if groupedArticles[indexPath.section].articleRows[indexPath.row + 1].visible {
                cell.disclosureIcon.rotate180Degrees(duration: 0.3, direction: "point up")
            } else {
                cell.disclosureIcon.rotate180Degrees(duration: 0.3, direction: "point down")
            }
        default:
            break
            //.DAILY_ANN:
            //.NEWS:
            //do nothing - no disclosure icon
        }
    }
    


    
    //===================================================================================================
    // pragma MARK:  STRUCT ARTICLEGROUP
    //===================================================================================================

    /**
     The grouping structure, used to store articles in nested groups, for purposes of tableView sorting and indicator for whether a row is an ARTICLE or DETAIL
     */
    struct ArticleGroup {
        
        // each ArticleGroup is a section. The section includes a header string and an array of ArticleRows
        var header = ""
        var articleRows = [ArticleRow]()
        
        init(header: String, articleRows: [ArticleRow]) {
            self.header = header
            self.articleRows = articleRows
            
        }
        
        /// Each ArticleRow contains one Article, one cellType (ARTICLE or DETAIL), and one visibility indicator
        struct ArticleRow {
            enum CellType {
                case ARTICLE, DETAIL
            }
            let article: Article
            let cellType: CellType
            var visible: Bool
            
            init(article: Article, cellType: CellType) {
                self.article = article
                self.cellType = cellType
                self.visible = true
                if cellType == .DETAIL {
                    //sets initial visibility to false (compressed) for detail rows
                    self.visible = false
                }
            }
        }
    }
}

//===================================================================================================
// pragma MARK:  ANIMATION EXTENSIONS
//===================================================================================================

extension UIView {
    /**
    A convenience method for animating a view 180 degrees.
    - Parameter duration: the length of time for the animation to take
    - Parameter direction: either "point up" or "point down", depending on how the view should be in its final state
    */
    func rotate180Degrees(duration: CFTimeInterval = 1.0, direction: String) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        //assume "point up"
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi)
        if (direction == "point down") {
            rotateAnimation.fromValue = CGFloat(Double.pi)
            rotateAnimation.toValue = 0.0
        }
        
        rotateAnimation.duration = duration
        
        self.layer.add(rotateAnimation, forKey: nil)
        
        self.transform = CGAffineTransform(rotationAngle: rotateAnimation.toValue as! CGFloat)
    }
}


