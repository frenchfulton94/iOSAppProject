//
//  SearchViewController.swift
//  MyMC
//
//  Created with <3 by MobileSquad on 3/1/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import MessageUI
import Foundation
import SwiftyJSON
import SafariServices
import ReachabilitySwift
import AlgoliaSearch
import RealmSwift
import Firebase
import FirebaseAuth

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITextFieldDelegate {
    
    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var MCShieldImageView: UIImageView!
    @IBOutlet weak var loadIcon: UIActivityIndicatorView!
    @IBOutlet weak var userButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    @IBOutlet weak var actionToolBar: UIToolbar! {
        didSet {
            
            actionToolBar.setShadowImage(image, forToolbarPosition: .any)
            actionToolBar.setBackgroundImage(image, forToolbarPosition: .any, barMetrics: .default)
        }
    }
    
    @IBAction func presentFavorites(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showFavorites", sender: nil)
    }
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.isTranslucent = false
            searchBar.backgroundColor = Colors.Grey.light
            searchBar.showsCancelButton = true
            searchBar.setShowsCancelButton(true, animated: false)
            searchBar.tintColor = Colors.Grey.dark
            
            let textfield = searchBar.value(forKey: "searchField") as! UITextField
            textfield.textColor = Colors.Grey.dark
            textfield.clearsOnBeginEditing = true
        }
    }
    
    // Class Variables
    // MARK: - Class Variables
    let client = Client(appID: "", apiKey: "")
    var employeeQueryArray: [Faculty] = []
    var servicesQueryArray: [Services] = []
    var sectionsArray: [Any?] = []
    var sectionTitleArray: [String] = []
    var selectedIndex: UInt8!
    var selectedImage: UIImage!
    let manhattanPlaceholderImage: UIImage! = UIImage(named: "manhattanLogoDefault")
    let profilePlaceHolderImage: UIImage! = UIImage(named: "profileDefaultImage")
    var statusBar: UIView!
    var reachability: Reachability!
    let realm = try! Realm()
    lazy var favoriteServices: Results<FavoriteSet> = { self.realm.objects(FavoriteSet.self).filter(NSPredicate(format: "type = %@", argumentArray: ["Services"])) }()
    let image = UIImage()
    var favoritesArray: [String] = []
    
    // Actions
    // MARK: - Actions
    @IBAction func showSearch(_ sender: UIBarButtonItem) {
     
        animateSearchBar()
    }
    
    @IBAction func showUserProfile(_ sender: UIBarButtonItem) {
        
//        let alertController = UIAlertController(title: "Coming Soon", message: "", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        self.present(alertController, animated: true, completion: nil)
            performSegue(withIdentifier: "showUserProfile", sender: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if searchResultsTableView.isHidden {
        let navBar = navigationController!.navigationBar
        navBar.barStyle = .default
        navBar.isTranslucent = true
        navBar.setBackgroundImage(image, for: .default)
        navBar.shadowImage = image
        navBar.tintColor = Colors.Grey.dark
        navBar.barTintColor = UIColor.clear
        }
       
        
    }
    
    
    // UIView States
    // MARK: - View States
    override func viewDidLoad() {
        super.viewDidLoad()
    
      
        let nib = UINib(nibName: "SearchTableViewHeader", bundle: nil)
        searchResultsTableView.register(nib, forHeaderFooterViewReuseIdentifier: "SearchTableViewHeader")
        
        UIView.animate(withDuration: 0.5, animations: {
            self.actionToolBar.isHidden = false
        }) 
        
    }
    
    
    /**
     Will animate the search bar based on its alpha.
     */
    func animateSearchBar() {
        
        if searchBar.isHidden {
            (self.parent as! MainViewController).timer.invalidate()
            (self.parent as! MainViewController).backgroundImageView.image = nil
            UIView.animate(withDuration: 0.3, delay: 0.0,
                                       options: .curveEaseOut,
                                       animations: {
                                        self.searchBar.isHidden = false
                                        
                                        self.MCShieldImageView.alpha = 0.0
                                        self.actionToolBar.isHidden = true
                                        self.searchResultsTableView.isHidden = false
                                        self.navigationController?.navigationBar.barTintColor = Colors.Grey.light
                                        self.navigationController?.navigationBar.isTranslucent = false
                                        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.Grey.dark,
                                            NSFontAttributeName: UIFont(name: Fonts.tradeGothic, size: 20)!]
                                        
                                        
                                        self.searchBar.becomeFirstResponder()
                                        
                },completion: {
                    void in
                    self.search("")
            })
        } else {
            
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                                            NSFontAttributeName: UIFont(name: Fonts.tradeGothic, size: 20)!]
             (self.parent as! MainViewController).initTimer()
            UIView.animate(withDuration: 0.3, delay: 0.0,
                                       options: .curveEaseOut,
                                       animations: {
                                       
                                        self.searchBar.isHidden = true
                                        self.searchResultsTableView.isHidden = true
                                        self.navigationController?.navigationBar.barTintColor = UIColor.clear
                                        self.MCShieldImageView.alpha = 1.0
                                        self.actionToolBar.isHidden = false
                                        (self.parent as! MainViewController).timer.fire()
                                      
                                                        },
                                       completion: {
                                        Void in
                                      
                                       
                                       
                                      

            })
            
            employeeQueryArray = []
            servicesQueryArray = []
            sectionsArray = []
            sectionTitleArray = []
            searchResultsTableView.reloadData()
            
        }
    }
    
    
    // UITableViewDataSource Functions
    /* Functions Directory:
     - numberOfSectionsInTableView() -> Int
     - tableView(numberOfRowsInSection) -> Int
     - tableView(cellForRowAtIndexPath) -> UITableViewCell
     - tableView(titleForHeaderInSection) -> String?
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch sectionTitleArray[section] {
        case "Employees":
            return employeeQueryArray.count
        case "Services" :
            return servicesQueryArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        if sectionTitleArray[indexPath.section] == "Employees" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainDirectoryCell", for: indexPath) as! MainTableViewCell
            let emp = employeeQueryArray[indexPath.row]
            cell.VC = self
            cell.nameLabel.text = emp.name
            cell.nameLabel.textColor = Colors.Green.dark
            cell.sectionLabel.text = emp.department
            cell.emailAddress = emp.email
            cell.currentViewController = self
            cell.profileImageView.layer.cornerRadius = 25
            cell.postionLabel.text = emp.title
  
            guard let employeeImageURL = emp.imageURL else {
                cell.profileImageView.image = profilePlaceHolderImage
                return cell
            }
            
            let httpsConvertedString = employeeImageURL.replacingOccurrences(of: "http", with: "https")
            
            guard let url = URL(string: httpsConvertedString) else {
                return cell
            }
            
            cell.profileImageView.af_setImage(withURL: url, placeholderImage: profilePlaceHolderImage, filter: nil, progress: nil, progressQueue: queue, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
            
            cell.setNeedsLayout()
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "servicesDirectoryCell", for: indexPath) as! servicesTableViewCell
            let serv = servicesQueryArray[indexPath.row]
            cell.servicesName.text = serv.title
            
            cell.servicesInfo.text = serv.summary?.capitalized
            var image = UIImage(named: "favDefault")
            cell.VC = self
            cell.indexPath = indexPath
            
            if let user = FIRAuth.auth()?.currentUser {
                if favoritesArray.contains(serv.objectID) {
                    image = UIImage(named: "favorited")
                    cell.favorited = true
                }
                
            } else {
            
            if let idArr = favoriteServices.first?.idSet {
            if idArr.contains(serv.objectID) {
                image = UIImage(named: "favorited")
                cell.favorited = true
            }
            }
                
            }
            let frame = CGRect(x: 0, y: 0, width: 50, height: cell.frame.height)
            let button = UIButton(frame: frame)
            button.setImage(image, for: UIControlState())
            button.addTarget(cell, action: #selector(cell.updateFavorites), for: .touchUpInside)
            button.contentMode = .center
            cell.accessoryView = button
            cell.service = serv
            guard let url = URL(string: serv.graphicURLString!) else {
                cell.serviceIconView.image = manhattanPlaceholderImage
                return cell
            }
            
            cell.serviceIconView.af_setImage(withURL: url, placeholderImage: manhattanPlaceholderImage, filter: nil, progress: nil, progressQueue: queue, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
            
            cell.setNeedsLayout()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SearchTableViewHeader") as! SearchTableViewHeader
        header.SearchSectionLabel.text = sectionTitleArray[section]
        
        return header
    }
    
    
    // UITableViewDelegate Functions
    /* Functions Directory:
     - tableView(didSelectRowAtIndexPath)
     */
    // MARK: - UITableViewDelegate Functions
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if sectionTitleArray[indexPath.section] == "Employees" {
            selectedIndex = UInt8(indexPath.row)
            searchBar.resignFirstResponder()
            let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
            if let image = cell.profileImageView.image {
                selectedImage = image
            }
            performSegue(withIdentifier: "presentPersonProfile", sender: nil)
        } else {
            
            let alert = {
              
                let alertController = UIAlertController(title: "Link Not Availble", message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            guard let urlS = servicesQueryArray[indexPath.row].urlString else {
                alert()
                return
            }
            if urlS != "" {
                
                guard let url = URL(string: urlS) else {
                    alert()
                    return
                }
                
                let svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                present(svc, animated: true, completion: nil)
            } else {
              alert()
            }
        }
    }
    
    
    // UISearchbarDelegate
    /* Function Directory:
     - searchBarShouldBeginEditing(searchBar) -> Bool
     - searchBar(textDidChange)
     */
    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        employeeQueryArray.removeAll()
//        servicesQueryArray.removeAll()
//        searchResultsTableView.reloadData()
        search(searchText)

    }
    
    func search(_ q: String) {

        self.loadIcon.isHidden = false
        self.loadIcon.startAnimating()
        let top = CGRect(x: 0, y: 0, width: self.searchResultsTableView.frame.width, height: self.searchResultsTableView.frame.height)
        self.searchResultsTableView.scrollRectToVisible(top, animated: false)
        
        let servicesQuery = Query(query: q)
        let employeeQuery = Query(query: q)
        
        servicesQuery.attributesToRetrieve = ["Description", "Title", "URL for App", "Icon URL", "Department Owner"]
        servicesQuery.hitsPerPage = 10
        employeeQuery.hitsPerPage = 10
        
        let queries = [
            IndexQuery(indexName: "dev_MC_Employees", query: employeeQuery),
            IndexQuery(indexName: "portal_app_services", query: servicesQuery)
        ]
        
        self.client.multipleQueries(queries, strategy: "none" , completionHandler: {
            (content, error) -> Void in
            if error == nil {
                let json = JSON(content!)
                let employeeHits: [JSON] = json["results"][0]["hits"].arrayValue
                let servicesHits: [JSON] = json["results"][1]["hits"].arrayValue
                
                var tempEmp = [Faculty]()
                for results in employeeHits {
                    let faculty = Faculty(json: results)
                    tempEmp.append(faculty)
                }
                self.employeeQueryArray = tempEmp
                
                var tempServ = [Services]()
                for record in servicesHits {
                    tempServ.append(Services(json: record))
                }
                self.servicesQueryArray = tempServ
                
                self.checkRecords()
                
                self.updateFavorites()
                
                
                
            } else {
                self.loadIcon.stopAnimating()
                print("There was an error reaching Algolia")
                print("Error: \(error)")
            }
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        animateSearchBar()
        employeeQueryArray.removeAll()
        servicesQueryArray.removeAll()
        
    }
    
    
    // UIScrollViewDelegate
    /* Function Directory:
     - scrollViewWillBeginDragging
     */
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    // MARK: - Array functions
    /**
     This function is used to check the the status of each search array.
     * * * * *
     - If there is data in the array, this function will append the number of elements
     stored in that array to another array called numOfRecordsArray.
     - Also, if there is data, this function will append the appropriate name (which is used to put into the tableView header.
     */
    func checkRecords() {
        sectionsArray = []
        sectionTitleArray = []
        
        if servicesQueryArray.count != 0 {
            sectionsArray.append(servicesQueryArray)
            sectionTitleArray.append("Services")
        }
        
        if employeeQueryArray.count != 0 {
            sectionsArray.append(employeeQueryArray)
            sectionTitleArray.append("Employees")
            
        }
    }
    
    // Misc Functions
    /* Function Directory
     - mailComposeController(didFinishWithResults)
     - prepareForSegue()
     - touchesBegan(withEvent)
     */
    // MARK: Misc Functions
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPersonProfile" {
            (segue.destination.childViewControllers[0] as! DirectoryProfileViewController).person = employeeQueryArray[Int(self.selectedIndex)]
        } 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if searchBar.alpha == 1.0 && touches.first!.view != searchBar {
            view.endEditing(true)
            animateSearchBar()
            searchResultsTableView.isHidden = true
        }
        
    }
    
    func updateFavorites() {
        
        if let user = FIRAuth.auth()?.currentUser {
            let userID = user.uid
            let ref = FIRDatabase.database().reference().child("Users/\(userID)/Favorites/Services")
            ref.observeSingleEvent(of: .value, with: {
                snapshot in
                if snapshot.exists() {
                    var idArr = (snapshot.value as! String).components(separatedBy: ", ")
                    print("idARR \(idArr)")
                    idArr.removeLast()
                    self.favoritesArray = idArr
                  
                    self.searchResultsTableView.reloadData()
                    UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseOut , animations: {
                    
                        self.loadIcon.stopAnimating()
                        self.searchResultsTableView.isHidden = false
                    }, completion: nil)
                
                    
                }
            })
            
        } else {
              self.searchResultsTableView.reloadData()
            UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseOut , animations: {
                
                self.loadIcon.stopAnimating()
                self.searchResultsTableView.isHidden = false
            }, completion: nil)
        }
    }
    
    }

