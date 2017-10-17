//
//  feedViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/20/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class feedViewController: UIViewController, UIScrollViewDelegate, UITabBarDelegate {

    
    @IBOutlet weak var nav: UINavigationItem!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var sectionScrollView: UIScrollView!
    @IBOutlet weak var subcategoryToolBar: UIToolbar!
    @IBOutlet weak var sectionTabBar: UITabBar!
    @IBOutlet weak var noPostLabel: UILabel!
    var sectionTitleArray: [String?] = ["Announcements (Everyone)", "News", "Featured Events", "Twitter", "Campus Alerts", "ITS News and Outages"]
    var vcArray: [feedTableViewController?] = []
    var sectionArray: [UIView?] = []
    var didShow: Bool! = false
    var currentVC: feedTableViewController!
    var underline: UIView!

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .default
        UIView.animate(withDuration: 0.5, animations: {
            self.navigationController?.navigationBar.barTintColor = Colors.Grey.light
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.tintColor = Colors.Grey.dark
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.Grey.dark, NSFontAttributeName: UIFont(name: Fonts.scalaSans.light.rawValue, size: 16)!]
                        }, completion: {
                void in
                UIView.animate(withDuration: 0.5, animations: {
                    let page = self.getCurrentPage()
                self.parent!.navigationItem.title = self.sectionTitleArray[page]
                    
                    self.displayButton()
                }) 
        }) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.sectionTabBar.selectedItem = self.sectionTabBar.items![0]
        self.sectionTabBar.tintColor = UIColor(red: 163/255, green: 208/255, blue: 50/255, alpha: 1.0)
        self.sectionTabBar.isTranslucent = true
        self.sectionTabBar.shadowImage = UIImage()
        self.sectionTabBar.backgroundColor = Colors.Grey.light.withAlphaComponent(0.5)
        self.underline = UIView(frame: CGRect(x: (self.sectionScrollView.contentOffset.x/6) + (self.view.frame.size.width/6)/4 ,y: 46
            , width: (self.view.frame.size.width/6)/2, height: 3))
        self.underline.backgroundColor = UIColor(red: 163/255, green: 208/255, blue: 50/255, alpha: 1.0)
      
        self.view.addSubview(underline)
        self.view.bringSubview(toFront: underline)
        
            print("myself \(self.view.frame) \(self.view.bounds)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let titles = ["Announcements View", "News View", "Featured Events View", "Twitter View", "Alerts View", "ITS View"]
        for title in titles {
            let vc = storyboard.instantiateViewController(withIdentifier: "Feed Table View") as! feedTableViewController
            
            vc.title = title
            vcArray.append(vc)
        }

            self.loadingIcon.isHidden = false
            self.loadingIcon.startAnimating()
        
        for vc in vcArray {
            self.addChildViewController(vc!)
            self.sectionArray.append(nil)
        }
      print("view \(self.view.frame)")
        print("scroll view \(self.sectionScrollView.frame)")
            let pageScrollViewSize = sectionScrollView.frame
        self.sectionScrollView.contentSize = CGSize(width: pageScrollViewSize.width * 6.0, height:self.view.frame.height)
        self.loadVisiblePages()
        if sectionTitleArray[self.getCurrentPage()] == "Announcements (Everyone)" {
            UserDefaults.standard.set(0, forKey: "Announcement Type")
        }
        self.automaticallyAdjustsScrollViewInsets = false
 
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let pageWidth = self.view.frame.size.width
        let pageHeight = self.view.frame.size.height
        let currentPage: CGRect = CGRect(x:(CGFloat(item.tag) * pageWidth), y: 0, width: pageWidth, height: pageHeight)
        
        self.sectionScrollView.scrollRectToVisible(currentPage, animated: false)
        self.checkNumOfPosts()
        
        displayButton()
        
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        parent!.navigationItem.title = self.sectionTitleArray[self.getCurrentPage()]
        if scrollView == self.sectionScrollView {
           
            let page = getCurrentPage()
           
            loadVisiblePages()
            self.underline.frame.origin.x = (sectionScrollView.contentOffset.x/6) + CGFloat(((self.view.frame.size.width/6)/4))
            self.sectionTabBar.selectedItem = self.sectionTabBar.items![page]
            let color: UIColor!
            
            switch page {
                
            case 0:
                color = Colors.Green.medium
            case 1:
                color = Colors.Green.light
            case 2:
                color = Colors.purple
            case 3:
                color = Colors.blue
            case 4:
                color = Colors.red
            case 5:
                color = Colors.orange
                
            default:
                color = Colors.Grey.dark
            }
            
            self.sectionTabBar.tintColor = color
            self.underline.backgroundColor = color
            
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.checkNumOfPosts()
        displayButton()
 
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "showTwitterMenu" {
            (segue.destination as! FeaturesFeedViewController).vc = vcArray[3]
        }
     }
    
    
    func getCurrentPage() -> Int {
        let page = Int(floor(self.sectionScrollView.contentOffset.x / self.sectionScrollView.frame.width))
        return page
    }
    
    
    func loadPage(_ page: Int) {
        if page < 0 || page >= 6  {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        print(page)
        if sectionArray[page] != nil {
            // Do nothing. The view is already loaded.
            
        } else {

            var frame = self.view.bounds

            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
           
            frame.size.height = self.sectionScrollView.frame.height
 
            let newPageView = vcArray[page]?.tableView

            newPageView?.contentMode = .scaleToFill
         
            newPageView?.frame = frame
            
            self.sectionScrollView.addSubview(newPageView!)

            self.sectionArray[page] = newPageView
            
        }
    }
    
    func purgePage(_ page: Int) {
        if page < 0 || page >= 6  {
            return
        }
        
        if sectionArray[page] != nil {
            sectionArray[page] = nil
        }
    }
    
    
    func loadVisiblePages() {
        // First, determine which page is currently visible
        let page = getCurrentPage()
        
        // Work out which pages you want to load
        let lastPage = 5
        
        // Purge anything before the first page
        if page != 0 {
            for index in 0 ..< page {
                purgePage(index)
            }
        }
        
        // Load pages in our range
        for index in 0...5{
            loadPage(index)
        }
        
        // Purge anything after the last page
        for index in lastPage ..< 6 {
            purgePage(index)
        }
    }
    
    func checkNumOfPosts(){
        let postNum = self.vcArray[self.getCurrentPage()]
        
        if (postNum?.globalPostArray.count == 0 && postNum?.title != "Featured Events View") || (postNum?.eventPostArray.count == 0 && postNum?.title == "Featured Events View") {
                 self.noPostLabel.isHidden = false
        } else {
                 self.noPostLabel.isHidden = true
        }
    }
    
    func showTwitterMenu() {
        performSegue(withIdentifier: "showTwitterMenu", sender: nil)
    }
    
    func displayButton() {
        
        switch getCurrentPage() {
        case 0:
            let feedButton = UIBarButtonItem()
            feedButton.title = " "
            feedButton.image = UIImage(named: "feedSmall")
            feedButton.action = #selector(vcArray[0]?.switchFeed)
            feedButton.target = vcArray[0]
            parent!.navigationItem.leftBarButtonItem = feedButton
        case 3:
            let feedButton = UIBarButtonItem()
            feedButton.title = " "
            feedButton.image = UIImage(named: "handleSmall")
            feedButton.action = #selector(self.showTwitterMenu)
            feedButton.target = self
            parent!.navigationItem.leftBarButtonItem = feedButton

        default:
            if parent!.navigationItem.leftBarButtonItem != nil {
                parent!.navigationItem.leftBarButtonItem = nil
            }
        }
    }
}
