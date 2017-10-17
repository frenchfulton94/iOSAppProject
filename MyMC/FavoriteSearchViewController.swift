//
//  FavoriteSearchViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 11/4/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import AlgoliaSearch
import RealmSwift
import Firebase
import FirebaseAuth

class FavoriteSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var loadIcon: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.isTranslucent = false
            searchBar.backgroundColor = Colors.Grey.light
            searchBar.showsCancelButton = true
            searchBar.setShowsCancelButton(true, animated: false)
            searchBar.tintColor = Colors.Grey.dark
            searchBar.setValue("Done", forKey:"_cancelButtonText")
            let textfield = searchBar.value(forKey: "searchField") as! UITextField
            textfield.textColor = Colors.Grey.dark
            textfield.clearsOnBeginEditing = true
        }

        
    }
  
    @IBOutlet weak var navBar: UINavigationBar!{
        didSet {
            navBar.isTranslucent = false
            navBar.setBackgroundImage(UIImage(), for: .default)
            navBar.shadowImage = UIImage()
        }
    }
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    let client = Client(appID: "4HZF9PBKRR", apiKey: "cd0c24801408a3a43eb4156de1a24541")
    var employeeQueryArray: [Faculty] = []
    var servicesQueryArray: [Services] = []
    let manhattanPlaceholderImage: UIImage! = UIImage(named: "manhattanLogoDefault")
    let profilePlaceHolderImage: UIImage! = UIImage(named: "profileDefaultImage")
    var searchTextString: String = ""
    var isFaculty: Bool!
    let realm = try! Realm()
    lazy var favorites: Results<FavoriteSet> = { self.realm.objects(FavoriteSet.self) }()
    var VC: FavoritesViewController!
    var favoritesArray: [String] = []
    var favEmployees: [Faculty] = []
    var favServices: [Services] = []
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        if isFaculty! {
            VC.favoriteFacultyCollectionView.reloadData()
        } else {
            VC.favoriteLinksCollectionView.reloadData()
        }
        dismiss(animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.searchBar.isUserInteractionEnabled = true
          //updateFavorites(indexPath: nil)
        let nib = UINib(nibName: "SearchTableViewHeader", bundle: nil)
        searchResultsTableView.register(nib, forHeaderFooterViewReuseIdentifier: "SearchTableViewHeader")
        search("")
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let type = isFaculty! ? "Faculty" : "Services"
        let predicate = NSPredicate(format: "type = %@", type)
        var favArray = favorites.filter(predicate).first!.idSet.components(separatedBy: ", ")
        favArray.removeLast()
        let cond = FIRAuth.auth()?.currentUser != nil ? !favoritesArray.isEmpty : !favArray.isEmpty
        return  cond ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
                    return isFaculty! ? favEmployees.count : favServices.count
        } else {
                   return isFaculty! ? employeeQueryArray.count : servicesQueryArray.count
        }
 
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
       
        if isFaculty! {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainDirectoryCell", for: indexPath) as! MainTableViewCell
            let emp = indexPath.section == 1 ? favEmployees[indexPath.row] : employeeQueryArray[indexPath.row]
            cell.VC = self
            cell.nameLabel.text = emp.name
            cell.nameLabel.textColor = UIColor(red: 0/255, green: 112/255, blue: 60/255, alpha: 1.0)
            cell.sectionLabel.text = emp.department
            cell.emailAddress = emp.email
            cell.currentViewController = self
            cell.profileImageView.layer.cornerRadius = 25
            cell.postionLabel.text = emp.title
            cell.indexPath = indexPath
            cell.person = emp
            var image = UIImage(named: "favDefault")
            if FIRAuth.auth()?.currentUser != nil {
                if favoritesArray.contains(emp.objectID) {
                    image = UIImage(named: "favorited")
                }
            } else {
            let predicate = NSPredicate(format: "type = %@", "Faculty")
            let idSet: [String] = favorites.filter(predicate).first!.idSet.components(separatedBy: ", ")
            print("idSet \(emp.objectID)")
            if idSet.contains(emp.objectID){
                image = UIImage(named: "favorited")
            }
            }
            let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let button = UIButton(frame: frame)
            button.setImage(image, for: UIControlState())
            button.addTarget(cell, action: #selector(cell.updateFavorites), for: .touchUpInside)
            button.contentMode = .center
            cell.accessoryView = button
        
            guard let employeeImageURL = emp.imageURL else {
                cell.profileImageView.image = profilePlaceHolderImage
                return cell
            }
            
            let httpsConvertedString = employeeImageURL.replacingOccurrences(of: "http", with: "https")
            
            
            guard let url = URL(string: httpsConvertedString) else {
                return cell
            }
            
            cell.profileImageView.af_setImage(withURL: url, placeholderImage: profilePlaceHolderImage, filter: nil, progress: nil, progressQueue: queue, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: nil)

            cell.setNeedsLayout()
            
            return cell

            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "servicesDirectoryCell", for: indexPath) as! servicesTableViewCell
            let serv = indexPath.section == 1 ? favServices[indexPath.row] : servicesQueryArray[indexPath.row]
            cell.servicesName.text = serv.title
            cell.VC = self
            cell.servicesInfo.text = serv.summary?.capitalized
            let predicate = NSPredicate(format: "type = %@", "Services")
            var image = UIImage(named: "favDefault")
            cell.indexPath = indexPath
            print("I made it here")
            if FIRAuth.auth()?.currentUser != nil {
                if favoritesArray.contains(serv.objectID) {
                    image = UIImage(named: "favorited")
                    cell.favorited = true
                }
                
            } else {
            let idSet = favorites.filter(predicate).first!.idSet.components(separatedBy: ", ")
            if idSet.contains(serv.objectID) {
                image = UIImage(named: "favorited")
                cell.favorited = true
            }
            }
            let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let button = UIButton(frame: frame)
            button.setImage(image, for: UIControlState())
            button.addTarget(cell, action: #selector(cell.updateFavorites), for: .touchUpInside)
            cell.accessoryView = button
            cell.service = serv
            guard let url = URL(string: serv.graphicURLString!) else {
                cell.serviceIconView.image = manhattanPlaceholderImage
                return cell
            }
            cell.serviceIconView.af_setImage(withURL: url, placeholderImage: manhattanPlaceholderImage, filter: nil, progress: nil, progressQueue: queue, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: nil)
     
            cell.setNeedsLayout()
            
            return cell

        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SearchTableViewHeader") as! SearchTableViewHeader
        // WILL BE IMPLEMENTED LATER
        //        let tapGesture = UITapGestureRecognizer()
        //        tapGesture.addTarget(self, action: #selector(self.tableHeaderTapped))
        //
        //        header.addGestureRecognizer(tapGesture)
        if section == 1 {
        
        header.SearchSectionLabel.text = "Favorites"
        } else {
            header.SearchSectionLabel.text = "Search Results"
        }
        
        return header
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        search(searchText)
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let cell = tableView.cellForRow(at: indexPath)
        if isFaculty! {
      (cell as! MainTableViewCell).updateFavorites()
            
        } else {
        (cell as! servicesTableViewCell).updateFavorites()
            
        }
       
    }
    
    func search(_ q: String) {
       
     
        if isFaculty! {
           employeeQueryArray = []
        } else {
           servicesQueryArray = []
        }
        
        self.loadIcon.isHidden = false
        self.loadIcon.startAnimating()
        let top = CGRect(x: 0, y: 0, width: self.searchResultsTableView.frame.width, height: self.searchResultsTableView.frame.height)
        self.searchResultsTableView.scrollRectToVisible(top, animated: false)
      
        let indexName = isFaculty! ? "dev_MC_Employees" : "portal_app_services"
        let index = client.index(withName: indexName)
      
        let query = Query(query: q)
        query.hitsPerPage = 10
        
        query.advancedSyntax = true
   
        index.search(query , completionHandler: {
            (content, error) -> Void in
            if error == nil {
                let json = JSON(content!)
                let hits = json["hits"].arrayValue
                
                
                if self.isFaculty! {
//                    var tempEmp = [Faculty]()
                    for results in hits {
                        

                          self.employeeQueryArray.append(Faculty(json: results))
                    }
            

                } else {
//                    var tempServ = [Services]()
                    
                    for record in hits {
                        self.servicesQueryArray.append(Services(json: record))
                    }
//                     = tempServ
                    
                }
                
                let type = self.isFaculty! ? "Faculty" : "Services"
                let predicate = NSPredicate(format: "type = %@", type)
                var favArray = self.favorites.filter(predicate).first!.idSet.components(separatedBy: ", ")
                
                favArray.removeLast()
                if FIRAuth.auth()?.currentUser != nil {
                    
                    if self.favoritesArray.isEmpty {
                    self.updateFavorites(q: q)
                    self.searchResultsTableView.reloadData()
                        
                    } else {
                           self.searchResultsTableView.reloadSections(IndexSet(integer: 0), with: .none)
                    }
                } else {
                    print(favArray)
                    if favArray.isEmpty {
                        self.searchResultsTableView.reloadData()
                    } else {
                        self.getObjects()
                        //self.searchResultsTableView.reloadSections(IndexSet(integer: 0), with: .none)
                    }
                    
                 
                    
                }
                self.loadIcon.stopAnimating()
                
            }  else {
                self.loadIcon.stopAnimating()
                print("There was an error reaching Algolia")
                print("Error: \(error)")
            }
            
        })

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if isFaculty! {
            VC.favoriteFacultyCollectionView.reloadData()
        } else {
            VC.favoriteLinksCollectionView.reloadData()
        }
        dismiss(animated: true, completion: nil)
//        searchBar.resignFirstResponder()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    

    func updateFavorites(q: String) {
        let type = isFaculty! ? "Faculty" : "Services"
        
        if let user = FIRAuth.auth()?.currentUser {
            let userID = user.uid
            let ref = FIRDatabase.database().reference().child("Users/\(userID)/Favorites/\(type)")
            ref.observeSingleEvent(of: .value, with: {
                snapshot in
                if snapshot.exists() {
                    var idArr = (snapshot.value as! String).components(separatedBy: ", ")
                   
                    idArr.removeLast()
                    self.favoritesArray = idArr
                    
//                    let cond = self.isFaculty! ? self.employeeQueryArray.isEmpty : self.servicesQueryArray.isEmpty
//                    if  cond  {
//                        
//                        self.search("")
//                        print("Im in here")
//                    } else {
                  
                       self.getObjects()
                   
                        self.searchResultsTableView.reloadData()
                    
                }
            })
            
        } else {
          
            getObjects()
            
        }
        
    }
    func getObjects() {
        favEmployees = []
        favServices = []
        let indice: String! = isFaculty! ? "dev_MC_Employees" : "portal_app_services"
        let index = client.index(withName: indice)
        let type = isFaculty! ? "Faculty" : "Services"
        let predicate = NSPredicate(format: "type = %@", type)
        var favArray = favorites.filter(predicate).first!.idSet.components(separatedBy: ", ")
         print(favArray.count)
        favArray.removeLast()
       
        let ids: [String] = FIRAuth.auth()?.currentUser != nil ? favoritesArray : favArray
        index.getObjects(withIDs: ids , completionHandler: {
            (content, error) -> Void in
            if error == nil {
                print("I should reload")
                print(content!)
                let json = JSON(content!)
                let objectArray: [JSON] = json["results"].arrayValue
                
                   for results in objectArray {
                if self.isFaculty! {
                 
                        let faculty = Faculty(json: results)
                        self.favEmployees.append(faculty)
                    
                } else {
                    let service = Services(json: results)
                    self.favServices.append(service)
 
                }
                }
            }
            if self.searchResultsTableView.numberOfSections > 1 {
                print("I reloaded section")
                 self.searchResultsTableView.reloadData()
//            self.searchResultsTableView.reloadSections(IndexSet(integer: 1), with: .none)
            } else {
                
            }
        })
        
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
