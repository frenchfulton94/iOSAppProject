//
//  QuadrangleStaffTableViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 6/8/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class QuadrangleStaffTableViewCell: UITableViewCell {

    @IBOutlet weak var staffImageView: UIView!
    @IBOutlet weak var staffNameLabel: UILabel!
    @IBOutlet weak var staffPositionLabel: UILabel!
    @IBOutlet weak var staffSummaryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
