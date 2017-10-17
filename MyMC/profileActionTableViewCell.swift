//
//  profileActionTableViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 8/15/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import MessageUI
import RealmSwift
import Firebase
import FirebaseAuth

class profileActionTableViewCell: UITableViewCell {
    @IBOutlet weak var toolBar: UIToolbar! {
        didSet{
            toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
            toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        }
    }
    @IBOutlet weak var phoneButton: UIBarButtonItem!
    @IBOutlet weak var emailButton: UIBarButtonItem!
    @IBOutlet weak var locationButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    
    var name: String!
    var phoneNumber: String?
    var emailAddress: String?
    var currentViewController: UIViewController!
    var VCtitle: String!
    var location: String?
    var person: Faculty!
    var favoritesArray: [String] = []
    
    var realm = try! Realm()
    
    @IBAction func addToFavorites(_ sender: UIBarButtonItem) {
       var image: UIImage!
        
        
        if let user = FIRAuth.auth()?.currentUser {
            let userID = user.uid
            let ref = FIRDatabase.database().reference().child(
                "Users/\(userID)/Favorites/Faculty")
            ref.observeSingleEvent(of: .value, with: {
                snapshot in
                
                if snapshot.exists() {
                    var finalString: String! = ""
                    var values = (snapshot.value as! String)
                    var arr = values.components(separatedBy: ", ")
                    arr.removeLast()
                    
                    var arrSet: Set<String> = Set( arr.map { $0 } )
                    if arrSet.contains(self.person!.objectID) {
                        arrSet.remove(self.person!.objectID)
                         image = UIImage(named: "favDefault")
                    } else {
                        let temp: Set<String> = [self.person!.objectID]
                        arrSet.formUnion(temp)
                        image = UIImage(named: "favorited")
                    }
                    _ = arrSet.map { finalString.append("\($0), ") }
                    ref.setValue(finalString)
                    
                    var items = self.toolBar.items
                    
                    let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.addToFavorites(_:)))
                    items![7] = button
                    self.toolBar.setItems(items, animated: false)
                    
                    
              
                }
            })
        } else {
            
            let predicate = NSPredicate(format: "type = %@", "Faculty" )
            if let facultySet = self.realm.objects(FavoriteSet.self).filter(predicate).first {
                do {
                    
                    
                    try realm.write {
                        var arr = facultySet.idSet.components(separatedBy: ", ")
                        arr.removeLast()
                        var finalString: String! = ""
                        var arrSet = Set(arr.map {$0})
                        if arrSet.contains(person!.objectID) {
                            arrSet.remove(person!.objectID)
                            image = UIImage(named: "favDefault")

                        } else {
                            let temp: Set<String> = [person!.objectID]
                            arrSet.formUnion(temp)
                            image = UIImage(named: "favorited")
                            
                        }
                        _ = arrSet.map { finalString.append("\($0), ") }
                        facultySet.idSet = finalString
                        
                        
                        var items = toolBar.items
                        
                        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.addToFavorites(_:)))
                        items![7] = button
                        toolBar.setItems(items, animated: false)
                    }

                } catch {
                    
                }
                
            }
            
        }

        
        
    }
    @IBAction func makeCall(_ sender: UIBarButtonItem) {
        print("making a call")
        //        Animations.makeItBounceHeavy(phoneButton)
        if self.phoneNumber != nil {
            if let url = URL(string: "tel://\(phoneNumber!)") {
                UIApplication.shared.openURL(url)
            }
        } else {
             let alertController = UIAlertController(title: "Phone Nubmer Not Available", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.currentViewController.present(alertController, animated: true, completion: nil)
        }
        
    }
    @IBAction func sendEmail(_ sender: UIBarButtonItem) {
        
        if emailAddress != nil {
            let mailComposeViewController = configuredMailComposeViewController()
            
            if MFMailComposeViewController.canSendMail() {
                self.currentViewController!.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                let string = "Hello \(name)"
                let activityViewController = UIActivityViewController(activityItems: [string], applicationActivities: nil)
                activityViewController.excludedActivityTypes = [ UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.postToWeibo, UIActivityType.message, UIActivityType.print, UIActivityType.copyToPasteboard,UIActivityType.assignToContact,UIActivityType.saveToCameraRoll,UIActivityType.addToReadingList, UIActivityType.postToFlickr, UIActivityType.postToVimeo,UIActivityType.postToTencentWeibo,UIActivityType.airDrop]
                activityViewController.setValue("" , forKey: "subject")
                
                currentViewController!.navigationController?.present(activityViewController, animated: true) {
                    // ...
                }
                
            }
        } else {
            let alertController = UIAlertController(title: "Email Not Available", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.currentViewController.present(alertController, animated: true, completion: nil)
        }
        
    }
    @IBAction func showLocation(_ sender: UIBarButtonItem) {
        if location != nil {
            self.currentViewController.performSegue(withIdentifier: "showMaps", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Location Not Available", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.currentViewController.present(alertController, animated: true, completion: nil)
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
            mailComposerVC.mailComposeDelegate = self.currentViewController as! SearchViewController
        }// Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([emailAddress!])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("Hello \(name!),", isHTML: false)
        
        return mailComposerVC
    }
    

    
    func showSendMailErrorAlert() {
        
        let sendMailErrorAlert = UIAlertController(title:  "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        
        self.currentViewController?.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    
}

