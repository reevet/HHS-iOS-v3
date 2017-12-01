//
//  BaseTableViewCell.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/30/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /** OVERRIDE IN SUBCLASSES */
    func fillCellWith(article: Article) {
    }

}
