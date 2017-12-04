//
//  DailyannTableViewCell.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/24/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

/**
 The cell that shows one row in the DailyannTableView table
 */
class DailyannTableViewCell: BaseTableViewCell {


    @IBOutlet weak var titleLabel: UILabel!
    
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
        // sets the title, which is usually typed out like October 20, 2017
        self.titleLabel.text = article.title
    }

}
