//
//  NewsTableViewController.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/26/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit
import Kingfisher  // assists with downloading and caching images

/**
 The TableView Controller that displays the list of news posts
 */
class NewsTableViewController: BaseTableViewController {

    // the hamburger icon in the top left
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    /* starts the controller */
    override func viewDidLoad() {
        
        // sets the header image and gives it scrolling parallax animation
        self.tableView.addParallax(with: #imageLiteral(resourceName: "Football"), andHeight: 160)
        
        // sets the hamburger menu icon to show the side menu
        setSWRevealFor(button: menuButton)
        
        // self.type is defined in the superclass
        // this must be set BEFORE calling super.viewDidLoad()
        self.type = ArticleStore.StoreType.NEWS
        
        // gets articles from the store
        let articles = getArticlesFromStore()
        
        // groups the articles into sections (by week or by day, depending
        // on the subclass
        groupedArticles = groupArticles(list: articles)
        
        // run the superclasse's viewDidLoad
        super.viewDidLoad()
    }
    
    /**
     This method is set up to allow grouping of articles in sections. However, the news posts are not grouped, we this simply uses the superclass to adds all articles to a single group. This grouping is overkill, but is left in place so that this class is similar to other TableViewController subclasses
     - Parameter list: the array of articles to group
     - Returns an array of ArticleGroups. In this case, contains only a single group
     */
    override func groupArticles(list: [Article]) -> [ArticleGroup] {
        
        // creates a sectionlist with only a single section in list
        return super.groupArticles(list: list)
    }
    
    /* overrides detail row expand/contract animation, since this tableView
     shows details in a new window, not in an expandable row */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //do nothing. This is here intentionally. Do not delete this overridden method
    }
    
    /* when a row is clicked, this tells the soon-to-open detail screen
     which article to show */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewsDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                // gets the article in the selected cell
                let selectedArticle = groupedArticles[indexPath.section].articleRows[indexPath.row].article
                // set the article into the detailViewController
                let controller = segue.destination as! NewsDetailViewController
                controller.article = selectedArticle
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}



