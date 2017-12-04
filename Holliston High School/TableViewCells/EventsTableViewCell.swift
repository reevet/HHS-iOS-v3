//
//  EventsTableViewCell.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/23/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

/**
 The cell that shows one row in the EventsTableView table
 */
class EventsTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
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
        // sets the event title e.g. Open House Semester 1
        self.titleLabel.text = article.title
        
        // sets the time for the event e.g. 10:12 am or All day
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        if let todayHour = calendar.dateComponents(in: TimeZone.current, from: article.date).hour {
            
            // events that start at midnight (hour == 0) are "All day" events
            if todayHour == 0 {
                self.timeLabel.text = "All day"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm"
                self.timeLabel.text = dateFormatter.string(from: article.date)
            }
        }
        
        // hides the disclosure icon if there are no details to display
        if article.details == "" {
            self.disclosureIcon.image = nil
        }
    }
    
}

