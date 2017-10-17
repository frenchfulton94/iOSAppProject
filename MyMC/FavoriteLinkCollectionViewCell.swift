//
//  FavoriteLinkCollectionViewCell.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 10/27/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteLinkCollectionViewCell: UICollectionViewCell {
    
    var VC: FavoritesViewController!
    var indexPath: IndexPath!
    let realm = try! Realm()
    var title: String!
    
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var optionView: UIView! {
        didSet {
//            if optionView.isHidden {
//                let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.showOptions))
//                gesture.minimumPressDuration = 0.5
//                addGestureRecognizer(gesture)
//            }
        }
    }
    @IBAction func removeLink(_ sender: UIButton) {
        let predicate = NSPredicate(format: "title = %@", title)
        let service = realm.objects(FavoriteServices.self).filter(predicate).first
        do {
            try realm.write {
                realm.delete(service!)
                VC.favoriteFacultyCollectionView.deleteItems(at: [indexPath])
            }
        } catch {
            
        }

    }
    @IBAction func dismiss(_ sender: UIButton) {
        optionView.isHidden = true
    }
    
    func showOptions(_ sender: UILongPressGestureRecognizer) {
      
        UIView.animate(withDuration: 0.5, animations: {
            self.optionView.isHidden = false
            
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        serviceImageView.image = nil
        optionView.isHidden = true
        VC = nil
        indexPath = nil
        title = nil
        
    }
    
}
