//
//  userDashboardMenuTableViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/24/17.
//  Copyright © 2017 Manhattan College. All rights reserved.
//

import UIKit

class userDashboardMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var notificationsView: UIView!
    @IBOutlet weak var numberOfNotifiationsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
