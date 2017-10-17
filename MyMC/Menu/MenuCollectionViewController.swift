//
//  MenuCollectionViewController.swift
//
//
//  Created by Michael Fulton Jr. on 3/1/16.
//
//

import UIKit
import PassKit

private let reuseIdentifier = "Cell"

class MenuCollectionViewController: UICollectionViewController{
    
    // Variables
    // MARK: - Variables
    var iconArray: [UIImage!] = [UIImage(named:"calendarMenu")!, UIImage(named:"feedMenu")!,

                                 UIImage(named: "quadrangleMenu")!,/* UIImage(named: "settingsMenu")!,*/  UIImage(named: "reportMenu")!, UIImage(named: "download")!]
    var featureTitleArray: [String] = ["Calendar", "Feed", "Quadrangle", /*"Settings",*/ "Feedback", "JasperCard"]
    
    // UIView State Functions
    // MARK: - UIView State Functions
    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    // UICollectionView Data Source Functions
    /* Function Directory
     - numberOfSectionsInCollectionView() -> Int
     - collectionView(numberOfItemsInSection) -> Int
     - collectionView(cellForItemAtInedxPath) -> Int
     */
    // MARK: - UICollectionView Data Source Functions
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if PKPassLibrary.isPassLibraryAvailable() {
            let passLibrary = PKPassLibrary()
            if passLibrary.passes().count == 0 {
                 return iconArray.count
            } else {
                return iconArray.count - 1
            }
           
        } else {
            return iconArray.count - 1
        }
        
        
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("menuCell", forIndexPath: indexPath) as! MenuCollectionViewCell
        
        cell.featuredIcon.setBackgroundImage(iconArray[indexPath.row], forState:.Normal)
        cell.featureLabel.text = featureTitleArray[indexPath.row]
        cell.menuVC = self
        cell.current = featureTitleArray[indexPath.row]
        
        return cell
    }
//    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
//        if identifier == "presentQuadrangle" {
//            return false
//        } else {
//            return true
//        }
//    }
    
}
