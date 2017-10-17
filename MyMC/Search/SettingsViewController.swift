//
//  SettingsViewController.swift
//  MyMC
//
//  Created by Joe  Riess on 6/2/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import SafariServices
import FirebaseDatabase
import SwiftyJSON
import Alamofire

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //
    @IBOutlet weak var settingsTableView: UITableView!

    let sectionsData: [String: [String]] = ["Support": ["Feedback", "Support"],
                                            "About": ["Credits", "Privacy Policy"],
                                            "Tutorial": ["Show Tutorial"]]
    let sectionKeys: [String] = ["About", "Support", "Tutorial"]
    var sectionArray: [Section] = []
    let privacyURL: String = "https://manhattan.edu/privacy"
    let feedbackURL: String = "https://docs.google.com/forms/d/1caeWGfpGCNV0uQYxR5GBQ4K3kfAJtsM9t0ba4vlPtEg/viewform"
    let supportURL: String = "https://manhattan.teamdynamix.com/TDClient/KB/?CategoryID=3318"
    let cellReuseID = "sectionCell"
    let manager = NetworkReachabilityManager(host: "www.google.com")
    struct Section {
        var sectionName: String!
        var sectionItems: [String]!
    }
    var urlDictionary: [String : String] = [:]
    
    let ref = FIRDatabase.database().reference().child("Settings")
    
    // MARK: - View States
    /* Function Directory:
        - viewDidLoad()
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        if !manager!.isReachable {
        let alertController = UIAlertController(title: "Not Connected", message: "Please connect to the internet!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            void in
            self.parent!.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        }

        manager?.listener = { status in
      
            if self.manager!.isReachable {
        self.ref.observeSingleEvent(of: .value, andPreviousSiblingKeyWith: {
            snapshot, values in
            print(values)
            let temp = snapshot.value as! [String : AnyObject]
            print(temp)
            for (name, json) in temp {
                let val = JSON(json)
                
                self.urlDictionary[name] = val["Value"].stringValue
            }
            if self.sectionArray.isEmpty {
            for key in self.sectionKeys {
                let array = self.sectionsData[key]
                let section = Section(sectionName: key, sectionItems: array)
                
                self.sectionArray.append(section)
            }
            }
            self.settingsTableView.reloadData()
        })
            } else {
                            }
            
        }
        
        manager?.startListening()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = Colors.Grey.dark
        navigationController?.navigationBar.barStyle = .default
    }
    /* End View States */

    
    // MARK: - UITableViewDataSource Functions
    /* Function Directory
        - numberOfSectionsInTableView()
        - tableView(numberOfRowsInSection)
        - tableView(cellForRowAtIndexPath)
        - tableView(titleForHeaderInSection)
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionArray[section].sectionItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! SettingsTableViewCell
        
        cell.cellLabel.text = sectionArray[indexPath.section].sectionItems[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArray[section].sectionName
    }
    /* End UITableViewDataSource Functions */
    
    
    // MARK: - UITableViewDelegate Functions
    /* Function Directory
        - tableView(didSelectRowAtIndexPath)
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sectionArray[indexPath.section].sectionName == "About" {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "about", sender: nil)
            } else if indexPath.row == 1 {
                presentSafariViewControllerWithURLString(urlDictionary["Privacy Policy"]!)
            }
        } else if sectionArray[indexPath.section].sectionName == "Support" {
            if indexPath.row == 0 {
                presentSafariViewControllerWithURLString(urlDictionary["Feed Back"]!)
            } else if indexPath.row == 1 {
                presentSafariViewControllerWithURLString(urlDictionary["Support"]!)
            }
            
        } else if sectionArray[indexPath.section].sectionName == "Tutorial" {
            // Perform segure for tutorial vc
            var imgArr: [String] = []
            for i in 1...20 {
                imgArr.append("iphone\(i)")
            }
            let defaults = UserDefaults.standard
            defaults.set(imgArr, forKey: "tutorialImages")
            performSegue(withIdentifier: "showTutorial", sender: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    // MARK - Misc Functions
    /* Function Directory
        - presentSafariViewControllerWithURLString(url)
    */
    /**
     Takes in a url string and present a SFSafariViewController with that string if it is valid
     - parameter url: URL string to present in SFSafariViewController
     */
    func presentSafariViewControllerWithURLString(_ url: String) {
        if let nsURL = URL(string: url) {
            let svc = SFSafariViewController(url: nsURL, entersReaderIfAvailable: true)
            present(svc, animated: true, completion: nil)
        }
    }
    /* End Misc Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "about" {
            (segue.destination as! AboutViewController).postArray = [urlDictionary["About"]!, urlDictionary["Credits"]!]
        }
    }

}
