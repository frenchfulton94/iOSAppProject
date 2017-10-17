//
//  Event.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 3/8/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import Foundation
import UIKit

struct Event {
    var eventTitle: String! 
    var eventImageURLString: String!     
    var eventImageURL: URL!
    var eventSummary: String!
    var eventDesrciption: String!
    var eventStartDateString: String! {
        didSet{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: self.eventStartDateString) {
            self.eventStartDate = date
            formatter.dateStyle = .full
            self.keyStartString = formatter.string(from: date)
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            self.eventTime = formatter.string(from: date)
            
        }
        
   
        }
    }
    var eventEndDateString: String! {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: self.eventEndDateString) {
            self.eventEndDate = date
            formatter.dateStyle = .full
            self.keyEndString = formatter.string(from: date)
            }
        }
    }
    var keyStartString: String! = ""
    var keyEndString: String! = ""
    var eventStartDate: Date!
    var eventEndDate: Date!
    var eventTime: String!
    var eventLocation: String!
    var eventShareURLString: String? {
        didSet{
            guard let urlString = eventShareURLString else {
                return
            }
            
            guard let url = URL(string: urlString) else {
                return
            }
            
            eventShareURL = url
        }
        
    }
    var eventShareURL: URL!
    var eventAddURLString: String! {
        didSet {
            var urlString = self.eventAddURLString.replacingOccurrences(of: "http", with: "https")
            urlString = urlString.replacingOccurrences(of: "Atmc", with: "Download")
            if let url = URL(string: urlString) {
                self.eventAddURL = url
            }
        }
    }
    var eventAddURL: URL!
    var eventCategory: String!
    
}
