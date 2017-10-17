//
//  DayNumberTableViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 4/29/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class DayNumberTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var noEventsView: UIView!
    var eventsArray: [Event]?

    var VC: NewCalendarTableViewController!
    

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
        
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        VC.selectedEvent = eventsArray![indexPath.row]
        VC.performSegue(withIdentifier: "showEventDetails", sender: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
