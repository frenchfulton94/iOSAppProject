//
//  MenuCollectionViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 3/2/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import SafariServices
import PassKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var featureLabel: UILabel!
    @IBOutlet weak var featuredIcon: UIButton!
    
    @IBAction func presentFeature(sender: UIButton) {
        
        switch self.current {
            
        case "Quadrangle":
            self.menuVC.performSegueWithIdentifier("presentQuadrangle", sender: nil)
        case "Feed":
            self.menuVC.performSegueWithIdentifier("presentFeed", sender: nil)
            
        case "Calendar":
            self.menuVC.performSegueWithIdentifier("presentCalendar", sender: nil)
            print("Sorry Not Available")
            
        case "Settings":
            self.menuVC.performSegueWithIdentifier("presentSettings", sender: nil)
            print("Sorry Not Available")
            
        case "JasperCard":
            
        
         
            
                    if let url = NSURL(string: "https://jaspercardws.manhattan.edu/wallet/my/jasper_card.pkpass") {
                        let svc = SFSafariViewController(URL: url)
                        menuVC.presentViewController(svc, animated: true, completion: nil)
                    }
               
            
            break
        case "Feedback":
            if let url = NSURL(string: "https://docs.google.com/forms/d/1caeWGfpGCNV0uQYxR5GBQ4K3kfAJtsM9t0ba4vlPtEg/viewform") {
                let svc = SFSafariViewController(URL: url)
                menuVC.presentViewController(svc, animated: true, completion: nil)
            }
                
        default:
            break
            
        }
    }
    var menuVC: MenuCollectionViewController!
    var current: String!
    
}
