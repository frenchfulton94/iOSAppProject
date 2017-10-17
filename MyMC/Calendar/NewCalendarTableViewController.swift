//
//  NewCalendarTableViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 4/29/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import Foundation
import AEXML
import ReachabilitySwift
import Alamofire
import CoreGraphics
import SwiftyJSON
import RealmSwift

class NewCalendarTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var blockView: UIView!
    
    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var noCalendarEventsLabel: UIView!
    
    // Class Variables
    // MARK: - Variables
    var cal = Foundation.Calendar.current
    var dateFormatter: DateFormatter! = DateFormatter()
    var dateComp: DateComponents! = DateComponents()
    var dateCount: Int = 0
    var yearMonthArray: [String : [String]] = [:]
    var eventDictionary: [String:[String:[String:[String:[Event]]]]] = [:]
    var currentCalendar: String! = "All Events"
    var selectedCell: IndexPath?
    var selectedEvent: Event?
    var canSet: Bool! = false
    var eventDays: [String:[String:[String:[String]]]] = [:]
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    let calendars = try! Realm().objects(Calendar.self)

    // UIView States
    /* Function Directory:
     - viewWillAppear()
     - viewWillDisappear()
     - viewDidLoad()
     */
    // MARK: - UIView States
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .blackTranslucent
        UIView.animate(withDuration: 0.5, animations: {
        let navBar = self.navigationController!.navigationBar
        navBar.isTranslucent = false
 
        navBar.barTintColor = Colors.Green.dark
        let calButton = UIButton()
            calButton.setImage(UIImage(named: "eventsSmall"), for: UIControlState())
        navBar.tintColor = UIColor.white
        calButton.sizeToFit()
        calButton.addTarget(self, action: #selector(NewCalendarTableViewController.showCalendarMenu) , for: .touchUpInside)
        let addCalButton = UIBarButtonItem(barButtonSystemItem: .add , target: self, action: #selector(self.addCalendar))
        let calBarButton = UIBarButtonItem(customView: calButton)
        let eyeButton = UIButton()
            eyeButton.setImage(UIImage(named: "eye"), for: UIControlState())
            eyeButton.sizeToFit()
            eyeButton.addTarget(self, action: #selector(NewCalendarTableViewController.switchStates), for: .touchUpInside)
            let addEyeButton = UIBarButtonItem(customView: eyeButton)
        self.parent!.navigationItem.leftBarButtonItems = [calBarButton, addCalButton]
            let rightItems = self.parent!.navigationItem.rightBarButtonItems
        self.parent!.navigationItem.rightBarButtonItems = [rightItems![0], addEyeButton]
        self.parent!.navigationItem.title = self.currentCalendar
            self.parent!.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: Fonts.scalaSans.light.rawValue, size: 16)!, NSForegroundColorAttributeName: UIColor.white ]
            self.parent!.navigationItem.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName : UIFont(name: Fonts.scalaSans.light.rawValue, size: 16)!], for: UIControlState())
        }) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.hidesBottomBarWhenPushed = true
         
        let reachability: Reachability
        do {
            reachability = try Reachability.init()!
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        UniversalLibrary.noConnection(self)
        
        let nib = UINib(nibName: "CalendarSectionHeader", bundle: nil)
        calendarTableView.register(nib, forHeaderFooterViewReuseIdentifier: "CalendarSectionHeader")
       
        dateFormatter.dateStyle = .full
        dateComp.hour = 3
        reachability.whenReachable = {
            reachability in
     
            self.loadingIcon.isHidden = false
            self.loadingIcon.startAnimating()

            DispatchQueue.main.async(){
                for calendar in self.calendars {
                    do {
                        let xml = try AEXMLDocument(xml: calendar.xmlData)
                        self.createEventDictionary(xml, calendar: calendar.name)
        
                    } catch {
                        //anything to lrt you know that something might have gone wrong to avoid a long debug headache
                    }
                }
            }
        }
        
        reachability.whenUnreachable = {
            reachability in
            
            DispatchQueue.main.async{
                print("unreachable")
                self.loadingIcon.stopAnimating()
                self.view.viewWithTag(69)!.isHidden = false
            }
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    
    // UITableViewDataSource Functions
    /* Function Directory:
     - numberOfSectionsInTableView()
     - tableView(numberOfRowsInSection()
     */
    // MARK: - UITableViewDataSource Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        if yearMonthArray[currentCalendar] != nil {
            return yearMonthArray[currentCalendar]!.count
        }
       return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if yearMonthArray[currentCalendar]?.count != 0 {
            let year = yearMonthArray[currentCalendar]![section].components(separatedBy: " ")[0]
            let month = yearMonthArray[currentCalendar]![section].components(separatedBy: " ")[1]
            print(eventDays[currentCalendar]![year]![month]!)
            return eventDictionary[currentCalendar]![year]![month]!.count
        }
            return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let year = yearMonthArray[currentCalendar]![indexPath.section].components(separatedBy: " ")[0]
        let month = yearMonthArray[currentCalendar]![indexPath.section].components(separatedBy: " ")[1]
        let day = eventDays[currentCalendar]![year]![month]![indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: "dayNumCell", for: indexPath) as! DayNumberTableViewCell
            
            cell.backView.layer.shadowOpacity = 0.5
            cell.backView.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.backView.layer.shadowRadius = 5
            cell.backView.layer.shadowColor = UIColor.black.cgColor
            cell.backView.backgroundColor = Colors.Grey.light
            cell.dayNumberLabel.textColor = Colors.Grey.dark
            cell.dayNameLabel.textColor = Colors.Grey.dark
            let dayName = day.components(separatedBy: ", ")[0]
            let index = dayName.characters.index(dayName.startIndex, offsetBy: 3)
            cell.dayNameLabel.text = day.substring(to: index)
            cell.dayNumberLabel.text = day.components(separatedBy: ", ")[1].components(separatedBy: " ")[1]
            cell.eventsArray = returnEvents(year, month: month, day: day)
            cell.VC = self

        if defaults.bool(forKey: "Calendar State"){
            if cell.eventsArray != nil {
                cell.backView.backgroundColor = Colors.Green.dark
                cell.dayNameLabel.textColor = UIColor.white
                cell.dayNumberLabel.textColor = UIColor.white
                cell.eventTableView.isHidden = false
                cell.noEventsView.isHidden = true
                
            } else {
                cell.noEventsView.isHidden = false
                cell.eventTableView.isHidden = true
            }

            
        }
         cell.eventTableView.reloadData()
            return cell
  
    }
    
    // UITableViewDelegate Functions
    /* Function Directory:
     - tableView(heighForRowAtIndexPath)
     - tableView(viewForHeaderInSection)
     */
    // MARK: - UITableViewDelegate Functions
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let year = yearMonthArray[currentCalendar]![indexPath.section].components(separatedBy: " ")[0]
        let month = yearMonthArray[currentCalendar]![indexPath.section].components(separatedBy: " ")[1]
        
        let date = eventDays[currentCalendar]![year]![month]![indexPath.row]
        let events = returnEvents(year, month: month, day: date)
        if defaults.bool(forKey: "Calendar State") != true {
        if selectedCell != nil {
            if indexPath == selectedCell {

                if events != nil {
                    
                    return (44.0 * CGFloat(events!.count)) + 100.0
                } else {
                    return 190.0
                }
            } else {
                return 100.0
            }
        } else {
            return 100.0
        }
        } else {
            if events != nil {
                return (44.0 * CGFloat(events!.count)) + 100.0
            } else {
                return 190.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CalendarSectionHeader") as! CalendarSectionHeader
        let dateArr = yearMonthArray[currentCalendar]![section].components(separatedBy: " ")
        header.monthLabel.font = UIFont(name: Fonts.scalaSans.light.rawValue, size: 24)
        header.yearLabel.font = UIFont(name: Fonts.tradeGothic, size: 20)
        header.monthLabel.textColor = Colors.Green.dark
        header.yearLabel.textColor = Colors.Grey.dark
        header.monthLabel.text = dateArr[1]
        header.yearLabel.text = dateArr[0]
        
        return header
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        if defaults.bool(forKey: "Calendar State") != true {
        let previousIndexPath = selectedCell
        
        var indexPaths: [IndexPath] = []
        if selectedCell != nil {
            selectedCell  = indexPath == selectedCell ? nil : indexPath
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
            
            tableView.reloadRows(at: indexPaths, with: .automatic)
        }
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) 
        
        if !defaults.bool(forKey: "Calendar State") {
        if selectedCell != nil  && indexPath == selectedCell {
            let year = yearMonthArray[currentCalendar]![indexPath.section].components(separatedBy: " ")[0]
            let month = yearMonthArray[currentCalendar]![indexPath.section].components(separatedBy: " ")[1]
            let date = eventDays[currentCalendar]![year]![month]![indexPath.row]
            let events = returnEvents(year, month: month, day: date)

            if let cells = tableView.cellForRow(at: indexPath) as? DayNumberTableViewCell {
                if events != nil {
                    cells.backView.backgroundColor = UIColor(red: 0/255, green: 112/255, blue: 60/255, alpha: 1.0)
                    cells.dayNameLabel.textColor = UIColor.white
                    cells.dayNumberLabel.textColor = UIColor.white

                    cells.eventTableView.isHidden = false
                    cells.noEventsView.isHidden = true
                    
                } else {
                    cells.noEventsView.isHidden = false
                    cells.eventTableView.isHidden = true
            }
        }
        }
        tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func showCalendarMenu(){
        calendarTableView.isHidden = true
        calendarTableView.setContentOffset(calendarTableView.contentOffset, animated: false)
        performSegue(withIdentifier: "showCalendarMenu", sender: nil)
    }

    
    func createEventDictionary(_ xml: AEXMLDocument, calendar: String) {
        if let base = xml.root["channel"]["item"].all {
            var event = Event()
            for events in base {
                
                event.eventTitle = events["title"].string
                event.eventSummary = events["xCal:summary"].string
                event.eventDesrciption = events["xCal:description"].string
                event.eventLocation = events["xCal:location"].string
                event.eventStartDateString = events["x-trumba:localstart"].string
                event.eventEndDateString = events["x-trumba:localend"].string
                var field = events["x-trumba:customfield"].all(withAttributes: ["name":"Event image"])
                
                event.eventImageURLString =  field?[0].string
                event.eventShareURLString = events["link"].string
                event.eventAddURLString = events["x-trumba:ealink"].string
                event.eventCategory = events["x-trumba:categorycalendar"].string
                
                let year = event.keyStartString.components(separatedBy: ", ")[2]
                let month = event.keyStartString.components(separatedBy: ", ")[1].components(separatedBy: " ")[0]
                
              let result = event.eventStartDate.compare(Date())
                
                let set = {
                    if self.yearMonthArray[calendar] != nil {
                        
                        if !self.yearMonthArray[calendar]!.contains(year + " " + month) {
                            self.yearMonthArray[calendar]!.append(year + " " + month)
                        }
                        
                    } else {
                        print("or else")
                        self.yearMonthArray[calendar] = [year + " " + month]
                    }
                }

                
                if result == .orderedDescending || result == .orderedSame {
                    
                    guard let years = eventDictionary[calendar] else {
                        eventDictionary[calendar] = [year:[month:[event.keyStartString:[event]]]]
                        eventDays[calendar] = [year:[month:[event.keyStartString]]]
                        set()
                        continue
                    }
                    
                    guard let months = years[year] else {
                        eventDictionary[calendar]![year] = [month:[event.keyStartString:[event]]]
                        eventDays[calendar]![year] = [month:[event.keyStartString]]
                        set()
                        continue
                    }
                    
                    guard let days = months[month] else {
                        eventDictionary[calendar]![year]![month] = [event.keyStartString:[event]]
                        eventDays[calendar]![year]![month] = [event.keyStartString]
                        set()
                        continue
                    }
                    
                    guard let _ = days[event.keyStartString] else {
                        eventDictionary[calendar]![year]![month]![event.keyStartString] = [event]
                        eventDays[calendar]![year]![month]!.append(event.keyStartString)
                        set()
                        continue
                    }
                    
                    eventDictionary[calendar]![year]![month]![event.keyStartString]!.append(event)
                    set()
      
             
                }
            }
            self.canSet = true
            self.calendarTableView.reloadData()
            if self.yearMonthArray[currentCalendar]?.count != 0 {
                self.blockView.isHidden = true
                self.noCalendarEventsLabel.isHidden = true
                self.calendarTableView.alpha = 0.0
                self.calendarTableView.isHidden = false
                UIView.animate(withDuration: 0.5, animations: {
              self.calendarTableView.alpha = 1.0
                }) 
                
            }
            self.loadingIcon.stopAnimating()

        }
    }
    
    
    func returnEvents(_ year: String, month: String, day: String) -> [Event]? {
        
        guard eventDictionary[currentCalendar]?[year] != nil else {
            return nil
        }
        
        guard eventDictionary[currentCalendar]?[year]?[month] != nil else {
            return nil
        }
        
        guard eventDictionary[currentCalendar]?[year]?[month]?[day] != nil else {
            return nil
        }
        
        return eventDictionary[currentCalendar]?[year]?[month]?[day]
        
    }
    
    func addCalendar() {
        let predicate = NSPredicate(format: "name == %@", currentCalendar)
        let cal = calendars.filter(predicate).first
            print(cal!.onlineName)
        let url = URL(string: "https://25livepub.collegenet.com/calendars/\(cal!.onlineName).ics")
        
        UIApplication.shared.openURL(url!)
        
    }
    
    func switchStates(){
        calendarTableView.setContentOffset(calendarTableView.contentOffset, animated: false)
        if defaults.bool(forKey: "Calendar State") == true {
            defaults.set(false, forKey: "Calendar State")
          
        } else {
            
            defaults.set(true, forKey: "Calendar State")
        }
          calendarTableView.reloadData()
    }
    // UIScrollViewDelegate Functions
    /* Function Directory:
     - scrollViewDidScroll
     */
    // MARK: - UIScrollViewDelegate Functions
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(  "\(scrollView.contentOffset.y)  \(scrollView.contentSize.height - 672)" )
        progressView.progress = Float(scrollView.contentOffset.y/(scrollView.contentSize.height - 672))
        let visible = calendarTableView.indexPathsForVisibleRows
        
        guard let temp = selectedCell else {
            return
        }
        
        guard !visible!.contains(selectedCell!) else {
            return
        }
        
        selectedCell = nil
        calendarTableView.reloadRows(at: [temp], with: .none)
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventDetails" {
            (segue.destination as! EventDetailViewController).event = selectedEvent!
        } else if segue.identifier == "showCalendarMenu" {
            (segue.destination as! CalendarMenuTableViewController).VC = self
        }
    }
    

}
