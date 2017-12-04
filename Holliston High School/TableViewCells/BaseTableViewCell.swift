//
//  BaseTableViewCell.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/30/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

/**
 A base tableview cell. Used by the other tableViewCells. Provides a basic interface for the population of data into the cell's views
 */
class BaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var disclosureIcon: UIImageView!
    
    /** OVERRIDE IN SUBCLASSES */
    func fillCellWith(article: Article) {
    }
}
