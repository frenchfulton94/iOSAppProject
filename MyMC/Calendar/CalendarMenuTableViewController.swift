//
//  CalendarMenuTableViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 5/2/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
class CalendarMenuTableViewController: UITableViewController {
    
    // Class Variables
    // MARK: - Class Variables
    var VC: NewCalendarTableViewController!
    var selected: IndexPath!
    let defaults = UserDefaults.standard

    let calendars = try! Realm().objects(Calendar.self).sorted(byProperty: "name", ascending: true)
    // UIView States
    /* Function Directory:
        - viewWillAppear()
        - viewDidLoad()
    */
    // MARK: - UIView States
    override func viewWillAppear(_ animated: Bool) {
 
 
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
               self.prefersStatusBarHidden
     
      
    }
    
    
    // UITableViewDataSource Functions
    /* Function Directory:
        - numberOfSectionsInTableView()
        - tableView(numberOfRowsInSection)
        - tableView(cellForRowAtIndexPath)
    */
    // MARK: - UITableViewDataSource Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return calendars.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarMenuCell", for: indexPath) as! CalendarMenuTableViewCell
       
        cell.calendarMenuLabel.text = calendars[indexPath.row].name
        
        if calendars[indexPath.row].name == self.VC.currentCalendar {
            selected = indexPath
            cell.contentView.backgroundColor = UIColor(red: 0, green: 112/255, blue: 60/255, alpha: 1.0)
            cell.calendarMenuLabel.textColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        } else {
           
            cell.contentView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
                cell.calendarMenuLabel.textColor = UIColor(red: 0, green: 112/255, blue: 60/255, alpha: 1.0)

        }

        return cell
    }
    
    
    // UITableViewDelegate
    /* Function Directory:
        - tableView(heightForRowAtIndexPath)
        - tableView(didSelectRowAtIndexPath)
    */
    // MARK: - UITableViewDelegate Functions
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54 //((UIScreen.mainScreen().bounds.height - 22)/CGFloat(calendars.count))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var cell = tableView.cellForRowAtIndexPath(selected) as! CalendarMenuTableViewCell
//        
//        cell.contentView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
//        cell.calendarMenuLabel.textColor = UIColor(red: 0, green: 112/255, blue: 60/255, alpha: 1.0)
        
        self.dismiss(animated: true) {
            
            if let cal = self.VC.yearMonthArray[self.VC.currentCalendar] {
                if cal.count != 0 {
                    self.VC.calendarTableView.alpha = 0.0
                    self.VC.calendarTableView.isHidden = false
                    
                    self.VC.noCalendarEventsLabel.isHidden = false
                    //self.VC.view.bringSubviewToFront(self.VC.calendarTableView)
                    self.VC.blockView.isHidden = true
                    UIView.animate(withDuration: 0.5, animations: {
                        self.VC.calendarTableView.alpha = 1.0
                    }) 
                    
                } else {
                    
                }
            } else {
                print("bla")
                self.VC.noCalendarEventsLabel.isHidden = false
            }
            
            self.VC.loadingIcon.stopAnimating()
            
            self.VC.calendarTableView.reloadData()
            
        }
        
       let  cell = tableView.cellForRow(at: indexPath) as! CalendarMenuTableViewCell
        
        cell.contentView.backgroundColor = UIColor(red: 0, green: 112/255, blue: 60/255, alpha: 1.0)
        cell.calendarMenuLabel.textColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        self.VC.noCalendarEventsLabel.isHidden = true
        //self.VC.loadingIcon.hidden = false
        self.VC.blockView.isHidden = false
        self.VC.noCalendarEventsLabel.isHidden = true
        // self.VC.loadingIcon.startAnimating()
        self.VC.currentCalendar = self.calendars[indexPath.row].name
        print("Current Cal \(self.calendars[indexPath.row].name)")
        self.VC.selectedCell = nil
        let top = CGRect(x: 0, y: 0, width: self.VC.calendarTableView.frame.width, height: self.VC.calendarTableView.frame.height)
        self.VC.calendarTableView.scrollRectToVisible(top, animated: false)
        
 
        
       

    }
   
}
