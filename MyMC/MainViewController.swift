//
//  MainViewController.swift
//  MyMC
//
//  Created with <3 by MobileSquad on 3/1/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import AEXML
import PassKit
import GoogleSignIn
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SwiftyJSON
import RealmSwift
import Alamofire

class MainViewController: UIViewController, UIScrollViewDelegate{
    
    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var gradientView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    // Variables
    // MARK: - Variables
    var VCArray: [UIViewController] = []
    var XMLDict: [String:[String:[Event]]]? = [:]
    var timer: Timer! = Timer()
    var images = [ UIImage(named: "first")!, UIImage(named: "second")!, UIImage(named: "third")!,
                   UIImage(named: "fourth")!, UIImage(named: "fifth")!, UIImage(named: "sixth")!, UIImage(named: "seventh")!]
    var pageController: UIPageViewController!
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    lazy var calendars: Results<Calendar> = { self.realm.objects(Calendar.self) }()
    lazy var twitterUsers: Results<Twitter> = { self.realm.objects(Twitter.self) }()
    lazy var favorites: Results<FavoriteSet> = { self.realm.objects(FavoriteSet.self) }()

    
    // UIView States
    /* Function Directory:
        - viewDidLoad()
        - viewWillAppear()
     */
     // MARK: - UIView States
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        if childViewControllers[0].title == "SEARCH" {
            if (childViewControllers[0] as! SearchViewController).searchResultsTableView.isHidden {
            initTimer()
            timer.fire()
            }
        } else {
             backgroundImageView.image = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(" I dissappeared")
        timer.invalidate()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchVC = storyboard!.instantiateViewController(withIdentifier: "Search") as! SearchViewController
//        let userVC = storyboard!.instantiateViewController(withIdentifier: "UserVC") as! UserDashboardViewController
        VCArray.append(searchVC)
//        addChildViewController(userVC)
        addChildViewController(searchVC)
        searchVC.view.tag = 22
        
 
        let frame = containerView.frame
     
        
        searchVC.view.frame = UIScreen.main.bounds
      
//        userVC.view.frame = userScrollView.frame
        
//        userVC.view.frame.origin.y = 0
        
//        userScrollView.addSubview(userVC.view)
        view.addSubview(searchVC.view)
       setUpRealm()
    
        
     
        
        // TODO: See if better option for handling this
        populateTwitter()
        populateCalendar()
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureUserView()
    }
    
