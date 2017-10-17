//
//  WeekTableViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 3/8/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class WeekTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var weekCollectionView: UICollectionView!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var noEventView: UIView!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
    var eventsArray: [Event] = []
    var dayNameArray: [String] = ["SUN", "MON", "TUES", "WED", "THU", "FRI", "SAT"]
    var firstDaysOfNextMonth: [String] = []
    var lastDaysOfPreviousMonth: [String] = []
    var daysNumArray: [String] = []
    var selectedDate: String?
   // var VC: CalendarViewController!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return daysNumArray.count 
        
    }
    
    var check = 0
    var num = 0
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCellWeek", for: indexPath) as! DayCollectionViewCell
        cell.dayOfTheWeekLabel.text = dayNameArray[indexPath.row]
   // Thursday, March 17, 2016
        
        
        if daysNumArray.count < 7 {
            
            if firstDaysOfNextMonth.count != 0 {
                
                if indexPath.row > (daysNumArray.count - 1 ) {
                   let days = daysNumArray.count
                  
                    cell.numberedDayOfTheWeekLabel.text = self.firstDaysOfNextMonth[indexPath.row - days].components(separatedBy: ", ")[1].components(separatedBy: " ")[1]
    
                } else {
                    cell.numberedDayOfTheWeekLabel.text = self.daysNumArray[indexPath.row].components(separatedBy: ", ")[1].components(separatedBy: " ")[1]
                }
                
            } else {
                
                if indexPath.row < lastDaysOfPreviousMonth.count {
                    cell.numberedDayOfTheWeekLabel.text = self.lastDaysOfPreviousMonth[indexPath.row].components(separatedBy: ", ")[1].components(separatedBy: " ")[1]
                } else {
                    let days = lastDaysOfPreviousMonth.count 
                    cell.numberedDayOfTheWeekLabel.text = self.daysNumArray[indexPath.row - days].components(separatedBy: ", ")[1].components(separatedBy: " ")[1]
                }
                
            }
            
        } else {
            cell.numberedDayOfTheWeekLabel.text = daysNumArray[indexPath.row].components(separatedBy: ", ")[1].components(separatedBy: " ")[1]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        self.selectedDate = daysNumArray[indexPath.row]
                print("dog")
           // VC.calendarTableView.reloadRowsAtIndexPaths([self.indexPath], withRowAnimation: .Automatic)
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCellWeek", for: indexPath) as! EventTableViewCell
        
        cell.eventTitleLabel.text = eventsArray[indexPath.row].eventTitle
        cell.eventTimeLabel.text = eventsArray[indexPath.row].eventTime
        
        return cell
    }
    
    func dayIndex(_ day: String) -> Int {
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
    
    
    

}
