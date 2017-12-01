//
//  LunchTableViewCell.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/22/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

class LunchTableViewCell: BaseTableViewCell {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var disclosureIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
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
