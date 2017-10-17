//
//  PageContentViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 6/11/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController{
    
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!

    @IBOutlet weak var gradientView: UIImageView!

    
    var screenTitle: String!
    var screenDescription: String!
    var position: String!
    var gradient: UIImage!
    var phone: UIImage!
    var color: UIColor!
    var url: URL!
   
    
    var page: Int = 0
       override func viewDidLoad() {
        super.viewDidLoad()
       
        self.view.backgroundColor = Colors.Grey.light
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        
        
        gradientView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: queue, imageTransition: .crossDissolve(0.3) , runImageTransitionIfCached: true, completion: {
            void in
            self.loadingIcon.stopAnimating()
        })

 
       
      

       
        
//        if page == 0 {
//            pageTitleLabel.textColor = Colors.Grey.dark
//            pageDescriptionBottom.textColor = Colors.Grey.dark
//            
//        } else {
//            pageTitleLabel.textColor = UIColor.whiteColor()
//            pageDescriptionBottom.textColor = UIColor.whiteColor()
//            pageDescriptionTop.textColor = UIColor.whiteColor()
//        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
