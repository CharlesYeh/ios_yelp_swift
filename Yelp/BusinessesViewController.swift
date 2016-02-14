//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

protocol FiltersDelegate {
    func setFilters(deal: Bool, distance: Float, sortBy: CustomYelpSortMode, categories: [String])
}

enum CustomYelpSortMode: Int {
    case BestMatched = 0, Distance, HighestRated, MostReviewed
    
    func getYelpSortMode() -> YelpSortMode {
        switch (self) {
        case .MostReviewed:
            // we'll reorder anyways
            return YelpSortMode.HighestRated
        case .BestMatched:
            return YelpSortMode.BestMatched
        case .Distance:
            return YelpSortMode.Distance
        case .HighestRated:
            return YelpSortMode.HighestRated
        }
    }
}

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FiltersDelegate {

    @IBOutlet weak var listingTableView: UITableView!

    var isMoreDataLoading: Bool = false
    var businesses: [Business] = []
    
    var searchText = ""
    var deal = false
    var distance: Float = 0.0
    var sortBy: CustomYelpSortMode = .BestMatched
    var categories: [String] = []
    
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
    
    func setFilters(deal: Bool, distance: Float, sortBy: CustomYelpSortMode, categories: [String]) {
        self.deal = deal
        self.distance = distance
        self.sortBy = sortBy
        self.categories = categories
        
        updateListing(self.searchText)
    }
    
    func updateListing(term: String) {
        Business.searchWithTerm(
            term,
            sort: self.sortBy.getYelpSortMode(),
            categories: self.categories,
            deals: self.deal,
            completion: { (businesses: [Business]!, error: NSError!) -> Void in
                
                self.businesses = businesses
                if self.distance > 0 {
                    self.businesses = self.businesses.filter({ (business: Business) -> Bool in Float(business.distance ?? "0.0") <= self.distance
                    })
                }
                
                if self.sortBy == .MostReviewed {
                    self.businesses.sortInPlace({ (left: Business, right: Business) -> Bool in
                        return left.reviewCount?.integerValue > right.reviewCount?.integerValue
                    })
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.listingTableView.reloadData()
                })
        })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
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
        return self.businesses.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! FilterViewController
        vc.initSwitchStates(deal, distance: distance, sortBy: sortBy, categories: categories)

    }
    
}
