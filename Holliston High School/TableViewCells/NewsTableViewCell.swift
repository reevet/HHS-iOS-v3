//
//  NewsTableViewCell.swift
//  Holliston High School
//
//  Created by Thomas Reeve on 11/26/17.
//  Copyright © 2017 Tom Reeve. All rights reserved.
//

import UIKit
import Kingfisher

class NewsTableViewCell: BaseTableViewCell {

    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func fillCellWith(article: Article) {
        // sets the article title e.g. "Fall Musical to be Performed This Thursday!"
        self.titleLabel.text = article.title
        
        // sets the post date of the article e.g. Tuesday, October 16, 2017
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, YYYY"
        self.dateLabel.text = dateFormatter.string(from: article.date)
        
        // sets the image into the thumbnail
        if (article.imgSrc != "") {
            let url = URL(string: article.imgSrc)
            // kf (below) is a Kingfisher method, a 3rd-party library that was
            // imported to simply the image downloading and caching
            self.thumbnailImage.kf.setImage(with: url)
        }
    }

}
