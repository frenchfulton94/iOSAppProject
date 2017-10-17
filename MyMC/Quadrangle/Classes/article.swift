//
//  article.swift
//  MyMC
//
//  Created with <3 by MobileSquad on 1/26/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import Foundation
import UIKit

struct article {
    var vc: SectionViewController!
    var title: String!
    var author: String!
    var date: String!
    var publisherString: String!
    var summary: String!
    var content: String! {
        didSet {
            self.content = "" + self.content
        }
    }
    var urlString: String! {
        didSet{
            if let url = URL(string: self.urlString){
                self.url = url
            }
        }
    }
    var url: URL!
    var imageURLString: String!
    var image: UIImage!
}
