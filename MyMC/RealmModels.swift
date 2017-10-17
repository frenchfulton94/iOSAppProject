//
//  RealmModels.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 8/13/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import Foundation
import RealmSwift
import AEXML
import SwiftyJSON

class Calendar: Object {
    dynamic var name : String = ""
    dynamic var lastBuildDate : String = ""
    dynamic var url : String = ""
    dynamic var xmlData : Data = Data()
    dynamic var onlineName : String = ""
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

class Building: Object {
    dynamic var name : String = ""
    dynamic var code : String = ""
    dynamic var coordinates : String = ""
    dynamic var location : String = ""
    dynamic var type : String = ""
    dynamic var floors : String = ""
    dynamic var image : String = ""
    //dynamic var schools : [String] = []
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
}

class Twitter: Object {
    dynamic var name : String = ""
    dynamic var handle : String = ""
    dynamic var subscribed : Bool = false
    override static func primaryKey() -> String? {
        return "name"
    }
}
    class tutSlide: Object {
        dynamic var slideNumber: Int = 0
        dynamic var slideDescription: String?
        dynamic var slideSection: String?
        dynamic var slideIntro: Bool = false
        dynamic var slideColor: String = "White"
        dynamic var slideDescPosition: String = "Bottom"
        dynamic var slideImageURL: String = ""
        dynamic var slideImage: Data = Data()
        override static func primaryKey() -> String? {
            return "slideNumber"
        }
        
}

class FavoriteSet: Object {
    dynamic var type: String! = ""
    dynamic var idSet: String! = ""
    
    override static func primaryKey() -> String? {
        return "type"
    }
}
class FavoriteFaculty: Object {
    dynamic var name: String! = ""
    dynamic var imageURL: String?
    dynamic var profile: Faculty!
    dynamic var objectID: String! = ""
    override static func primaryKey() -> String? {
        return "name"
    }
    
    convenience init(json: JSON) {
        self.init()
        profile = Faculty(json: json)
        name = profile.name
        imageURL = profile.imageURL
        objectID = profile.objectID
    }
}
class FavoriteServices: Object {
    dynamic var title: String!
    dynamic var url: String?
    dynamic var imageURL: String?
    dynamic var objectID: String! = ""
    
    override static func primaryKey() -> String? {
        return "title"
    }
    
    convenience init(json: JSON) {
        self.init()
        title = UniversalLibrary.convertSpecialCharacters(json["Title"].stringValue)
        url  = json["URL for App"].stringValue
        imageURL = json["Icon URL"].stringValue
        objectID = json["objectID"].string
    }
}

class Services: Object {
    dynamic var title: String!
    dynamic var department: String?
    dynamic var summary: String?
    dynamic var graphicURLString: String?
    dynamic var objectID: String! = ""
    dynamic var urlString: String? {
        didSet {
            if urlString == "null" {
               urlString = nil
            }
        }
    }
    
    override static func primaryKey() -> String? {
        return "title"
    }
    
