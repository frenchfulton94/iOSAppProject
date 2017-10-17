//
//  directoryPerson.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/22/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct directoryPerson {
    var parentVC: UIViewController!
    let name: String!
    var title: String!
    var titleDepart: String?
    var titleTwo: String?
    var department: String!
    var secondTitle: String?
    var secondTitleDept: String?
    var email: String!
    var phone: String!
    var noPhone: Bool!
    var officeRoom: String!
    var urlString: String? {
        didSet{
            if let url = URL(string: self.urlString!) {
                self.url = url
            }
        }
    }
    var url: URL?
    var imageURL: String?
    var largeImageURL: String?
    var image: UIImage?
    var rank: Int!
    
    init (json: JSON) {
        self.name = json["EMPL_FULL_NAME"].stringValue
        self.email = json["EMPL_EMAIL"].stringValue
        self.title = json["EMPL_JOB_DESC"].stringValue
        var temp = json["TITLEDEPT"].stringValue.components(separatedBy: " - ")
        self.department = temp[1]
        self.titleTwo = json["TITLEDEPT_2"].stringValue
        if self.title == "null" || self.title == "" {
            self.title = temp[0]
        }
        self.largeImageURL = json["imgurl"].stringValue
        self.phone = json["EMPL_OFFICE_FTELE"].stringValue
        self.officeRoom = json["EMPL_OFFICE"].stringValue
        self.imageURL = json["imgurl_thumbnail"].stringValue
        self.rank = json["_rankingInfo"]["userScore"].intValue
    
        self.secondTitleDept = json["TITLEDEPT_2"].stringValue
    }
}
