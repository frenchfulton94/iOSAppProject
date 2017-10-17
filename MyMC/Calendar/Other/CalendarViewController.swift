//
//  CalendarViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 3/8/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import Foundation
import AEXML

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var XMLDict: [String:[String:[Event]]]? = [:]
    var currentCalendar: String!
    var selectedDate: String!
    var selectedIndex: NSIndexPath?
    var cal = NSCalendar.currentCalendar()
    var today = NSDate()
    //var dateFormatter = NSDateFormatter()
    var dayFormatter = NSDateFormatter()
    var dateComp = NSDateComponents()
    var finalArray: [String :[[String]]] = [:]
    var dateArray: [String:[String]] = [:]
    var numOfRows: [String:Int] = [:]
    var monthOrder: [String] = []
    var dateCount = 0
    var todayString: String!
    var selectedCell: NSIndexPath?
    var sevenArray: [String] = []
    var numevents = 0
    var temp2: Int! = 0
    var temp: Int! = 0
    var selectedCollectionCell: String?
    let storyboardVC = UIStoryboard(name: "Main", bundle: nil)
    var Selectedevent: Event! {
        didSet{
            performSegueWithIdentifier("showDetails", sender: nil)
        }
    }
    
    var parent: MainViewController!
    
    
    enum Calendar: String {
        case All = "mc-all-events-excluding-meetings"
        case Academic = "mc-academic"
        case Athletics = "mc-athletics"
        case Career = "mc-career_professional_development"
        case Featured = "mc-featured_events"
        case Lectures = "mc-lectures-presentations"
        case Multicultural = "mc-multicultural"
        case Public = "mc-open_to_public"
        case Religion = "mc-religious-and-spiritual"
        case StudAct = "mc-student_activities"
        case StudClubs = "mc-student-clubs"
        case Volunteer = "mc-volunteer_service"
        
        static let allCalendars = [ Academic, Athletics, Career, Featured, Lectures,
                                    Multicultural, Public, Religion, StudAct, StudClubs, Volunteer]
        
        func calendarName() -> String! {
            switch self {
            case .All:
                return "All"
            case .Academic:
                return "Academic"
            case .Athletics:
                return "Atletics"
            case .Career:
                return "Career & Professional Development"
            case .Featured:
                return "Featured Events"
            case .Lectures:
                return "Lectures & Presentations"
            case .Multicultural:
                return "Multicultural"
            case .Public:
                return "Open to Public"
            case .Religion:
                return "Religious & Spiritual"
            case .StudAct:
                return "Student Activities"
            case .StudClubs:
                return "Student Clubs"
            case .Volunteer:
                return "Volunteer Service"
                
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        dayFormatter.dateStyle = .FullStyle
        dateComp.hour = 3
        todayString = dayFormatter.stringFromDate(today)
       self.calendarTableView.hidden = true
        getDates()
        fillNumArray()
        fillCallendarDict()
        parent = storyboardVC.instantiateViewControllerWithIdentifier("MainVC") as! MainViewController
        
        if XMLDict!.count == 0 {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            let queue = dispatch_get_global_queue(qos, 0)
            dispatch_async(queue){
                self.loadCalendarEvents()
               
                dispatch_async(dispatch_get_main_queue()){
                    self.loading.stopAnimating()
                    if self.XMLDict!.count != 0 {
                    self.temp = 7
                    self.calendarTableView.reloadData()
                    self.calendarTableView.hidden = false
                     self.parent.XMLDict = self.XMLDict!
                    }
                    
                }
                
            }
            
        }
        
        
      


        // Do any additional setup after loading the view.
    }
    
    
    func loadCalendarEvents() {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let today = formatter.stringFromDate(NSDate())
        let urlString = "https://25livepub.collegenet.com/calendars/"
        let endURLString = ".rss?xcal=1&months=12&startdate=\(today)"
        var xmlDictionary: [String : AEXMLDocument] = [:]
        var calendarEvents: [String : [String : [Event]]] = [:]
        
        
        for topic in Calendar.allCalendars {
            let URLString = urlString + topic.rawValue + endURLString
            if let url = NSURL(string: URLString){
                if let data = NSData(contentsOfURL: url){
                    do {
                        print("I made it to the do")
                        let xml = try AEXMLDocument(xmlData: data)
                        xmlDictionary[topic.calendarName()] = xml
                    } catch {
                        
                    }
                    
                }
            }
        }
        
        func createEventDictionary(xml: AEXMLDocument) -> [String:[Event]] {
            let base = xml.root["channel"]["item"]
            var tempDict: [String: [Event]] = [:]
            var event = Event()
            for events in base.all! {
                
                
                event.eventTitle = events["title"].stringValue
                event.eventSummary = events["xCal:summary"].stringValue
                event.eventDesrciption = events["xCal:description"].stringValue
                event.eventLocation = events["xCal:location"].stringValue
                event.eventStartDateString = events["x-trumba:localstart"].stringValue
                event.eventEndDateString = events["x-trumba:localend"].stringValue
                var field = events["x-trumba:customfield"].all
                if field?.count == 2 {
                    event.eventImageURLString = field![1].stringValue
                } else {
                    event.eventImageURLString = nil
                }
                event.eventShareURLString = events["link"].stringValue
                event.eventAddURLString = events["x-trumba:ealink"].stringValue
                event.eventCategory = events["x-trumba:categorycalendar"].stringValue
            
                print("Keystart \(xml.root["channel"]["title"].stringValue) \(event.keyStartString)")
                if event.keyStartString == event.keyEndString {
                    
                    
                    
                    
                    if let key = tempDict[event.keyStartString] {
                        tempDict[event.keyStartString]?.append(event)
                    } else {
                        tempDict[event.keyStartString] = []
                        tempDict[event.keyStartString]?.append(event)
                    }
                } else {
                    let cal = NSCalendar.currentCalendar()
                    
                    let startDate = event.eventStartDate
                    let endDate = event.eventEndDate
                    
                    let dateComp = NSDateComponents()
                    
                    dateComp.hour = 3
                    
                    if let key = tempDict[event.keyStartString] {
                        tempDict[event.keyStartString]?.append(event)
                    } else {
                        tempDict[event.keyStartString] = []
                        tempDict[event.keyStartString]?.append(event)
                    }
                    
                    
                    
                    cal.enumerateDatesStartingAfterDate(startDate, matchingComponents: dateComp, options: .MatchStrictly){
                        (dates, exactMatch, stop) -> Void in
                        
                        let dateFormatterx = NSDateFormatter()
                        dateFormatterx.dateStyle = .FullStyle
                        let newDate = dateFormatterx.stringFromDate(dates!)
                        if let key = tempDict[newDate] {
                            tempDict[newDate]?.append(event)
                        } else {
                            tempDict[newDate] = [event]
                        }
                        
                        if newDate == event.keyEndString {
                            stop.memory = true
                        }
                        
                    }
                    
                    
                    
                    
                    
                }
                
                
            }
            
            return tempDict
            
            
        }
        
        for (Calendar, XML) in xmlDictionary {
            calendarEvents[Calendar] = createEventDictionary(XML)
        }
        
        self.XMLDict = calendarEvents
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyBoard.instantiateViewControllerWithIdentifier("CalendarVC") as! CalendarViewController
        
        VC.XMLDict = self.XMLDict
    
        
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let month = monthOrder[section]
      
        let rows = numOfRows[month]
        
       /* if month == todayString.componentsSeparatedByString(", ")[1] {
            return rows!
        }*/
        return temp
    }
    
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("lol")
        if indexPath.section == 0 {
        
            var num: Int
            var check: Int
            if self.finalArray[monthOrder[0]]![0].count == 7 {
                num = 1
            } else {
                num = 0
            }
            if indexPath.row < 7 {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("dayTableViewCell", forIndexPath: indexPath) as! DayTableViewCell
                let month = self.monthOrder[0]
                
                let firstRow = self.finalArray[month]![0].count
              
                if firstRow == 7 {
                    cell.dayOfTheWeekLabel.text = self.finalArray[month]![0][indexPath.row].componentsSeparatedByString(", ")[0].componentsSeparatedByString(", ")[0]
                    let date = self.finalArray[month]![0][indexPath.row]
                    if let value = XMLDict!["Featured Events"]![date] {
                      cell.eventsArray = value
                    }
                    //cell.eventTableView.reloadData()
                    if !sevenArray.contains(date) {
                        sevenArray.append(date)
                    }
                    
                    cell.date = self.finalArray[month]![0][indexPath.row]
                    
                } else {
                    print("\(indexPath) \(indexPath.row)")
                    if indexPath.row < firstRow  {
                        let date = self.finalArray[month]![0][indexPath.row]
                        cell.dayOfTheWeekLabel.text = self.finalArray[month]![0][indexPath.row].componentsSeparatedByString(", ")[0]
                        if !sevenArray.contains(date)  {
                        sevenArray.append(date)
                            print(date)
                        }
                        if let value = XMLDict!["Featured Events"]![date] {
                            cell.eventsArray = value
                        }
                       // cell.eventTableView.reloadData()
                        
                        cell.date = self.finalArray[month]![0][indexPath.row]
                    } else {
                        check = indexPath.row - firstRow
                        cell.dayOfTheWeekLabel.text = self.finalArray[month]![1][check].componentsSeparatedByString(", ")[0]
                        let date = self.finalArray[month]![1][check]
                        if !sevenArray.contains(date)  {
                    
                            sevenArray.append(date)
                            print(date)
                        }
                        if let value = XMLDict!["Featured Events"]![date] {
                          cell.eventsArray = value
                        }
                        //cell.eventTableView.reloadData()
                        cell.date = self.finalArray[month]![1][check]
                       
                    }
                    
                  
                }
                
                if indexPath.row == 0 && indexPath.section == 0 {
                    cell.dayOfTheWeekLabel.text = "Today"
                    
                 cell.dayView.backgroundColor = UIColor(red: 0/255, green: 112/255, blue: 60/255, alpha: 1.0)
                    
                } else {
                    cell.dayView.backgroundColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
                }
                 cell.eventTableView.reloadData()
                cell.VC = self
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("weekTableViewCell", forIndexPath: indexPath) as! WeekTableViewCell
                cell.selectionStyle = .None
                cell.weekCollectionView.delegate = cell
                cell.VC = self
                cell.indexPath = indexPath
                let month = self.monthOrder[0]
                let nextMonth = self.monthOrder[1]
                let lastRow = self.finalArray[month]!.count - 1
             
                var lastdays:[String] = []
                if self.finalArray[month]![indexPath.row-7].count < 7 && indexPath.row == numOfRows[month]! - 1 {
                    if indexPath.section == monthOrder.count - 1 {
                        let nextMonth = self.monthOrder[indexPath.section + 1]
                        lastdays = self.finalArray[nextMonth]![0]
                        cell.daysNumArray = self.finalArray[month]![indexPath.row] + lastdays
                    }
                    
                } else {
                    cell.daysNumArray = self.finalArray[month]![indexPath.row - 6]
                }
                if let date = cell.selectedDate {
                    print("i was selected")
                    let events =  XMLDict!["Featured Events"]![date]!
                    self.numevents = XMLDict!["Featured Events"]![date]!.count
                    self.selectedCollectionCell = date
                    cell.eventsArray = events
                    cell.eventTableView.reloadData()
                }
               // cell.daysNumArray = self.finalArray[month]![indexPath.row - 6]
               // if self.finalArray[month]![lastRow].count < 7 && indexPath.row == lastRow {
               //     cell.firstDaysOfNextMonth = self.finalArray[nextMonth]![0]
                    
               // }
                cell.weekCollectionView.reloadData()
                num++
                cell.weekCollectionView.allowsSelection = true
  
                return cell
            }
            
        } else {
            
        
      
           let cell = tableView.dequeueReusableCellWithIdentifier("weekTableViewCell", forIndexPath: indexPath) as! WeekTableViewCell
             let month = self.monthOrder[indexPath.section]
            cell.selectionStyle = .None
            cell.weekCollectionView.delegate = cell
            cell.VC = self
            cell.indexPath = indexPath
            var lastdays: [String] = []
            if indexPath.row == 0 && self.finalArray[month]![0].count < 7 {
                let previousMonth = self.monthOrder[indexPath.section - 1]
                let lastRow = (self.finalArray[previousMonth]!.count) - 1
                
               lastdays = self.finalArray[previousMonth]![lastRow]
                cell.daysNumArray = lastdays + self.finalArray[month]![indexPath.row]
            } else if self.finalArray[month]![indexPath.row].count < 7 && indexPath.row == numOfRows[month]! - 1 {
                if indexPath.section < monthOrder.count - 1 {
                let nextMonth = self.monthOrder[indexPath.section + 1]
                lastdays = self.finalArray[nextMonth]![0]
                cell.daysNumArray = self.finalArray[month]![indexPath.row] + lastdays
                } else {
                    cell.daysNumArray = self.finalArray[month]![indexPath.row]
                }
                
            } else {
                cell.daysNumArray = self.finalArray[month]![indexPath.row]
            }
            if let date = cell.selectedDate {
                let events =  XMLDict!["Featured Events"]![date]!
                self.numevents = XMLDict!["Featured Events"]![date]!.count
                self.selectedCollectionCell = date

                  cell.eventsArray = events
                cell.eventTableView.reloadData()
            }
            
          /*  if indexPath.row == 0 && self.finalArray[month]![0].count < 7 {
                let previousMonth = self.monthOrder[indexPath.section - 1]
                let lastRow = (self.finalArray[previousMonth]!.count) - 1
             
                cell.lastDaysOfPreviousMonth = self.finalArray[previousMonth]![lastRow]
                  cell.weekCollectionView.reloadData()
                
            } else if self.finalArray[month]![indexPath.row].count < 7 {
                let nextMonth = self.monthOrder[indexPath.section + 1]
                cell.firstDaysOfNextMonth = self.finalArray[nextMonth]![0]
                cell.weekCollectionView.reloadData()
                
            }*/
            cell.weekCollectionView.reloadData()

            
            cell.weekCollectionView.allowsSelection = true

            

            return cell
        }
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
        
        return monthOrder[section]
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            
                      }
    }
    
    func getDates() {
        
        
        cal.enumerateDatesStartingAfterDate(today, matchingComponents: dateComp, options:.MatchStrictly) { (dates, exactMatch, stop) -> Void in
            let currentDate = self.dayFormatter.stringFromDate(dates!)
            let month = currentDate.componentsSeparatedByString(", ")[1].componentsSeparatedByString(" ")[0]
            let Year = currentDate.componentsSeparatedByString(", ")[2].componentsSeparatedByString(" ")[0]
            
            let key = month + " " + Year
            
            if self.dateCount == 0 {
                self.dateArray[key] = [self.todayString]
            }
            if let _ = self.dateArray[key] {
                self.dateArray[key]?.append(currentDate)
                
            } else {
                self.dateArray[key] = [currentDate]
              
            }
            
            if self.monthOrder.contains(key) {
              
            } else {
                self.monthOrder.append(key)
            }
            if ++self.dateCount == 365 {
                stop.memory = true
            }
        }
        
    }
    
    func numberOfRows(num: Int, start: String, year: String, month: String) -> Int {
        if (num == 31 && (start == "Friday" || start == "Saturday")) || (num == 30 && start == "Saturday")  {
            return 6
        } else if num == 28 && start == "Sunday" {
            return 4
        } else if month == dayFormatter.stringFromDate(today).componentsSeparatedByString(", ")[1].componentsSeparatedByString(" ")[0] && year == dayFormatter.stringFromDate(today).componentsSeparatedByString(", ")[2].componentsSeparatedByString(" ")[0] {
            let dnum = 7 + ceil(Double(num/7))
            return Int(dnum)
        }  else {
            return 5
        }
        
    }
    
    
    
    func dayIndex(day: String) -> Int {
        switch day {
        case "Sunday":
            return 0
        case "Monday":
            return 1
        case "Tuesday":
            return 2
        case "Wednesday":
            return 3
        case "Thursday":
            return 4
        case "Friday":
            return 5
        case "Saturday":
            return 6
        default:
            return -1
            
        }
    }
    
    
    func fillNumArray() {
        for (key, array) in dateArray {
            
            let day = array[0].componentsSeparatedByString(", ")[0]
            array.count
            let rows = numberOfRows(array.count, start: day, year: key.componentsSeparatedByString(" ")[1], month: key.componentsSeparatedByString(" ")[0])
            
            numOfRows[key] = rows
        }
        
    }
    
    func fillCallendarDict() {
      
        var dayArray: [String] = []
        for (month, rows) in  numOfRows {
       
            finalArray[month] = []
            let days = dateArray[month]![0]
            let dayString = days.componentsSeparatedByString(", ")[0]
            let firstWeek = 7 - dayIndex(dayString)
            var count = 0
            for i in 0..<rows {
                
                if i == 0 {
                    for d in  0..<firstWeek {
                        dayArray.append(dateArray[month]![d])
                        count++
                    }
                    finalArray[month]?.append(dayArray)
                    dayArray = []
                } else {
                    for j in count..<(count+7) {
                        if j < dateArray[month]?.count {
                            
                            if dateArray.count != 0 {
                                dayArray.append(dateArray[month]![j])
                            }
                            
                        }
                    }
                    finalArray[month]?.append(dayArray)
                    dayArray = []
                    count += 7
                }
                
            }
        }
        
    }
    var tempCell: DayTableViewCell!
    var tooTempCell: WeekTableViewCell!

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        if indexPath.row < 7  && indexPath.section == 0 {
            
            
            if self.selectedCell == indexPath {
            
                
                if numevents != 0 {
                    
                    
                    return CGFloat((self.numevents * 44) + 100)
                } else {
                    return 190.0
                }
                
                
            } else {
                
                return 100.0
            }
            
        } else {
            if let selected = selectedCell {
                if selected.row >= 7 {
                print("Im in here")
                if numevents != 0 {
                    return CGFloat((self.numevents * 44) + 64)
                } else {
                    return 190.0
                    }
                } else {
                    return 64.0
                }

            }
           else {
                return 64.0
            }
        }
       
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("\(indexPath) \(indexPath.row)")

        print("part 2")
        if indexPath.section == 0 {
            if indexPath.row < 7  {
        let previousIndexPath = selectedCell
        print("fuckboi")
        var indexPaths: [NSIndexPath] = []
        if indexPath == selectedCell {
            selectedCell = nil
        } else {
            selectedCell = indexPath
        }
        if let previous = previousIndexPath {
            indexPaths.append(previous)
        }
        
        if let current = selectedCell {
            indexPaths.append(current)
            
        }
        
        if indexPaths.count > 0 {
     
       let cell = tableView.cellForRowAtIndexPath(indexPath) as! DayTableViewCell
            if cell.eventsArray.count != 0 {
                print("events count \(cell.eventsArray.count)")
                
            self.numevents = XMLDict!["Featured Events"]![cell.date]!.count
          tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
         
            }
        } else {
            
        }
            }
    
          //  tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
       print("ahgdfhjafhas")
        (segue.destinationViewController as! EventDetailViewController).event = self.Selectedevent
    }
    


}