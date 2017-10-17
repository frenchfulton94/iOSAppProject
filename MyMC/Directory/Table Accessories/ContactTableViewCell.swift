//
//  ContactTableViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/21/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var conatactInfoView: UILabel! {
        didSet{
            self.conatactInfoView.numberOfLines = 0
        }
    }
  
}
