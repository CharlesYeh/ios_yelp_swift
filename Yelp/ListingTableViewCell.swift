//
//  ListingTableViewCell.swift
//  Yelp
//
//  Created by Charles Yeh on 2/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import AFNetworking
import UIKit

class ListingTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var numReviewsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}
