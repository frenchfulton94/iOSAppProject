//
//  feedTableViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 2/9/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import AEXML
import Alamofire
import FirebaseDatabase
import FirebaseAuth
import SafariServices
import SwiftyJSON
import RealmSwift

class feedTableViewController: UITableViewController, NSURLConnectionDelegate, UIGestureRecognizerDelegate {
    
    var globalPostArray: [FeedPost] = []
    var eventPostArray: [Event] = []
    var handleArray: [String] = []
    var selectedCellIndex: IndexPath?
    var selectionCellIndex: IndexPath?
    var isLoading = true
    var feedDictionary: [String: String] = [:]
    let defaults  = UserDefaults.standard
    let realm = try! Realm()
    var tableLoading: Bool! = false
    var req: Request?
    var tempDate: String! = ""
    lazy var twitterUsers : Results<Twitter> = { self.realm.objects(Twitter.self).filter("subscribed == true") }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        self.tableView.isDirectionalLockEnabled = true
        self.tableView.isHidden = true
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = Colors.Grey.dark
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to Reload")
        refreshControl?.addTarget(self, action: #selector(feedTableViewController.refresh(_:)), for: .valueChanged)
        self.tableView?.addSubview(refreshControl!)
        
        let ref = FIRDatabase.database().reference().child("Feeds")
        ref.observeSingleEvent(of: .value, with: {
            snapshot in
            
            let temp = snapshot.value as! [String : AnyObject]
            for (feed, json) in temp {
                let val = JSON(json)
               
                self.feedDictionary[feed] = val["FeedURL"].stringValue
                
            }
            self.loadPosts(under: self.title!)
            self.tableView.rowHeight = UITableViewAutomaticDimension;
            self.tableView.estimatedRowHeight = 220.0;
        })
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if self.title == "Featured Events View" {
            return eventPostArray.count
        } else {

            if !tableLoading {
                return globalPostArray.count
            } else {
                return 0
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        switch self.title! {
        case "Twitter View":
            let post = globalPostArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "twitterPostCell", for: indexPath) as! socialFeedTableViewCell
            
            cell.postDateLabel.text = post.postDate
            cell.postDateLabel.textColor = UIColor.white
            cell.twitterPostLabel.text = post.postContent
            cell.twitterPostLabel.textColor = UIColor.white
            
            cell.postTwitterHandle.text = post.postAuthor!
            cell.postTwitterHandle.textColor = UIColor.white
            cell.backgroundColor = post.postColor
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.loadURLOptions(_:)))
            gesture.minimumPressDuration = 0.3
            
            cell.addGestureRecognizer(gesture)
            return cell
            
        case "Featured Events View":
            let cell = tableView.dequeueReusableCell(withIdentifier: "generalPostCell", for: indexPath) as! generalFeedTableViewCell

            let event = eventPostArray[indexPath.row]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            
            let date = dateFormatter.string(from: event.eventStartDate as Date)
            cell.postDateLabel.isHidden = false
            cell.postDateLabel.text = date
            cell.postDateLabel.textColor = UIColor.white
            cell.postHeaderLabel.text = event.eventTitle
            cell.postHeaderLabel.textColor = UIColor.white
            cell.contentView.backgroundColor = Colors.purple

            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.loadURLOptions(_:)))
            gesture.minimumPressDuration = 0.3
            
            cell.addGestureRecognizer(gesture)
            return cell

        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: "generalPostCell", for: indexPath) as! generalFeedTableViewCell
            let post = globalPostArray[indexPath.row]
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.loadURLOptions(_:)))
            gesture.minimumPressDuration = 0.3
            cell.addGestureRecognizer(gesture)

            if selectionCellIndex != nil {
                
                if selectionCellIndex == indexPath {
                    cell.postDateLabel.isHidden = true
                    
                    cell.postHeaderLabel.text = post.postSummary
                    cell.postHeaderLabel.font = UIFont(name: Fonts.scalaSans.light.rawValue, size: 17.0)
                    cell.postHeaderLabel.textColor = Colors.Grey.dark
                    cell.contentView.backgroundColor = Colors.Grey.light
                } else {
                    cell.postDateLabel.isHidden = false
                    cell.postDateLabel.text = post.postDate
                    cell.postHeaderLabel.font = UIFont(name: Fonts.tradeGothic, size: 25.0)
                    cell.postDateLabel.textColor = UIColor.white
                    cell.postHeaderLabel.text = post.postTitle
                    cell.postHeaderLabel.textColor = UIColor.white
                    cell.contentView.backgroundColor = post.postColor
                }
                
            } else {
                cell.postDateLabel.isHidden = false
                cell.postDateLabel.text = post.postDate
                cell.postHeaderLabel.font = UIFont(name: "TradeGothicLTStd-BdCn20", size: 25.0)
                cell.postDateLabel.textColor = UIColor.white
                cell.postHeaderLabel.text = post.postTitle
                cell.postHeaderLabel.textColor = UIColor.white
                cell.contentView.backgroundColor = post.postColor }

            return cell
        }
    }
    
    func loadPosts(under: String) {
        let currentVC: String! = self.title
        var urlString: String!
        globalPostArray = []
         eventPostArray = []
        self.tableView.reloadData()
        switch(under) {
        case "News View":
            
            urlString = feedDictionary["Manhattan College News"]
            self.appendURLToArray(urlString)
            
        case "Announcements View":
            
            let type = defaults.integer(forKey: "Announcement Type")
            let typeArray = ["Everyone", "Students", "Faculty and Staff"]
            urlString = feedDictionary[typeArray[type]]
            var url: String!
  
            if  URL(string: urlString) != nil {
                url = urlString
                self.appendURLToArray(url)
            }

        case "Twitter View":
            print("1 Tweet")
            let socialURLArray = createTwitterStrings()
            self.handleArray = socialURLArray
            for urlString in socialURLArray {
                self.appendURLToArray(urlString)
            }
        case "Featured Events View":
            let calDate = calendarStringFormmatter()
            let url =  feedDictionary["Featured Events"]! + "\(calDate)"
            
            self.appendURLToArray(url)
            
        default:
            var url: String!
            if currentVC == "Campus Alerts View" {
                url = feedDictionary["Campus Alerts"]
            } else {
                url = feedDictionary["ITS News and Outages"]
                
            }
            
            self.appendURLToArray(url)
        }
    }

    func createTwitterStrings() -> [String] {
        var tempArray: [String] = []
        print("2 Tweet")
        for user in twitterUsers {
            print(user)
            tempArray.append(feedDictionary["Twitter"]! + user.handle)
        }
        
        return tempArray
    }
    
    func calendarStringFormmatter() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let finalDate = dateFormatter.string(from: date)
        
        return finalDate
    }
  
    var counter: Int = 0
    func appendURLToArray(_ url: String!) {
        print("APPEND")
       
        isLoading = true
        req = Alamofire.request(url).validate().response {
             (response)in
            do {
                let newsXML = try AEXMLDocument(xml: response.data!)
                let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                 print(url)
                self.parseXML(newsXML, MainURL: url)
                queue.async {
 
                    if self.title == "Twitter View" {
                        self.globalPostArray = self.globalPostArray.sorted {
                            let dateFormatter1 = DateFormatter()
                            dateFormatter1.dateFormat = "MMM d, yyyy"
                            let date1 = dateFormatter1.date(from: $0.postDate)
                            
                            let dateFormatter2 = DateFormatter()
                            dateFormatter2.dateFormat = "MMM d, yyyy"
                            let date2 = dateFormatter2.date(from: $1.postDate)
                            
                            let result = date1!.compare(date2!)
                            
                            return result == ComparisonResult.orderedDescending
                            
                        }
                    }
                    DispatchQueue.main.sync {
                        
                    
 
                        self.tableView.rowHeight = UITableViewAutomaticDimension;
                        self.tableView.estimatedRowHeight = 220.0;
                        self.tableView.frame.size.width = UIScreen.main.bounds.width

                        self.tableLoading = false
                        
                        self.tableView.reloadData()
                        self.tableView.isScrollEnabled = true
                        
                        self.refreshControl?.endRefreshing()

                        self.isLoading = false
                        (self.parent as! feedViewController).loadingIcon.stopAnimating()
                        
                        if self.parent != nil {
                            if (self.globalPostArray.count == 0  && self.title != "Featured Events View" ) || (self.eventPostArray.count == 0 && self.title == "Featured Events View"){
                                self.tableView.isHidden = true
                                (self.parent as! feedViewController).noPostLabel.isHidden =  false
                            } else {
                                self.tableView.alpha = 0.0
                                UIView.animate(withDuration: 1.0) {
                                    self.tableView.isHidden = false
                                    self.tableView.alpha = 1.0
                                    
                                }
                                
                                (self.parent as! feedViewController).noPostLabel.isHidden =  true
                            }
        
                            self.tableView.frame.size.width = UIScreen.main.bounds.width
                        }

                    }
                }
                
            } catch {
                
                self.isLoading = false
                print("\(error)")
            }
            self.req = nil
        }
        
        
        
    }
    
    func parseXML(_ xml: AEXMLDocument, MainURL: String?) -> Void {
        var postObject: FeedPost = FeedPost()
        var num = 0
        var tmp: [FeedPost] = []
        if self.title != "Twitter View" {
            if tempDate != xml.root["channel"]["pubDate"].string  {
             
                tempDate = xml.root["channel"]["pubDate"].string
            }
        } else {
           
        }
       
        
        func preparePostObject(_ color: UIColor, xml: AEXMLDocument!, category: String) -> Void {
            print(category)
            guard let posts = xml.root["channel"]["item"].all else {
                return
            }
                for post in posts {
                    postObject.postCategory = category
                    postObject.postTitle = post["title"].string
                    postObject.postAuthor = category
                    
                    postObject.postColor = color
                    postObject.postSummary = convertSpecialCharacters(post["description"].string)
                    
                    if post["link"].count == 0 {
                        postObject.postURL = ""
                    } else {
                        
                        postObject.postURL =  post["link"].string
                    }
                    postObject.postDate = post["pubDate"].string
                    tmp.append(postObject)
  
                }
                globalPostArray = tmp
            

        }
        print(self.title)
        switch(self.title!) {
        case "News View":
            preparePostObject(Colors.Green.light, xml: xml, category: "News")
            
        case "Announcements View":
            preparePostObject(Colors.Green.medium, xml: xml, category: "Announcements")
            
        case "Twitter View":
            guard let allPost = xml.root["item"].all else {
                return
            }
            let handle = MainURL!.components(separatedBy: "=")[1]
            
            if allPost.count > 1 {
                for post in allPost {
                    postObject.postCategory = "Twitter"
                    postObject.postTitle = ""
                    postObject.postDate = post["time"].string
                    postObject.postAuthor = "\(handle)"
                    postObject.postContent = post["text"].string
                    postObject.postColor = Colors.blue
                    postObject.postURL = "https://twitter.com/\(handle)"
                    globalPostArray.append(postObject)
                    
                }
            }
        case "Featured Events View" :
            guard let base = xml.root["channel"]["item"].all else {
                return
            }
       
                var event = Event()
                
                for events in base {
                    
                    event.eventTitle = events["title"].string
                    event.eventSummary = events["xCal:summary"].string
                    event.eventDesrciption = events["xCal:description"].string
                    event.eventLocation = events["xCal:location"].string
                    
                    event.eventStartDateString = events["x-trumba:localstart"].string
                    event.eventEndDateString = events["x-trumba:localend"].string
                    var field = events["x-trumba:customfield"].all
                    if field?.count == 2 {
                        event.eventImageURLString = field![1].string
                    } else {
                        event.eventImageURLString = nil
                    }
                    event.eventShareURLString = events["link"].string
                    event.eventAddURLString = events["x-trumba:ealink"].string
                    event.eventCategory = events["x-trumba:categorycalendar"].string
                    self.eventPostArray.append(event)
                
                
            }
        case "ITS View":
            
            guard let postARRAY = xml.root["entry"].all else {
                return
            }
     
                for post in postARRAY {
                    postObject.postCategory = "ITS"
                    postObject.postTitle = post["title"].string
                    postObject.postDate = post["published"].string
                    postObject.postAuthor = post["author"]["name"].string
                    postObject.postSummary = post["summary"].string
                    let link = post["link"].all(withAttributes: ["rel" : "alternate"])![0]

                    let url = link.attributes["href"]! as String
                    
                    postObject.postURL = url
                    
                    postObject.postColor = Colors.orange
                   tmp.append(postObject)
                    
                }
                globalPostArray = tmp
            
        case "Campus Alerts View":
            preparePostObject(Colors.red, xml: xml, category: "Campus Alerts")
            
        default:
            return
        }
 
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
            switch segue.identifier! {
                
            case "showEventDetails":
                (segue.destination as! EventDetailViewController).event = eventPostArray[selectedCellIndex!.row]

            case "showTwitterMenu":
                (segue.destination as! FeaturesFeedViewController).usersSelectedFeeds = self.handleArray
            
            default:
                break
            }
            
       
    }
 
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if self.title != " Twitter View" || self.title != "Featured Events View" {
            let previousIndexPath = selectionCellIndex
            
            var indexPaths: [IndexPath] = []
            
            if selectionCellIndex != nil {
                if indexPath == selectionCellIndex {
                    selectionCellIndex = nil
                    print("selectionCell =  nil")
                    
                } else {
                    selectionCellIndex = indexPath
                    print("selectionCell = \(indexPath.row)")
                }
                
            } else {
                selectionCellIndex = indexPath
                print("selectionCell = \(indexPath.row)")
            }

            if let previous = previousIndexPath {
                indexPaths.append(previous)
                print("previous was added")
            }
            
            if let current = selectionCellIndex {
                indexPaths.append(current)
                print("selection was addaed")
            }
            
            if indexPaths.count > 0 {
                tableView.reloadRows(at: indexPaths, with: .automatic)
            }
        }
        
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    var didSeg: Bool!
    override func viewWillAppear(_ animated: Bool) {
        didSeg = false
    }
    func loadURLOptions(_ sender: UILongPressGestureRecognizer) {
        let touch = sender.location(in: self.tableView)
        
        if let index = tableView.indexPathForRow(at: touch) {
            selectedCellIndex = index
            
            switch self.title! {
            case "Featured Events View":
                
                if didSeg == false {
                    self.performSegue(withIdentifier: "showEventDetails", sender: nil)
                    didSeg = true
                }
                
            default:
    
                if UIApplication.shared.canOpenURL(URL(string: self.globalPostArray[index.row].postURL)!) {

                    if self.title == "Twitter View" {
                        
                        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        let appAction = UIAlertAction(title: "Open in App", style: .default){
                            (action) in
                            if let url = URL(string: self.globalPostArray[index.row].postURL) {
                                let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                                self.present(safariVC, animated: true, completion:  nil)
                            }
                        }
                        
                        if UIApplication.shared.canOpenURL(URL(string: "twitter://")!) {
                            alert.addAction(cancelAction)
                            alert.addAction(appAction)
                            let twitterAction = UIAlertAction(title:"Open in Twitter" , style: .default) {
                                (action) in
                                let handle = self.globalPostArray[index.row].postAuthor!.components(separatedBy: "@")[1]
                                if let url = URL(string: "twitter://user?screen_name=\(handle)") {
                                    UIApplication.shared.openURL(url)
                                }
                            }
                            
                            alert.addAction(twitterAction)
                            
                            present(alert, animated: true, completion: nil)
                        } else {
                            if let url = URL(string: self.globalPostArray[index.row].postURL) {
                                let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                                self.present(safariVC, animated: true, completion:  nil)
                            }
                        }
                        
                    } else {
                        if let url = URL(string: self.globalPostArray[index.row].postURL) {
                            let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                            self.present(safariVC, animated: true, completion:  nil)
                        }
                    }
                }
            }
        }
    }
    
    func convertSpecialCharacters(_ string: String) -> String {
        let encodedData = string.data(using: String.Encoding(rawValue: UInt(NSNumber(value: String.Encoding.utf8.rawValue))))!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
            NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue) as AnyObject
        ]
        var attributedString: NSAttributedString!
        do {
            attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch {
            
        }
        let decodedString = attributedString.string
        return decodedString
    }
    
    func iSort( _ postArray: [FeedPost]) -> [FeedPost]
    {
        let nObjects = postArray.count
        var temp = postArray
        
        for x in 0..<nObjects
        {
            
            //print("date1 \(date1!)")
            for y in x+1..<nObjects
            {
                
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "MMM d, yyyy"
                let date1 = dateFormatter1.date(from: postArray[x].postDate)
                
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "MMM d, yyyy"
                let date2 = dateFormatter2.date(from: postArray[y].postDate)
                // print("date2 \(date2!)")
                
                
                let result = date1!.compare(date2!)
                //let result = (self.globalPostArray[x].postDate.compare(globalPostArray[y].postDate))
                
                if result == ComparisonResult.orderedAscending
                {
                    let tmp = temp[y]
                    temp[y] = temp[x]
                    temp[x] = tmp
                }
            }
        }
        
        return postArray
    }
    
    func switchFeed() {
        
        
        var val = defaults.integer(forKey: "Announcement Type")
        var newTitle: String!
        if val == 0  {
            newTitle = "Announcements (Students)"
            val = 1
        } else if val == 1 {
            newTitle = "Announcements (Employees)"
            val = 2
        } else {
            newTitle = "Announcements (Everyone)"
            val = 0
        }
        let typeArray = ["Everyone", "Students", "Faculty and Staff"]
        let urlString = feedDictionary[typeArray[val]]
        if URL(string: urlString!) == nil {
            let alertController = UIAlertController(title: "Link Not Available Yet", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        parent!.parent!.navigationItem.title = newTitle
        defaults.set(val, forKey: "Announcement Type")
        globalPostArray = []
        counter = 0
        loadPosts(under:self.title!)
    }
    
    func loadUsersTwitterSettings() -> [String] {
        let defaults = UserDefaults.standard
        if let userSubscribed = defaults.object(forKey: "usersTwitterSettings") {
            return userSubscribed as! [String]
        } else {
            return []
        }
    }
    
    
    func refresh(_ sender:AnyObject) {
        // Code to refresh table view
        print(refreshControl!.isRefreshing)
        print("FJHFJSJ")
        req?.cancel()
        if !isLoading && !tableLoading {
            print("I did it")
             (self.parent as! feedViewController).loadingIcon.startAnimating()
            isLoading = true
                 tableView.isScrollEnabled = false
            tableLoading = true
            counter = 0
            loadPosts(under:self.title!)
        }
    }
    
}