    convenience init(json: JSON) {
        self.init()
        title = UniversalLibrary.convertSpecialCharacters(json["Title"].stringValue)
        urlString  = json["URL for App"].stringValue
        summary = json["Description"].stringValue
        graphicURLString = json["Icon URL"].stringValue
        department = json["Deptartment Owner"].string
        objectID = json["objectID"].string
           }
}
class Faculty: Object {
    dynamic var name: String! = ""
    dynamic var title: String! = ""
    dynamic var titleDepart: String?
    dynamic var titleTwo: String?
    dynamic var department: String! = ""
    dynamic var secondTitleDept: String?
    dynamic var email: String! = ""
    dynamic var phone: String?
    dynamic var officeRoom: String?
    dynamic var urlString: String?
    dynamic var imageURL: String?
    dynamic var largeImageURL: String?
    dynamic var objectID: String! = ""

    
    convenience init(json: JSON) {
        self.init()
        name = json["EMPL_FULL_NAME"].stringValue
        email = json["EMPL_EMAIL"].stringValue
        title = json["EMPL_JOB_DESC"].stringValue
        print("title \(title)")
        var temp = json["TITLEDEPT"].stringValue.components(separatedBy: " - ")
        department = temp[1]
        titleTwo = json["TITLEDEPT_2"].stringValue
        if title == "null" || title == "" {
            title = temp[0]
        }
        largeImageURL = json["imgurl"].stringValue
        phone = json["EMPL_OFFICE_FTELE"].stringValue
        officeRoom = json["EMPL_OFFICE"].stringValue
        imageURL = json["imgurl_thumbnail"].stringValue
        secondTitleDept = json["TITLEDEPT_2"].stringValue
        objectID = json["objectID"].stringValue
        
    }
    
}
//class PlannerObject: Object {
//    dynamic var title: String! = ""
//    dynamic var date: Date! = Date()
//    dynamic var summary: String?
//    dynamic var topics: [String] = []
//    dynamic var completed: Bool = false
//    dynamic var grade: Int = 0
//    dynamic var partners: [String] = []
//    dynamic var type: String! = ""
//    
//    func addToCalendar(){
//        
//    }
//    
//    func createReminder(){
//        
//    }
//    
//    func addPartners(){
//        
//    }
//    
//}
//
//enum PlannerObjectType: String {
//    case Homework = "Homework"
//    case Test = "Test"
//    case Projects = "Projects"
//    case Quizzes = "Quizzes"
//    case Notes = "Notes"
//}
//
//class Courses: Object {
//    dynamic var title: String!
//    dynamic var time: String!
//    dynamic var location: String!
//    dynamic var faculty: Faculty?
//}
//
//class User: Object {
//    dynamic var firstName: String!
//    dynamic var lastName: String!
//    dynamic var email: String!
//    dynamic var jasperCard: JasperCard!
//    dynamic var major: String?
//    dynamic var residents: String!
//    dynamic var studentLevel: String?
//    dynamic var school: String?
//    dynamic var level: String?
//    dynamic var favoriteEmployees: [String]! = []
//    dynamic var favoriteServices: [String]! = []
//   
//    
//    convenience init(userInfo: JSON, jasperCardInfo: JSON) {
//        self.init()
//        jasperCard = JasperCard(json: jasperCardInfo)
//        firstName = jasperCard.firstName
//        lastName = jasperCard.lastName
//       
//        major = userInfo["MAJOR1_DESC"].stringValue
//        residents = userInfo["RESD_CODE_DESC"].stringValue
//        studentLevel = userInfo["STUDENT_LEVEL"].stringValue
//        school = userInfo["SCHOOL_DESC"].stringValue
//        level = userInfo["LEVEL_DESC"].stringValue
//    }
//}

class JasperCard: Object {
    dynamic var id: String! = ""
    dynamic var pidm: String! = ""
    dynamic var firstName: String! = ""
    dynamic var lastName: String! = ""
    dynamic var fullName: String! = ""
    dynamic var barcodeNumber: String! = ""
    dynamic var diningDollars: String! = ""
    dynamic var jasperDollars: String! = ""
    dynamic var lastUpdated: String! = ""
    dynamic var imageURLString: String?
    
    convenience init(json: JSON) {
        self.init()

        
        id = json[0]["SPRIDEN_ID"].stringValue
        firstName = json[0]["SPRIDEN_FIRST_NAME"].stringValue
        print(firstName)
        lastName = json[0]["SPRIDEN_LAST_NAME"].stringValue
        barcodeNumber = json[0]["ISO_ABA"].stringValue
        diningDollars = String(format: "%.2f", json[0]["DiningDollars"].floatValue)
        jasperDollars = String(format: "%.2f", json[0]["JasperDollars"].floatValue)
        lastUpdated = json[0]["LAST_FIN"].stringValue
        pidm = json[0]["SPRIDEN_PIDM"].stringValue
        
        
    }
    
    func formatDate(date: String) {
        //2017/02/27 16:13:12
    }
    
 
    
    func getBarcodeImage() -> UIImage {
        let data = self.barcodeNumber.data(using: .ascii)
        let filter = CIFilter(name: "CIPDF417BarcodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        return UIImage(ciImage: filter!.outputImage!)
    }
    
    func getBalance() -> Float! {
        return Float(diningDollars!)! + Float(jasperDollars!)!
    }
    
    
    func getFullName() -> String! {
        return "\(firstName!) \(lastName!)"
    }
    
    func getImageURLWithSize(width: Int!, height: Int!) -> String! {
        return "https://mcbannerimg.imgix.net/\(self.pidm!)?auto=enhance&w=\(width)&h=\(height)&fm=png"
        
    }
    func returnPass() {
        
    }
}
