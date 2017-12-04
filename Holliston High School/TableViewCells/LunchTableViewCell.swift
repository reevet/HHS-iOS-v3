//
//  LunchTableViewCell.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/22/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

/**
The cell that shows one row in the LunchTableView table
*/
class LunchTableViewCell: BaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    
    /**
     Fills the cell's views with article data
     - Parameter article: the article to display in the row
     */
    override func fillCellWith(article: Article) {
        // sets the lunch title e.g. "Cheeseburger"
        self.titleLabel.text = article.title
        
        // sets the date e.g Mon, Mov 12
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        self.dateLabel.text = dateFormatter.string(from: article.date)
        
        // hides the disclosure icon is there are no details to show
        if article.details == "" {
            self.disclosureIcon.image = nil
        }
    }

}
