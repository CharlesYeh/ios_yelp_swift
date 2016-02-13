//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var listingTableView: UITableView!

    var isMoreDataLoading: Bool = false
    var businesses: [Business]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        listingTableView.delegate = self
        listingTableView.dataSource = self
        listingTableView.rowHeight = UITableViewAutomaticDimension
        listingTableView.estimatedRowHeight = 120

        self.updateListing("")
    }
    
    func updateListing(term: String) {
        Business.searchWithTerm(
            term,
//            sort: filterType,
//            categories: categories,
            completion: { (businesses: [Business]!, error: NSError!) -> Void in
                
                self.businesses = businesses
            
                dispatch_async(dispatch_get_main_queue(), {
                    self.listingTableView.reloadData()
                })
        })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.updateListing(searchText)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listingTableViewCell", forIndexPath: indexPath) as! ListingTableViewCell
        
        let data = self.businesses[indexPath.row]
        
        cell.nameLabel.text = data.name
        
        cell.addressLabel.text = data.address
        cell.typeLabel.text = data.categories
        
        if let imageURL = data.imageURL {
            cell.iconImageView.setImageWithURL(imageURL)
        } else {
            cell.iconImageView.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }
        
        if let ratingImageURL = data.ratingImageURL {
            cell.ratingImageView.setImageWithURL(ratingImageURL)
        } else {
            cell.ratingImageView.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }
        
        if let reviewCount = data.reviewCount {
            cell.numReviewsLabel.text = "\(reviewCount) reviews"
        } else {
            cell.numReviewsLabel.text = ""
        }
        
        if let distance = data.distance {
            cell.distanceLabel.text = "\(distance)"
        } else {
            cell.distanceLabel.text = ""
        }
        
        cell.priceLabel.text = ""
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.businesses != nil {
            return self.businesses.count
        } else {
            return 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
