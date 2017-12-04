//
//  LunchDetailsTableViewCell.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/22/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

/**
 The cell that shows one detail row in the SchedulesTableView table
 */
class LunchDetailsTableViewCell: BaseTableViewCell {

    @IBOutlet weak var detailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
     Fills the cell's views with article data
     - Parameter article: the article to display in the row
     */
    override func fillCellWith(article: Article) {
        self.detailsLabel.text = article.details
    }
}
