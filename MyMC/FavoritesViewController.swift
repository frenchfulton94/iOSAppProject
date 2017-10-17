//
//  FavoritesViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 10/27/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices
import AlamofireImage
import AlgoliaSearch
import Firebase
import SwiftyJSON
import FirebaseAuth


class FavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var favoriteFacultyCollectionView: UICollectionView!
    @IBOutlet weak var favoriteLinksCollectionView: UICollectionView!

    @IBOutlet weak var removeFacultyButton: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var removeLinkButton: UIButton!
    var empRem: Bool! = false
    var servRem: Bool! = false
    var favoriteFacultyArray: [FavoriteFaculty] = []
    var favoriteServicesArray: [FavoriteServices] = []
    
    let realm = try! Realm()
    let client = Client(appID: "4HZF9PBKRR", apiKey: "cd0c24801408a3a43eb4156de1a24541")
    lazy var favorites: Results<FavoriteSet> = { self.realm.objects(FavoriteSet.self) }()
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func removeEmployees(_ sender: UIButton) {
        let predicate =
        favoriteFacultyCollectionView.reloadData()
        let title = removeFacultyButton.titleLabel?.text
        let cond = title == "remove"
        let check = cond ? false : true
        removeLinkButton.isEnabled = check
        favoriteLinksCollectionView.isUserInteractionEnabled = check
        removeLinkButton.isEnabled = false
        let newTitle = cond ?  "cancel" : "remove"
        removeFacultyButton.setTitle(newTitle, for: .normal)
        empRem = cond ? true : false
    
        favoriteFacultyCollectionView.reloadData()
        
    }
    @IBAction func removeLinks(_ sender: UIButton) {
        favoriteLinksCollectionView.reloadData()
        
       let title = removeFacultyButton.titleLabel?.text
        let cond = title == "remove"
        let check = cond ? false : true
        removeFacultyButton.isEnabled = check
        favoriteFacultyCollectionView.isUserInteractionEnabled = check
        let newTitle = cond ? "cancel" : "remove"
        removeLinkButton.setTitle(newTitle, for: .normal)
        empRem = cond ? true : false
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let navBar = navigationController!.navigationBar
        navBar.barStyle = .default
        navBar.isTranslucent = false
        navBar.shadowImage = UIImage()
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.tintColor = Colors.Grey.dark
        navBar.barTintColor = Colors.Grey.light
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "TradeGothicLTStd-BdCn20", size: 17)!, NSForegroundColorAttributeName: Colors.Grey.dark ]
        navigationItem.title = "FAVORITES"
        print("view will appear")
           setUpObjects()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteFacultyCollectionView.layer.shadowOpacity = 0.5
        favoriteFacultyCollectionView.layer.shadowOffset = CGSize(width: 0, height: 4)
        favoriteFacultyCollectionView.layer.shadowRadius = 5
        favoriteFacultyCollectionView.layer.shadowColor = UIColor.black.cgColor
     
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
           return collectionView.tag == 0 ? favoriteFacultyArray.count + 1 :  favoriteServicesArray.count + 1

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        if collectionView.tag == 0 {
            
            if indexPath.row <= (favoriteFacultyArray.count - 1) {
                
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favFaculty", for: indexPath) as! FavoriteFacultyCollectionViewCell
              
            let faculty = favoriteFacultyArray[indexPath.row]
            cell.facultyNameLabel.text = faculty.name
            let newString = faculty.imageURL?.replacingOccurrences(of: "http", with: "https")
            cell.VC = self
            cell.indexPath = indexPath
            let url = URL(string: newString!)
                cell.facultyImageView.af_setImage(withURL: url!, placeholderImage: UIImage(named: "profileDefaultImage") , filter: nil, progress: nil, progressQueue: queue, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: nil)
                let title = removeFacultyButton.titleLabel?.text
                let check = title == "remove" ? true : false
                cell.optionView.isHidden = check
                cell.close.isHidden = check

            return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddFaculty", for: indexPath) as! addFacultyCollectionViewCell
                
                return cell
            }
        } else {
            if indexPath.row <= (favoriteServicesArray.count - 1) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favLinks", for: indexPath) as! FavoriteLinkCollectionViewCell
            let service = favoriteServicesArray[indexPath.row]
                print("\(service.title) : \(service.url)")
            let link = service.imageURL
            cell.VC = self
            cell.indexPath = indexPath
            cell.title = service.title
            let url = URL(string: link!)
            print("urlll \(favoriteServicesArray)")
            cell.serviceImageView.af_setImage(withURL: url!, placeholderImage: UIImage(named: "manhattanDefaultImage"), filter: nil, progress: nil, progressQueue: queue, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: nil)
            
                let title = removeLinkButton.titleLabel?.text
                let check = title == "remove" ? true : false
                cell.optionView.isHidden = check
                cell.close.isHidden = check
            return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddLinks", for: indexPath) as! addLinkCollectionViewCell
                
                return cell
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 0 {
            if indexPath.row <= (favoriteFacultyArray.count - 1) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favFaculty", for: indexPath) as! FavoriteFacultyCollectionViewCell
                if removeFacultyButton.titleLabel?.text == "remove" {
            performSegue(withIdentifier: "showProfile", sender: indexPath.row)
                } else {
                    cell.removeFaculty(cell.close)
                }
            } else {
                performSegue(withIdentifier: "searchFavorites", sender: true)
            }
        } else {
            
             if indexPath.row <= (favoriteServicesArray.count - 1) {
                let alert = {
                    
                    let alertController = UIAlertController(title: "Link Not Availble", message: "", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                guard let urlS = favoriteServicesArray[indexPath.row].url else {
                    
                    alert()
                    return
                }
                
                if urlS != "" {
                    guard let url = URL(string: urlS) else {
                        alert()
                        return
                    }
                    
                    let svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favLinks", for: indexPath) as! FavoriteLinkCollectionViewCell
                    if removeLinkButton.titleLabel?.text == "remove"  {
                        present(svc, animated: true, completion: nil)
                        favoriteServicesArray = []
                        favoriteFacultyArray = []
                    } else {
                        cell.removeLink(cell.close)
                    }

                    
                }
         
                             } else {
                
                    performSegue(withIdentifier: "searchFavorites", sender: false)
            }
            
        }
        
    }
    
      override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
       
        if segue.identifier == "showProfile" {
         
            (segue.destination.childViewControllers[0] as! DirectoryProfileViewController).person =
                favoriteFacultyArray[sender as! Int].profile
            (segue.destination.childViewControllers[0] as! DirectoryProfileViewController).parentVC = self
            
        } else if segue.identifier == "searchFavorites" {
            (segue.destination as! FavoriteSearchViewController).isFaculty = sender as! Bool
            (segue.destination as! FavoriteSearchViewController).VC = self
        }
        favoriteServicesArray = []
        favoriteFacultyArray = []
    }
    
    
    func setUpObjects() {

        var falcArr: [String] = []
        var servArr: [String] = []
       
       
        if FIRAuth.auth()?.currentUser == nil {
            let facPred = NSPredicate(format: "type = %@", "Faculty")
            let servPred = NSPredicate(format: "type = %@", "Services")
            let facultySet = favorites.filter(facPred).first!.idSet
            let servicesSet = favorites.filter(servPred).first!.idSet
            falcArr = (facultySet?.components(separatedBy: ", ") ?? [""])
            falcArr.removeLast()
            servArr = (servicesSet?.components(separatedBy: ", ") ?? [""])
            servArr.removeLast()
          
            getObjects(ids: falcArr, type: "Faculty", index: "dev_MC_Employees")
            getObjects(ids: servArr, type: "Services", index: "portal_app_services")
            
            
        } else {
            let userID = FIRAuth.auth()!.currentUser!.uid
            print(userID)
            let ref =  FIRDatabase.database().reference().child("Users/\(userID)/Favorites")
            print("Im here")
            ref.observeSingleEvent(of: .value, with: {
                snapshot in
                print("Im here as always")
                if snapshot.exists() {
                    
               
                  
                    falcArr = (snapshot.childSnapshot(forPath: "Faculty").value as! String).components(separatedBy: ", ")
                    print(falcArr.count)
                    falcArr.removeLast()
                    servArr = (snapshot.childSnapshot(forPath: "Services").value as! String).components(separatedBy: ", ")
                    print(falcArr)
                    servArr.removeLast()
                    
                    self.getObjects(ids: falcArr, type: "Faculty", index: "dev_MC_Employees")
                    self.getObjects(ids: servArr, type: "Services", index: "portal_app_services")
                    
                    
                }
                
                
            })
            
            
        }
    }
    
    
    func getObjects(ids: [String], type: String, index: String ) {
        let index = client.index(withName: index)

        index.getObjects(withIDs: ids, completionHandler: {
            (content, error) -> Void in
            if error == nil {
                print("I should reload")
                let json = JSON(content!)
                let objectArray: [JSON] = json["results"].arrayValue
                switch type {
                case "Faculty":
                for results in objectArray {
                    let faculty = FavoriteFaculty(json: results)
                    self.favoriteFacultyArray.append(faculty)
                }
                self.favoriteFacultyCollectionView.reloadData()
                
                case "Services":
                for results in objectArray {
                    let service = FavoriteServices(json: results)
                    self.favoriteServicesArray.append(service)
                    
                }
                self.favoriteLinksCollectionView.reloadData()
                
                default:
                return
                }
            }
            
        })
      
    }
   

}
