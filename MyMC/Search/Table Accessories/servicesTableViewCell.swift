//
//  servicesTableViewCell.swift
//  MyMC
//
//  Created with <3 by MobileSquad on 4/15/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import AlamofireImage
import RealmSwift
import Firebase
import FirebaseAuth
class servicesTableViewCell: UITableViewCell {
    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var serviceIconView: UIImageView!
    @IBOutlet weak var servicesName: UILabel!
    @IBOutlet weak var servicesInfo: UILabel!
    
    // Varibales
    // MARK: Varibles
    var service: Services!
    var VC: UIViewController!
    var indexPath: IndexPath!
    let realm = try! Realm()
    var favorited: Bool! = false
    
    func updateFavorites() {
          print(FIRAuth.auth()?.currentUser?.email)
        if let user = FIRAuth.auth()?.currentUser{
            let userID = user.uid
            let ref = FIRDatabase.database().reference().child(
                "Users/\(userID)/Favorites/Services")
            
            var finalString: String! = ""
            if self.VC.title == "SEARCH" {
                ref.observeSingleEvent(of: .value, with: {
                    snapshot in
                    
                    if snapshot.exists() {
                        var values = (snapshot.value as! String)
                        var arr = values.components(separatedBy: ", ")
                        arr.removeLast()
                        var arrSet: Set<String> = Set (arr.map{$0})
                    
                        print(arr)
                        if arrSet.contains(self.service.objectID) {
                            arrSet.remove(self.service.objectID)
                            self.favorited = false
                        } else {
                            let temp: Set<String> = [self.service.objectID]
                            arrSet.formUnion(temp)
                            self.favorited = true
                            
                        }
                        print("arr \(arrSet)")
                        print("arr \(arrSet.count)")
                        
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
                if arrSet.contains(service.objectID) {
                    arrSet.remove(service.objectID)
                    self.favorited = false
                  
                } else {
                    let temp: Set<String> = [service.objectID]
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
          
            let predicate = NSPredicate(format: "type = %@", "Services" )
            if let facultySet = self.realm.objects(FavoriteSet.self).filter(predicate).first {
                do {
                    print("idSet \(facultySet.idSet)")
                    var arr = facultySet.idSet.components(separatedBy: ", ")
                    arr.removeLast()
                    var finalString: String! = ""
                       var image: UIImage! = UIImage(named: "favDefault")
                    var arrSet = Set(arr.map {$0})
                      print("IDDDDDD")
                    if arrSet.contains(service.objectID) {
                        arrSet.remove(service.objectID)
                        self.favorited = false
                    } else {
                        let temp: Set<String> = [service.objectID]
                        arrSet.formUnion(temp)
                        self.favorited = true
                        image = UIImage(named: "favorited")
                    }
                  
                    _ = arrSet.map { finalString.append("\($0), ") }
                    
                    
                    try realm.write {
                        facultySet.idSet = finalString
                        realm.add(facultySet, update: true)

                    }
                 
                   
                    var frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    if self.VC.title == "SEARCH" {
                        frame =  CGRect(x: 0, y: 0, width: 50, height: self.frame.height)
                    }
                    let button = UIButton(frame: frame)
                    button.setImage(image, for: UIControlState())
                    button.addTarget(self, action: #selector(self.updateFavorites), for: .touchUpInside)
                    self.accessoryView = button
                    if VC.title == "SEARCH" {
                        (VC as! SearchViewController).searchResultsTableView.reloadRows(at: [indexPath!], with: .none)
                    } else {
                        //(VC as! FavoriteSearchViewController).searchResultsTableView.reloadRows(at: [indexPath!], with: .none)
                        (self.VC as! FavoriteSearchViewController).getObjects()

                    }
                } catch {
                    
                }
                
            }

    }
        

    }
    
    override func prepareForReuse() {
       self.serviceIconView.image = nil
     
    }

}
