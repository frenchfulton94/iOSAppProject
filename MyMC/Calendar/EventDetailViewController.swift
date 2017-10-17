//
//  EventDetailViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 3/11/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import SafariServices
class EventDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Outlets
    // MARK: - Outlets
   
    @IBOutlet weak var locationButton: UIBarButtonItem!
    @IBOutlet weak var eventTableView: UITableView! {
        didSet {
            eventTableView.rowHeight = UITableViewAutomaticDimension;
            eventTableView.estimatedRowHeight = 220.0;
        }
    }
    @IBOutlet weak var eventActionsToolbar: UIToolbar! {
        didSet {
            eventActionsToolbar.isTranslucent = false
            eventActionsToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            eventActionsToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
            eventActionsToolbar.barTintColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
            eventActionsToolbar.tintColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        }
    }
    var header : ParallaxHeaderView!
  
    
    
    // Class Variables
    // MARK: - Variables
    var event: Event!
   
    
    // Actions
    // MARK: - Actions
    @IBAction func showLocation(_ sender: UIBarButtonItem) {
        
        if event.eventLocation != "" {
            performSegue(withIdentifier: "showLocation", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Location Not Available", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)        }
        
    }
    @IBAction func addEventToCalendar(_ sender: UIBarButtonItem) {
       
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)        
//        let browserAction = UIAlertAction(title: "Open in Browser", style: .Default) {
//            (action) in
//            //        }
//        
//        alert.addAction(cancelAction)
//        alert.addAction(browserAction)
//        
//        presentViewController(alert, animated: true, completion: nil)
        
        UIApplication.shared.openURL(self.event.eventAddURL)

    }
    
    @IBAction func shareEvent(_ sender: UIBarButtonItem) {
        let string: String! = event.eventTitle + "\n" + event.keyStartString + "\n@ " + event.eventTime + " \n\n"
        
        let activityViewController = UIActivityViewController(activityItems: [string, event.eventShareURL], applicationActivities: nil)
        
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    
    
    // UIView States
    /* Function Directory:
        - viewWillAppear()
        - viewDidLoad()
    */
    // MARK: - UIViewStates
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//           self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
     
        
        
        
    }
//    navBar.translucent = true
//    navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//    navBar.shadowImage = UIImage()
//    navBar.tintColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
//    
//    navBar.barTintColor = UIColor.clearColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let month = event.keyStartString.components(separatedBy: ", ")[1].components(separatedBy: " ")[0]
        let day = event.keyStartString.components(separatedBy: ", ")[0]
        let dayNum = event.keyStartString.components(separatedBy: ", ")[1].components(separatedBy: " ")[1]
        
//        let size = CGRect(x: 0, y: 0, width: eventTableView.frame.size.width, height: 165)
        //let headerView = EventDetailHeaderView(size: size, month: month, day: day, dayNum: dayNum, imgURL: event.eventImageURLString)
        if let headerView = Bundle.main.loadNibNamed("EventDetailTableHeader", owner: self, options: nil)?.first as? EventDetailTableHeader {
            headerView.eventDay.text = day
            headerView.eventMonth.text = month
            headerView.eventDayNum.text = dayNum
            headerView.frame.size.width = view.frame.width
           
            guard let string = event.eventImageURLString else {
                
                headerView.filterView.backgroundColor = UIColor(red: 0/255, green: 112/255, blue: 60/255, alpha: 1.0)
                header = ParallaxHeaderView.parallaxHeaderView(withSubView: headerView) as! ParallaxHeaderView
                eventTableView.tableHeaderView = header
                 headerView.loadIcon.stopAnimating()
                
                return
            }
            
            guard let url = URL(string: string) else {
                headerView.filterView.backgroundColor = UIColor(red: 0/255, green: 112/255, blue: 60/255, alpha: 1.0)
                header = ParallaxHeaderView.parallaxHeaderView(withSubView: headerView) as! ParallaxHeaderView
                eventTableView.tableHeaderView = header
                 headerView.loadIcon.stopAnimating()
                return
            }
            let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            headerView.eventImage.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: queue, imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: true, completion: {
                    void in
                headerView.loadIcon.stopAnimating()
            })
            

            headerView.filterView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        header = ParallaxHeaderView.parallaxHeaderView(withSubView: headerView) as! ParallaxHeaderView
        eventTableView.tableHeaderView = header
        }
                
  
    }
    
    
    // UITableViewDataSource
    /* Function Directory:
        - numberOfSectionsInTableView()
        - tableView(numberOfRowsInSection)
        - tableView(cellForRowAtIndexPath)
    */
    // MARK: - UITableViewDataSource Function
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventDetailCell", for: indexPath) as! eventDetailTableViewCell
        
        cell.eventDetailLabel.numberOfLines = 0
        switch indexPath.row {
        case 0:
            cell.eventDetailLabel.text = event.eventTitle
            cell.eventDetailLabel.font = UIFont(name: "ScalaSansOT-CondBold", size: 20)
            cell.eventDetailLabel.textColor = UIColor(red: 0/255, green: 112/255, blue: 60/255, alpha: 1.0)
            
        case 1:
            cell.eventDetailLabel.text = event.eventTime + "\n" + event.eventLocation
            cell.eventDetailLabel.font = UIFont(name: "ScalaSansOT-Light", size: 16)
            cell.eventDetailLabel.textColor =  UIColor(red: 90/255, green: 136/255, blue: 39/255, alpha: 1.0)
        default:
            cell.eventDetailLabel.text = event.eventDesrciption
            cell.eventDetailLabel.font = UIFont(name: "ScalaSansOT-Cond", size: 18)
            cell.eventDetailLabel.textColor =  UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        }
        
        return cell
    }
    
    
    // Navigation Functions
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("cheese")
        if segue.identifier == "showLocation" {
            (segue.destination as! MapViewController).selectedEvent = event
        } 
       
    }
    
    
    // Misc
    /* Function Directory:
        - shouldPerformSegueWithIdentifier()
    */
    // MARK: - Misc Functions
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showEventDetails" {
            return false
        } else {
            return true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerView = eventTableView.tableHeaderView as! ParallaxHeaderView
        headerView.layoutHeaderView(forScrollOffset: scrollView.contentOffset)
        eventTableView.tableHeaderView = headerView
    }
    
    
}
