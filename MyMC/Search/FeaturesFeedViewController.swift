//
//  FeaturesFeedViewController.swift
//  MyMC
//
//  Created by Joe  Riess on 6/9/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class FeaturesFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var toolBar: UIToolbar!
    // Variables
    let reuseId = "subscribedFeedCell"
    let defaults = UserDefaults.standard
    var usersSelectedFeeds: [String] = []
    let realm = try! Realm()
    var vc: feedTableViewController!
    lazy var twitterUsers: Results<Twitter> = { self.realm.objects(Twitter.self) }()
    lazy var localTwitter: FavoriteSet = { self.realm.objects(FavoriteSet.self).filter(NSPredicate(format: "type = %@", argumentArray: ["Twitter"]))[0] }()
    
    var didUpdate: Bool! = false
    @IBAction func closeMenu(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: {
            if self.didUpdate!  {
                self.vc.counter = 0
                self.vc.loadPosts(under: "Twitter View")
            }
            
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load users deafults if any
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = nil
        toolBar.isTranslucent = false
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolBar.barTintColor = Colors.Grey.light
        toolBar.tintColor = Colors.Grey.dark
        print("local twitter")
        print(localTwitter)
  
        print(twitterUsers)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
  
        // Save the settings to users defaults
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return twitterUsers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! FeedSettingsTableViewCell
        
        let user = twitterUsers.sorted(byProperty: "name", ascending: true)[indexPath.row]
        
        cell.label.text = user.name
        if cell.label.text == "Manhattan College" {
            cell.isUserInteractionEnabled = false
            cell.contentView.alpha = 0.3
        } else {
            cell.isUserInteractionEnabled = true
            cell.contentView.alpha = 1.0
        }
        
        cell.tintColor = Colors.Green.dark
        
        
        if user.subscribed {
            cell.accessoryType = .checkmark
            cell.accessoryView?.tintColor = Colors.Green.dark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FeedSettingsTableViewCell
        didUpdate = true
        let user = twitterUsers.sorted(byProperty: "name", ascending: true)[indexPath.row]
        var subscribed: Bool = false
        if user.name != "Manhattan College" {
            if let userAuth = FIRAuth.auth()?.currentUser {
                let userID = userAuth.uid
                let ref = FIRDatabase.database().reference().child("Users/\(userID)/Twitter/Handles")
                var localArray = localTwitter.idSet.components(separatedBy: ", ")
                localArray.removeLast()
                var localSet = Set(localArray.map { $0 })
                var final: String = ""
                if user.subscribed {
                    localSet.remove(user.handle)
                } else {
                    var tempSet: Set<String> = [user.handle]
                    localSet.formUnion(tempSet)
                }
                   localSet.map { final.append("\($0), ") }
                print("JUUUUMMPPP")
                ref.setValue(final, withCompletionBlock: {
                    error, firref in
                    
                    tableView.reloadData()
                })
                
            } else {
                if user.subscribed {
                    try! realm.write {
                        user.subscribed = false
                        realm.add(user, update: true)

                    }
                    
                    
                    
                    tableView.cellForRow(at: indexPath)?.accessoryType = .none
                } else {
                    try! realm.write {
                        user.subscribed = true
                        realm.add(user, update: true)

                    }
                    
                    subscribed = true
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    tableView.cellForRow(at: indexPath)?.accessoryView?.tintColor = Colors.Green.dark
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
