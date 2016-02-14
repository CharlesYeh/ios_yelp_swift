//
//  FilterTableViewCell.swift
//  Yelp
//
//  Created by Charles Yeh on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    optional func switchCell(switchCell: FilterTableViewCell, didChangeValue value: Bool)
}
class FilterTableViewCell: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    
    var delegate: SwitchCellDelegate?
    
    @IBAction func switchValueChanged(sender: AnyObject) {
        delegate?.switchCell?(self, didChangeValue: cellSwitch.on)
    }
}