    // Misc Functions
    /* Function Ditrctory:
        - initTimer()
        - runSlideShow()
    */
    // MARK: - Misc Functions
    func initTimer(){
           timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.runSlideShow), userInfo: nil, repeats: true)
    }
    
    func runSlideShow() {
        let num = arc4random_uniform(UInt32(images.count))
        let image = images[Int(num)]
        let crossFade = CABasicAnimation(keyPath: "contents")
        crossFade.duration = 1.0
        crossFade.fromValue = backgroundImageView.image?.cgImage
        crossFade.toValue = image.cgImage
        if backgroundImageView.layer.animationKeys() != nil {
            backgroundImageView.layer.removeAllAnimations()
        }
        backgroundImageView.layer.add(crossFade, forKey: "animateContents")
        backgroundImageView.image = image
    }
    
    func populateCalendar() {
        self.updateCal()

            let ref = FIRDatabase.database().reference()
        ref.child("Calendars").observe(FIRDataEventType.value, with: {
            (snapshot) in
            
            var nameArray:[String] = []
            if self.calendars.count != 0 {
                for cal in self.calendars {
                    nameArray.append(cal.name)
                }
            }
            let calendarDict = snapshot.value as! [String : AnyObject]
            
            for cal in self.calendars {
                if !calendarDict.keys.contains(cal.name) {
                    do {
                        try self.realm.write {
                            self.realm.delete(cal)
                        }
                    } catch {
                        
                    }
                }
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            
            let today = formatter.string(from: Date())
            for (name, json) in calendarDict {
                let newJSON = JSON(json)
                let url = newJSON["CalendarURL"].stringValue
                let onlineName = newJSON["CalendarName"].stringValue
        
                if !nameArray.contains(name) {
                    let newCalendar = Calendar()
                    
                    Alamofire.request(url + "?xcal=1&months=12&startdate=\(today)")
                        .validate().response(completionHandler: { (response) in
                            if let responseData = response.data {
                                do {
                                  
                                    let xml = try AEXMLDocument(xml: responseData)
                                  
                                    try self.realm.write(){
                                        newCalendar.name = name
                                        newCalendar.url = url
                                        newCalendar.onlineName = onlineName
                                        newCalendar.lastBuildDate = xml.root["channel"]["lastBuildDate"].string
                                        newCalendar.xmlData = responseData
                                        self.realm.add(newCalendar)
                                    }
                                } catch {
                                    print("There was a problem get the data for  - ERROR: \(name)")
                                }
                                
                                
                                
                                
                            } else {
                                print("There was a problem get the data for  - ERROR: \(response.error)")
                            }                        })
                    
                            
                    
                    
                } else {
                    
                    let predicate = NSPredicate(format: "name == %@", name)
                    let cal = self.calendars.filter(predicate).first
                    
                    if cal!.onlineName != onlineName {
                        do {
                            try self.realm.write {
                                
                                cal!.onlineName = onlineName
                            }
                        } catch {
                            
                        }
                    }
                    var newURL: Bool = false
                    if cal!.url !=  url {
                        do {
                            try self.realm.write {
                                cal!.url = url
                                newURL = true
                            }
                        } catch {
                            
                        }
                    }
                    
                    if newURL {
                        
                        Alamofire.request(cal!.url + "?xcal=1&months=12&startdate=\(today)").validate().response {
                            (response) in
                            if let responseData = response.data {
                                do {
                                    let xml = try AEXMLDocument(xml: responseData)
                                    let onlineDate = xml.root["channel"]["lastBuildDate"].string
                                    
                                    do {
                                        try self.realm.write {
                                            cal!.lastBuildDate = onlineDate
                                            cal!.xmlData = responseData
                                        }
                                    }
                                    
                                    
                                } catch {
                                    
                                }
                                
                            }
                        }
                    }
                    
                    
                }
                
            }

        }) {
            (error) in
            
            print(error.localizedDescription)
        }
        
        calendars = realm.objects(Calendar.self)
        
        

    }
   
    
    func populateTwitter() {
        
        
        let ref = FIRDatabase.database().reference().child("Twitter")
        ref.observe(.value, with: {
            snapshot in
            
            var nameArray: [String] = []
            if self.twitterUsers.count != 0 {
                for user in self.twitterUsers{
                    nameArray.append(user.name)
                }
            }
            let tempDict = snapshot.value as! [String : AnyObject]
            
            for user in self.twitterUsers {
                if !tempDict.keys.contains(user.name) {
                    do {
                        try self.realm.write {
                            self.realm.delete(user)
                        }
                    } catch {
                        
                    }
                }
            }
            
            do {
                var newhandle: String = ""
                try self.realm.write() {
                    for (name, json) in tempDict {
                        let newJSON = JSON(json)
                        let handle = newJSON["Handle"].stringValue
                        if !nameArray.contains(name) {
                            let newTwitter = Twitter()
                            
                            newTwitter.name = name
                            newTwitter.handle = handle
                            if name == "Manhattan College" {
                                newTwitter.subscribed = true
                                newhandle = handle
                            }
                            self.realm.add(newTwitter)
                            
                          
                            
                            
                        }else {
                            let predicate: NSPredicate = NSPredicate(format: "name == %@", name)
                            
                            if let user = self.twitterUsers.filter(predicate).first{
                                if user.handle != handle {
                                    user.handle = handle
                                }
                            }
                        }
                    }
                }
                print("walalalal")
                try self.realm.write {
                    let predicate = NSPredicate(format: "type = %@", argumentArray: ["Twitter"])
                if self.favorites.filter(predicate).isEmpty {
                    print(2222)
                    let newFav = FavoriteSet()
                    newFav.type = "Twitter"
                    
                    newFav.idSet = "\(newhandle), "
                    self.realm.add(newFav)
                    
                }
                }
                
            } catch {
                
            }
            
            
        })
        
    }
    
    
    func updateCal() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        let today = formatter.string(from: Date())
        for calendar in calendars {
            let url = calendar.url + "?xcal=1&months=12&startdate=\(today)"
            Alamofire.request(url)
                .validate()
                .response { response in
                    if let responseData = response.data {
                        do {
                            
            
                            let xml = try AEXMLDocument(xml: responseData)
                            let onlineDate = xml.root["channel"]["lastBuildDate"].string
                            
                        
                            if calendar.lastBuildDate != onlineDate {
                                do {
                                    try self.realm.write() {
                                        calendar.xmlData = responseData
                                        calendar.lastBuildDate = onlineDate
                                    }
                                    
                                } catch {
                                    
                                }
                            }
                            print("I'm herer")
                        } catch {
                            
                        }
                    }
                    
            }
            
        }
        
    }

    func configureUserView(){
        if GIDSignIn.sharedInstance().currentUser != nil {
        let navBar = navigationController!.navigationBar
        navBar.barStyle = .default
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.tintColor = Colors.Grey.dark
        navBar.barTintColor = UIColor.clear
       
        }
       // navigationController?.navigationItem.leftBarButtonItem
    }

    func logOut() {
        
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        (childViewControllers[0] as! UserDashboardViewController).refreshView(loggedin: false)
        
        
        print("tapped signout")
    }

    func setUpRealm() {
       
        if favorites.count == 1 {
            do {
                try realm.write {
                    let temp = ["Faculty", "Services"]
                    for type in temp {
                        let favSet = FavoriteSet()
                        favSet.type = type
                      
                        
                        realm.add(favSet)
                        
                    }
                }

            } catch let error as NSError {
                print(error.description)
            }
        }
    }

}
