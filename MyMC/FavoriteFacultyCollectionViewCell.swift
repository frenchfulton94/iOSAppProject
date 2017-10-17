//
//  FavoriteFacultyCollectionViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 10/27/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteFacultyCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    var VC: FavoritesViewController!
    var indexPath: IndexPath!
    @IBOutlet weak var facultyImageView: UIImageView! { didSet {
            facultyImageView.layer.masksToBounds = true
            facultyImageView.layer.cornerRadius = 30.0
        } }
    @IBOutlet weak var optionView: UIView! {
        didSet {
//            if optionView.isHidden {
//            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.showOptions))
//            gesture.minimumPressDuration = 0.2
//            addGestureRecognizer(gesture)
//            }
        }
    }
    @IBOutlet weak var close: UIButton!
    
    @IBOutlet weak var facultyNameLabel: UILabel!
    
    let realm = try! Realm()
    @IBAction func dismiss(_ sender: UIButton) {
            optionView.isHidden = true
    }
    @IBAction func removeFaculty(_ sender: UIButton) {
        let predicate = NSPredicate(format: "name = %@", facultyNameLabel.text!)
        let faculty = realm.objects(FavoriteFaculty.self).filter(predicate).first
        do {
            try realm.write {
                
                realm.delete(faculty!)
                VC.favoriteFacultyCollectionView.deleteItems(at: [indexPath])
                
            }
        } catch {
            
        }
    
    }
    
    func showOptions(_ sender: UILongPressGestureRecognizer) {
          print("i was pressed")
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveLinear , animations: {
            self.optionView.isHidden = false
            
            }, completion: nil)
     
    }
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        facultyImageView.image = nil
//        facultyNameLabel.text = ""
//        optionView.hidden = true
//        indexPath = nil
//        VC = nil
//        
//        
//    }
}
