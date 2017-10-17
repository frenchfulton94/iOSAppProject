//
//  OpenLinkTableViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/21/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class OpenLinkTableViewCell: UITableViewCell {
    
    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var openURLButton: UIButton!
    
    
    // Class Variables
    // MARK: - Class Variables
    var URL: Foundation.URL?
    
    
    // Actions
    // MARK: - Actions
    @IBAction func openURL(_ sender: UIButton) {
        UIApplication.shared.openURL(URL!)
    }

}
