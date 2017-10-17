//
//  QuadrangleAboutTableViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 6/8/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class QuadrangleAboutTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 2 {
            let url = URL(string: "https://mcquad.org/contact-the-quadrangle/")
            let svc = SFSafariViewController(url:url!)
            present(svc, animated: true, completion: nil)
            
        } else if indexPath.row == 3 {
            let url = URL(string: "https://mcquad.org/staff/")
            let svc = SFSafariViewController(url:url!)
            present(svc, animated: true, completion: nil)
            
            
        } else if indexPath.row == 4 {
            
            func configuredMailComposeViewController() -> MFMailComposeViewController {
                let mailComposerVC = MFMailComposeViewController()
                
                
                mailComposerVC.mailComposeDelegate = self
                
                // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
                
                mailComposerVC.setToRecipients(["thequad@manhattan.edu"])
                mailComposerVC.setSubject("")
                mailComposerVC.setMessageBody("", isHTML: false)
                
                return mailComposerVC
            }
            
            
            func showSendMailErrorAlert() {
                
                let sendMailErrorAlert = UIAlertController(title:  "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
                
               present(sendMailErrorAlert, animated: true, completion: nil)
            }
            
            let mailComposeViewController = configuredMailComposeViewController()
            
            if MFMailComposeViewController.canSendMail() {
                present(mailComposeViewController, animated: true, completion: nil)
            } else {
                let string = ""
                let activityViewController = UIActivityViewController(activityItems: [string], applicationActivities: nil)
                activityViewController.excludedActivityTypes = [ UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.postToWeibo, UIActivityType.message, UIActivityType.print, UIActivityType.copyToPasteboard,UIActivityType.assignToContact,UIActivityType.saveToCameraRoll,UIActivityType.addToReadingList, UIActivityType.postToFlickr, UIActivityType.postToVimeo,UIActivityType.postToTencentWeibo,UIActivityType.airDrop]
                activityViewController.setValue("" , forKey: "subject")
                
                navigationController?.present(activityViewController, animated: true) {
                    // ...
                }
                
            }
            
            
           
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
        print("I canceled")
    }
}
