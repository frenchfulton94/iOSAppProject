//
//  mainMenuTableViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 6/2/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import SafariServices
import PassKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class mainMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Variables
    // MARK: - Variables
    var menu = ["HOME", "FEED", "CALENDAR", "QUADRANGLE", "SETTINGS", "JasperCard"]
    var VC = ["Search", "FeedVC", "CalendarVC", "QuadrangleVC", "SettingsVC"]
    var colors = [ UIColor(red: 163/255, green: 208/255, blue: 50/255, alpha: 1.0),
                   UIColor(red: 90/255, green: 136/255, blue: 39/255, alpha: 1.0),
                   UIColor(red: 165/255, green: 24/255, blue: 144/255, alpha: 1.0),
                   UIColor(red: 212/255, green: 93/255, blue: 0/255, alpha: 1.0),
                   UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0),
                   UIColor(red: 0/255, green: 112/255, blue: 60/255, alpha: 1.0)]
    // UIView States
    /* Function Directory:
        - viewDidLoad()
        - viewWillAppear(animated: Bool)
    */
    // MARK: - UIView States
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let navBar = self.navigationController!.navigationBar
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.tintColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        
        if self.parent?.navigationItem.title == nil {
            self.parent!.navigationItem.titleView = nil
        } else {
            self.parent!.navigationItem.title = nil
        }
        navBar.barTintColor = UIColor.clear
        navBar.backgroundColor = UIColor.clear
    }
    
    // UITableView Data Source & Delegate
    /* Function Directory:
        - numberOfSectionsInTableView(tableView: UITableView)
        - tableView(numberOfRowsInSection)
        - tableView(cellForRowsAtIndexPath)
        - tableView(didSelectRowAtIndexPath)
     */
    // MARK: - UITableView Data Source & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if PKPassLibrary.isPassLibraryAvailable() {
            let passLibrary = PKPassLibrary()
            if passLibrary.passes().count == 0 {
                return menu.count
            } else {
                return menu.count - 1
            }
            
        } else {
            return menu.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainMenuCell", for: indexPath) as! mainMenuTableViewCell
        
        cell.menuItemLabel.text = menu[indexPath.row]
        cell.menuItemLabel.textColor = colors[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: false)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let root = parent?.navigationController?.viewControllers
        root![0].navigationItem.leftBarButtonItems = nil
        
        if root![0].navigationItem.rightBarButtonItems?.count > 1 {
            root![0].navigationItem.rightBarButtonItems!.removeLast()
        }

        (root![0] as! MainViewController).backgroundImageView.image = nil
        if indexPath.row != 5 {
            
            
            if root!.count > 1 {
                
               _ = navigationController?.popToRootViewController(animated: false)
                navigationController?.setToolbarHidden(true, animated: false)
                
                parent?.navigationController?.toolbar.isHidden = true
                
            } else {
                
                root![0].childViewControllers[1].removeFromParentViewController()
                root![0].view.viewWithTag(21)!.removeFromSuperview()
            }
            
            var VCtitle = menu[indexPath.row]
            if VCtitle == "HOME" {
                VCtitle = "SEARCH"
                
            }
            
          
            if root![0].childViewControllers[0].title != VCtitle {
                root![0].childViewControllers[0].removeFromParentViewController()
                (root![0] as! MainViewController).view.viewWithTag(22)!.removeFromSuperview()
                let vc = storyboard.instantiateViewController(withIdentifier: VC[indexPath.row])
                root![0].addChildViewController(vc)
                vc.view.tag = 22
                if VCtitle != "Quadrangle" {
                    var height = (root![0] as! MainViewController).containerView.frame.height
                     vc.view.frame.size.height =  height
                } else {
                    var height = UIScreen.main.bounds.height
                    vc.view.frame.size.height =  height
                    vc.view.frame.origin.y = 0
                }
                
               

                if root![0].navigationItem.title == nil {
                    root![0].navigationItem.titleView = nil
                } else {
                    root![0].navigationItem.title = nil
                }
                (root![0] as! MainViewController).containerView.addSubview(vc.view)
                if root![0].childViewControllers[0].title == "SEARCH" {
                    if (root![0].childViewControllers[0] as! SearchViewController).MCShieldImageView.alpha == 1.0 {
                        
                    }
                }
                
            } else {
                

                    root![0].childViewControllers[0].viewWillAppear(true)
//
            }
        } else {
            if let url = URL(string: "https://jaspercardws.manhattan.edu/wallet/my/jasper_card.pkpass") {
                let svc = SFSafariViewController(url: url)
                present(svc, animated: true, completion: nil)
            }
            
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
