//
//  DailyannTableViewCell.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/24/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit

class DailyannTableViewCell: BaseTableViewCell {


    @IBOutlet weak var titleLabel: UILabel!
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
        // sets the title, which is usually typed out like October 20, 2017
        self.titleLabel.text = article.title
    }

}
