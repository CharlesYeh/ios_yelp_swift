//
//  FilterViewController.swift
//  Yelp
//
//  Created by Charles Yeh on 2/12/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var filtersTableView: UITableView!
    
    let filters = [
        ("Deal", ["Offering a Deal"]),
        ("Distance", ["Auto", "0.3 miles", "1 mile", "5 miles", "20 miles"]),
        ("Sort By", ["Best Match", "Distance", "Rating", "Most Reviewed"]),
        ("Category", ["Miami", "Jacksonville"])]
    override func viewDidLoad() {
        super.viewDidLoad()

        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        cancelButton.targetForAction("cancelAction", withSender: self)
    }
    
    func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("filters.header")! as UITableViewHeaderFooterView
//        
////        header.headerLabel.text = self.filters[section].0
//        return header
//    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filters[section].1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("filters.item")! as! FilterTableViewCell
        cell.cellLabel.text = self.filters[indexPath.section].1[indexPath.row]
        return cell
    }

}
