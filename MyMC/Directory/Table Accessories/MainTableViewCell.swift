//
//  MainTableViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/21/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import MessageUI
import RealmSwift
import Firebase
import FirebaseAuth

class MainTableViewCell: UITableViewCell {
    
    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet{
            
            profileImageView.layer.masksToBounds = true
//            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.bounce))
//            gesture.delegate = self
//            profileImageView.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var postionLabel: UILabel!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var menuItemLabel: UILabel!
    
    // Variables
    // MARK: - Variables
    var emailAddress: String?
    var currentViewController: UIViewController?
    var VCtitle: String!
    let realm = try! Realm()
    var person: Faculty?
    var indexPath: IndexPath?
    var VC: UIViewController!
    var favorited: Bool! = false
 
    
    
    @IBAction func sendEmail(_ sender: UIButton) {
//         Animations.makeItBounceHeavy(mailButton)
        if emailAddress != nil {
            let mailComposeViewController = configuredMailComposeViewController()
            
            if MFMailComposeViewController.canSendMail() {
                self.currentViewController!.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                let string = "Hello \(nameLabel.text)"
                let activityViewController = UIActivityViewController(activityItems: [string], applicationActivities: nil)
                activityViewController.excludedActivityTypes = [ UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.postToWeibo, UIActivityType.message, UIActivityType.print, UIActivityType.copyToPasteboard,UIActivityType.assignToContact,UIActivityType.saveToCameraRoll,UIActivityType.addToReadingList, UIActivityType.postToFlickr, UIActivityType.postToVimeo,UIActivityType.postToTencentWeibo,UIActivityType.airDrop]
                activityViewController.setValue("" , forKey: "subject")
                
                currentViewController!.navigationController?.present(activityViewController, animated: true) {
                    // ...
                }
                
            }
        }
    }
    
    
    func updateFavorites() {
        print(person!.name)
        
        if let user = FIRAuth.auth()?.currentUser {
            let userID = user.uid
            let ref = FIRDatabase.database().reference().child(
                "Users/\(userID)/Favorites/Faculty")
            
            var finalString: String! = ""
            if self.VC.title == "SEARCH" {
                ref.observeSingleEvent(of: .value, with: {
                    snapshot in
                    
                    if snapshot.exists() {
                        var values = (snapshot.value as! String)
                        var arr = values.components(separatedBy: ", ")
                        var arrSet: Set<String> = Set (arr.map{$0})
                        arr.removeLast()
                        print(arr)
                        if arrSet.contains(self.person!.objectID) {
                            arrSet.remove(self.person!.objectID)
                            self.favorited = false
                        } else {
                            let temp: Set<String> = [self.person!.objectID]
                            arrSet.formUnion(temp)
                            self.favorited = true
                            
                        }
                        _ = arrSet.map { finalString.append("\($0), ") }
                        ref.setValue(finalString)
                        var image: UIImage! = UIImage(named: "favDefault")
                        if self.favorited! {
                            image = UIImage(named: "favorited")
                        }
                        var frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                        if self.VC.title == "SEARCH" {
                            frame =  CGRect(x: 0, y: 0, width: 50, height: self.frame.height)
                        }
                        let button = UIButton(frame: frame)
                        button.setImage(image, for: UIControlState())
                        button.addTarget(self, action: #selector(self.updateFavorites), for: .touchUpInside)
                        self.accessoryView = button
                    }
                })
                
            } else {
                var arrSet: Set<String> = Set( (self.VC as! FavoriteSearchViewController).favoritesArray )
                if arrSet.contains(person!.objectID) {
                    arrSet.remove(person!.objectID)
                    self.favorited = false
                    
                } else {
                    let temp: Set<String> = [person!.objectID]
                    arrSet.formUnion(temp)
                    self.favorited = true
                    
                }
                (self.VC as! FavoriteSearchViewController).favoritesArray = Array(arrSet.map { $0 })
                (self.VC as! FavoriteSearchViewController).getObjects()
                
                
                _ = arrSet.map { finalString.append("\($0), ") }
                ref.setValue(finalString)
                
                var image: UIImage! = UIImage(named: "favDefault")
                if self.favorited! {
                    image = UIImage(named: "favorited")
                }
                var frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                if self.VC.title == "SEARCH" {
                    frame =  CGRect(x: 0, y: 0, width: 50, height: self.frame.height)
                }
                let button = UIButton(frame: frame)
                button.setImage(image, for: UIControlState())
                button.addTarget(self, action: #selector(self.updateFavorites), for: .touchUpInside)
                self.accessoryView = button
            }
            
            
        } else {
            
            let predicate = NSPredicate(format: "type = %@", "Faculty" )
            if let facultySet = self.realm.objects(FavoriteSet.self).filter(predicate).first {
                do {
                    
                    var arr = facultySet.idSet.components(separatedBy: ", ")
                    arr.removeLast()
                    var image: UIImage! = UIImage(named: "favDefault")
                    var finalString: String! = ""
                    var arrSet = Set(arr.map {$0})
                   
                    if arrSet.contains(person!.objectID) {
                        arrSet.remove(person!.objectID)
                        self.favorited = false
                        
                        
                    } else {
                        let temp: Set<String> = [person!.objectID]
                        arrSet.formUnion(temp)
                        self.favorited = true
                        image = UIImage(named: "favorited")
                    }
                    _ = arrSet.map { finalString.append("\($0), ") }
                    
    
                    var frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    if self.VC.title == "SEARCH" {
                        frame =  CGRect(x: 0, y: 0, width: 50, height: self.frame.height)
                    }
                    let button = UIButton(frame: frame)
                    button.setImage(image, for: UIControlState())
                    button.addTarget(self, action: #selector(self.updateFavorites), for: .touchUpInside)
                    self.accessoryView = button
                    try realm.write {
                         facultySet.idSet = finalString
                        realm.add(facultySet, update: true)
                    }
                
                    if self.VC.title == "SEARCH" {
                        (self.VC as! FavoriteSearchViewController).searchResultsTableView.reloadRows(at: [self.indexPath!], with: .none)
                       
                    } else {
                         (self.VC as! FavoriteSearchViewController).getObjects()
                    }
               
                
                    
                    
                } catch {
                    
                }
                
            }
            
        }
        
  
        
    }
    
    // Email Functionality
    /* Function Directory:
     - configureMailComposeViewController() -> MFMailComposeViewController
     Setup MFMailComposeViewController
     
     - showSendMailErrorAlert() -> Void
     Alert user to email error
     
     - mailComposeController() -> Void
     Dismiss MFMailComposeViewController after finishing email
     
     */
    // MARK: - Email Functionality
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        
        if currentViewController?.title == "ProfileViewController" {
            mailComposerVC.mailComposeDelegate = self.currentViewController! as! DirectoryProfileViewController
        } else {
            print(self.currentViewController!.title)
            mailComposerVC.mailComposeDelegate = self.currentViewController as! SearchViewController
        }// Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([emailAddress!])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("Hello \(nameLabel.text!.components(separatedBy: " ")[0]),", isHTML: false)
        
        return mailComposerVC
    }
    
   
    func showSendMailErrorAlert() {
        
        let sendMailErrorAlert = UIAlertController(title:  "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        
        self.currentViewController?.present(sendMailErrorAlert, animated: true, completion: nil)
    }
}
