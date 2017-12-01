//
//  TableViewCell.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/20/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

class SchedulesTableViewCell: BaseTableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
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
        self.titleLabel.text = article.title
        
        // sets the date e.g. Monday, November 15, 2015
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, YYYY"
        self.dateLabel.text = dateFormatter.string(from: article.date)
        
        // gets the first letter of the title (equiv to substring[0..<1]
        let index = article.title.index(article.title.startIndex, offsetBy: 1)
        let initial = article.title[..<index]
        
        // chooses the correct icon based on the title's first letter
        switch initial {
        case "A":
            self.iconImage.image = #imageLiteral(resourceName: "A Day")
        case "B":
            self.iconImage.image = #imageLiteral(resourceName: "B Day")
        case "C":
            self.iconImage.image = #imageLiteral(resourceName: "C Day")
        case "D":
            self.iconImage.image = #imageLiteral(resourceName: "D Day")
        default:
            self.iconImage.image = #imageLiteral(resourceName: "Star")
        }
        
        // hides the disclosure icon if there are no details to display
        if article.details == "" {
            self.disclosureIcon.image = nil
        }
    }
}
