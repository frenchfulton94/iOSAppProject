//
//  DayTableViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 3/8/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dayOfTheWeekLabel: UILabel!
        
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var noEventsView: UIView!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    var date: String!
    var eventsArray: [Event]?
    var current: Int!
    var selectedEvent: Event!
    var VC: NewCalendarTableViewController!
    var today: Bool! {
        didSet {
            
            if today! {
            print(" I am Truth")
        self.contentView.backgroundColor = UIColor(red: 0/255, green: 112/255, blue: 60/255, alpha: 1.0)
            } else {
                print("I am Lie")
                self.contentView.backgroundColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
            }

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if eventsArray == nil {
            return 0
        } else {
        return eventsArray!.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCellDay", for: indexPath) as! EventTableViewCell
        
        cell.eventTitleLabel.text = eventsArray![indexPath.row].eventTitle
        cell.eventTimeLabel.text = eventsArray![indexPath.row].eventTime
        
        print("number of events \(eventsArray!.count)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        VC.selectedEvent = eventsArray![indexPath.row]
        VC.performSegue(withIdentifier: "showEventDetails", sender: nil)
        tableView.deselectRow(at: indexPath, animated: false)



    }
}
