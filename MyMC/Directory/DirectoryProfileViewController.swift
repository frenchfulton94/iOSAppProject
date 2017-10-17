//
//  ProfileViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/21/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import MessageUI
import AlamofireImage
import RealmSwift
import Firebase
import FirebaseAuth

class DirectoryProfileViewController: UIViewController, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate  {
    
    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var closeButton: UIBarButtonItem! {
        didSet{
            closeButton.setBackgroundImage(UIImage(), for: UIControlState(), barMetrics: .default)
        
        }
    }
   
    @IBOutlet weak var profileTableView: UITableView! {
        didSet {
            let rowHeight = (65 * UIScreen.main.bounds.size.width)/320
            profileTableView.rowHeight = rowHeight
            profileTableView.backgroundColor = UIColor.clear
            profileTableView.tableFooterView = UIView()
            profileTableView.tableFooterView?.backgroundColor = UIColor.clear
            profileTableView.rowHeight = UITableViewAutomaticDimension
            profileTableView.estimatedRowHeight = 85.0
            
        }
    }
    
   
    // Class Variables
    // MARK: - Variables
    var person: Faculty?
    var parentVC: FavoritesViewController?
    let realm = try! Realm()
    var favoritesArray: [String] = []
    
    // Actions
    // MARK: - Actions
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
       
        if let vc = parentVC {
            vc.viewWillAppear(true)
        }
        dismiss(animated: true, completion: nil)
      
    }
    
    
    // View States
    // MARK: - View States
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFavorites()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let navBar = navigationController!.navigationBar
        navBar.barStyle = .default
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.tintColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        navBar.barTintColor = UIColor.clear
        
    }
    
    // TableViewDataSource
    /* Function Directory:
        - numberOfSectionsInTableView(tableView) -> Int
        - tableView(numberOfRowsInSection) -> Int
        - tableView(cellForRowAtIndexPath) -> UITableViewCell
    */
    // MARK: - TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    
            return 3
        
    }
   // if person Other: \(person!.titleTwo!)\n
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainDirectoryCell") as! MainTableViewCell
            
            cell.accessoryType = .none
            cell.nameLabel.textColor = UIColor(red: 0/255, green: 112/255, blue: 60/255, alpha: 1.0)
            cell.nameLabel.text = person!.name
            cell.postionLabel.text = person!.title + " - \(person!.department!)"
            cell.profileImageView.layer.cornerRadius = 75
            cell.backgroundColor = UIColor.clear
            if person!.titleTwo! as String != "" {
                cell.postionLabel.text = cell.postionLabel.text! + "\n\n\(person!.titleTwo!)"
            }
            var urlString: String! = person!.largeImageURL!
            if person!.largeImageURL != nil {
                if person!.largeImageURL!.contains("https") {
                    urlString = person!.largeImageURL
                    
                } else {
                    let newURL = person!.largeImageURL!.replacingOccurrences(of: "http", with: "https")
                    urlString = newURL
                }
            }
            guard let url = URL(string: urlString) else {
                cell.profileImageView.image = UIImage(named: "profileDefaultPhotoLarge")
                return cell
            }
            
            let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            cell.profileImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "profileDefaultImageLarge"), filter: nil, progress: nil, progressQueue: queue, imageTransition: .flipFromLeft(0.5), runImageTransitionIfCached: true, completion: nil)

            
            return cell
        } else if indexPath.row == 1 {
            if person!.phone == "" {
                person!.phone = "N/A"
            }
            
            if person!.officeRoom == "" {
                person!.officeRoom  = "N/A"
            }
            
            if person!.email  == "" {
                person!.email = "N/A"
            }
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! ContactTableViewCell
            cell.conatactInfoView.text = "Office: \(person!.officeRoom!)\nPhone: \(person!.phone!)\nEmail: \(person!.email!)"
            cell.backgroundColor = UIColor.clear
            
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") as! profileActionTableViewCell
            cell.name = person!.name.components(separatedBy: " ")[0]
            if person!.phone  != "N/A" {
                cell.phoneNumber = person!.phone
            }
            if person!.officeRoom  != "N/A" {
                cell.location = person!.officeRoom 
            }  else {
                cell.location = nil
            }
            cell.accessoryType = .none
            if person!.email  != "N/A" {
            cell.emailAddress = person!.email
            } else {
                cell.emailAddress = nil
            }
            cell.currentViewController = self
            cell.person = person
            var image: UIImage! = UIImage(named: "favDefault")
            if FIRAuth.auth()?.currentUser != nil {
                if favoritesArray.contains(person!.objectID) {
                    image = UIImage(named: "favorited")

                }
            } else {
            let predicate = NSPredicate(format: "type = %@", "Faculty")
            let favoriteFaculty = self.realm.objects(FavoriteSet.self).filter(predicate).first
            let idArr = favoriteFaculty?.idSet
            
            if idArr!.contains(person!.objectID){
                image = UIImage(named: "favorited")
            }
            }
            var items = cell.toolBar.items
            
            
            let button = UIBarButtonItem(image: image, style: .plain, target: cell, action: #selector(cell.addToFavorites(_:)))
            items![7] = button
            cell.toolBar.setItems(items, animated: false)
            cell.backgroundColor = UIColor.clear
            return cell
            
        } else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "openURLCell") as! OpenLinkTableViewCell
            
//            cell.URL = (person?.url)
            cell.backgroundColor = UIColor.clear
            
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMaps" {
            let vc = segue.destination as! MapViewController
            vc.selectedPerson = person
        }
    }
    func updateFavorites() {
        
        if let user = FIRAuth.auth()?.currentUser {
            let userID = user.uid
            let ref = FIRDatabase.database().reference().child("Users/\(userID)/Favorites/Faculty")
            ref.observeSingleEvent(of: .value, with: {
                snapshot in
                if snapshot.exists() {
                    var idArr = (snapshot.value as! String).components(separatedBy: ", ")
                    print(idArr)
                    idArr.removeLast()
                    self.favoritesArray = idArr
                    
                    self.profileTableView.reloadData()
                }
            })
            
        }
    }
    
    // Misc
    /* Function Directory:
        - mailComposeController()
        - configureView()
    */
    // MARK: - Misc
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        print("I canceled")
    }
    
    
}
