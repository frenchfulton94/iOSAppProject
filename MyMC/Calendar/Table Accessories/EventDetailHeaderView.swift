//
//  EventDetailHeaderView.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 8/14/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class EventDetailTableHeader: UIView {
    fileprivate var eventMonthString: String!
    fileprivate var eventDayString: String!
    fileprivate var eventDayNumString: String!
    fileprivate var imageurl: String?
    
        @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var eventMonth: UILabel!
    @IBOutlet weak var eventDay: UILabel!
    @IBOutlet weak var eventDayNum: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    
    @IBOutlet weak var loadIcon: UIActivityIndicatorView!
    @IBOutlet weak var loadBar: UIProgressView!
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
