//
//  noConnectionViewController.swift
//  MyMC
//
//  Created with <3 by MobileSquad on 5/3/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class noConnectionViewController: UIViewController {

    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var noConnectionMessageLabel: UILabel!
    
    // Class Variables
    // MARK: - Class Variables
    var noConnectionMessages: [String] = ["It’s Probably JasperNet", "Do you even JasperNet?", "Here’s an idea, turn off Airplane mode", "Why dont you try again"]
    

    // View States
    // MARK: - View States
    override func viewDidLoad() {
        super.viewDidLoad()
        let rand = arc4random_uniform(UInt32(noConnectionMessages.count))

        self.noConnectionMessageLabel.text = noConnectionMessages[Int(rand)]
    }
}
