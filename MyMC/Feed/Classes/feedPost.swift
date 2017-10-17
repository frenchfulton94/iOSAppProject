//
//  feedPost.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 2/9/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import Foundation
import UIKit

struct FeedPost {
    var postCategory: String!
    var postTitle: String!
    var postAuthor: String! = ""
    var postDate: String! {
        didSet {
            
                let dateFormatter = DateFormatter()
            
                switch self.postCategory {
                case "Manhattan College News":
                    dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss x"
                    
                case "Events":
                    dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss z"
                    
                case "ITS":
                    var dateArr:[String]! = self.postDate.components(separatedBy: "T")
                    self.postDate = dateArr[0]
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                case "Twitter":
                    dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
                case "News", "Announcements", "Campus Alerts":
                    var dateArr:[String] = self.postDate.components(separatedBy: " ")
                    let day = dateArr[1]
                    let mon = dateArr[2]
                    let year = dateArr[3]
                   
                    self.postDate = day + " " + mon + " " + year
                  print(self.postDate + "gananan")
                    // Tue, 16 Aug 2016 03:14:28 EDT
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    
                default:
                    dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss z"
                }
            
                if self.postDate != nil {
                    if let newDate = dateFormatter.date(from: self.postDate) {
                        dateFormatter.dateStyle = .medium
                        
                        self.postDate = dateFormatter.string(from: newDate)
                    }
                }
        }
    }
    
    var postPublisherString: String!
    var postContent: String!
    var postURL: String!
    var postColor: UIColor!
    var postSummary: String!
}
