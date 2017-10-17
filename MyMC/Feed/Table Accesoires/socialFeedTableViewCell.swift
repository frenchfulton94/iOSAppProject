//
//  socialFeedTableViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 2/9/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class socialFeedTableViewCell: UITableViewCell {
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var twitterPostLabel: UILabel!
    @IBOutlet weak var postTwitterHandle: UILabel!

    @IBOutlet weak var postBox: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
