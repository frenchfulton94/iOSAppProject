//
//  ViewController.swift
//  MyMC
//
//  Created with <3 by MobileSquad on 1/20/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import ReachabilitySwift
import AlamofireImage
import SafariServices

class QuadrangleViewController: UIViewController, UIScrollViewDelegate, UITabBarDelegate {
    
    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articlePublishedLabel: UILabel!
    @IBOutlet weak var sectionScrollView: UIScrollView!
    @IBOutlet weak var websiteButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var sectionTabBar: UITabBar! {
        didSet{
            for item in sectionTabBar.items! {
               
                    item.isEnabled = false 
                
            }
            sectionTabBar.selectedItem = sectionTabBar.items![0]
            sectionTabBar.tintColor = UIColor.white
            sectionTabBar.backgroundImage = UIImage()
            sectionTabBar.shadowImage = UIImage()
            sectionTabBar.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    @IBOutlet weak var gradientView: UIView! {
        didSet {
            gradientView.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var articleToolBar: UIToolbar! {
        didSet {
            articleToolBar.setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
            articleToolBar.setShadowImage(UIImage(), forToolbarPosition: .bottom)
        }
    }
    
    
    // Variables
    // MARK: - Variables
    var didChange: Bool! = true
    var sectionArray: [UIView?] = []
    var VCArray: [UIViewController] = []
    var sectionTitle: [String?] = ["Latest", "News", "Features", "Opinions-Editorials", "Arts & Entertainment", "Sports"]
    var currentArticle: article?
    var currentVC: SectionViewController!
    var underline: UIView!
    var currentPage: Int! = 0
    
    
    // Actions
    // MARK: - Actions
    @IBAction func shareArticle(_ sender: UIBarButtonItem) {
        if currentArticle != nil {
            let string: String! = "Read " + currentArticle!.title + " on WordPress\n"
            let URL: Foundation.URL! = Foundation.URL(string: currentArticle!.urlString)
            let activityViewController = UIActivityViewController(activityItems: [string, URL], applicationActivities: nil)
            navigationController?.present(activityViewController, animated: true,completion: nil)
        }
    }
    @IBAction func presentArticleView(_ sender: UITapGestureRecognizer) {
        let vc = VCArray[getCurrentPage()] as! SectionViewController
        if currentArticle != nil && !vc.articleView.isDragging {
            performSegue(withIdentifier: "presentArticleSegue", sender: nil)
        }
    }
    @IBAction func openInWebsite(_ sender: UIBarButtonItem) {
        let sfs = SFSafariViewController(url: currentArticle!.url as URL, entersReaderIfAvailable: true)
        present(sfs, animated: true, completion: nil)
        
    }
    
    
    // UIView States
    /* Function Directory:
     - viewDidLoad()
     - viewWillAppear()
     - viewWillDissAppear()
     */
    // MARK: - UIView States
    override func viewDidLoad() {
        super.viewDidLoad()
        websiteButton.isEnabled = false
        shareButton.isEnabled = false
        let reachability: Reachability
        do {
            reachability = try Reachability.init()!
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        UniversalLibrary.noConnection(self)
        
        reachability.whenReachable = {
            reachability in
            
                print("View Did Load...")
            DispatchQueue.main.async {
                self.configureView()
                self.currentPage = self.getCurrentPage()
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let Latest: UIViewController = storyBoard.instantiateViewController(withIdentifier: "Latest")
                let NewsVC: UIViewController = storyBoard.instantiateViewController(withIdentifier: "News")
                let FeaturedVC: UIViewController = storyBoard.instantiateViewController(withIdentifier: "Featured")
                let OpEdVC: UIViewController = storyBoard.instantiateViewController(withIdentifier: "OpEd")
                let ArtsVC: UIViewController = storyBoard.instantiateViewController(withIdentifier: "Arts")
                let SportsVC: UIViewController = storyBoard.instantiateViewController(withIdentifier: "Sports")
                
                self.VCArray = [Latest, NewsVC, FeaturedVC, OpEdVC, ArtsVC, SportsVC]
                
                for vc in self.VCArray {
                    self.addChildViewController(vc)
                    self.sectionArray.append(nil)
                }
                for item in 0..<self.articleToolBar.items!.count {
                    if item == 2 {
                        self.articleToolBar.items![item].setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName: UIFont(name: "ScalaSansOT-Light", size: 17)!], for: .normal)
                    }
                }
                let pageScrollViewSize = self.view.frame
                self.sectionScrollView.contentSize = CGSize(width: pageScrollViewSize.width * CGFloat(self.VCArray.count), height:pageScrollViewSize.height)
                print("view \(self.view.frame)")
                print("scrollView \(self.sectionScrollView.frame)")
                print("content \(self.sectionScrollView.contentSize)")
                self.loadVisiblePages()
                self.parent!.navigationItem.title = self.sectionTitle[self.getCurrentPage()]
              
            }
        }
        
        reachability.whenUnreachable = {
            reachability in
            
            DispatchQueue.main.async{
                print("unreachable")
                self.view.viewWithTag(69)!.isHidden = false
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.3, animations: {
        
        let navBar = self.navigationController!.navigationBar
        navBar.barStyle = .blackTranslucent
            
        navBar.barTintColor = UIColor.black.withAlphaComponent(0.5)
        navBar.isTranslucent = true
        navBar.shadowImage = UIImage()
        navBar.tintColor = UIColor.white
        self.navigationController?.hidesBarsOnSwipe = false
        self.parent!.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName: UIFont(name: "ScalaSansOT-Light", size: 17)!]
//        self.view.frame = UIScreen.main.bounds
     self.view.bounds = UIScreen.main.bounds
        self.articleToolBar.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let barbutton = UIBarButtonItem()
            self.sectionTabBar.alpha = 1.0
            self.articleToolBar.alpha = 1.0
            self.gradientView.alpha = 1.0
      
        barbutton.image = UIImage(named: "iTSmall")
        barbutton.title = "About"
        barbutton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "ScalaSansOT-Light", size: 16)!], for: UIControlState())
        
        barbutton.target = self
        barbutton.action = #selector(self.showAbout)
        self.parent!.navigationItem.leftBarButtonItem = barbutton
            
            self.parent!.navigationItem.title = self.sectionTitle[self.getCurrentPage()]
        })

    }
    

    
    // UIScrollView Delegate Functions
    /* Function Directory:
     - scrollViewDidScroll()
     - scrollViewDidEndDecelerating()
     */
    // MARK: - UIScrollView Delegate Functions
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag == 1 {
            currentPage = getCurrentPage()
            parent!.navigationItem.title = sectionTitle[currentPage]
            loadVisiblePages()
            underline.frame.origin.x = (sectionScrollView.contentOffset.x/6) + CGFloat(((view.frame.size.width/6)/4))
            sectionTabBar.selectedItem = sectionTabBar.items![currentPage]
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            currentPage = getCurrentPage()
            (VCArray[currentPage] as! SectionViewController).configureParentView()
        }
    }
    
    
    // UITabBar Delegate Functions
    /* Function Directory:
     - tabBar(didSelectItem)
     */
    // Mark: - UITabBar Delegate Functions
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let pageWidth = view.frame.size.width
        let pageHeight = view.frame.size.height
        currentPage = getCurrentPage()
        let page: CGRect = CGRect(x:(CGFloat(item.tag) * pageWidth), y: 0, width: pageWidth, height: pageHeight)
        
        sectionScrollView.scrollRectToVisible(page, animated: false)
        (VCArray[currentPage] as! SectionViewController).configureParentView()
    }
    
    // Page Scrolling Functions
    // MARK: - Page Scrolling Functions
    // TODO:  Make class for page scrolling. This is used in multiple places
    /* Function Directory:
     - getCurrentPage() -> Int
     - loadPage()
     - purgePage()
     - loadVisibleViews()
     
     */
    /**
     Returns the index of the current page in view
     
    */
    func getCurrentPage() -> Int {
        let page = Int(floor(sectionScrollView.contentOffset.x / UIScreen.main.bounds.width))
        //print("Current Page: \(page)")
        return page
    }
    
    /**
     Loads subviews(pages) intxo main view with size and
     position
     
     - parameter page: Curent page number to load
     
     */
    func loadPage(_ page: Int) {
        
        if page < 0 || page >= VCArray.count  {
            return
        }
        
        if sectionArray[page] == nil {
            var frame = UIScreen.main.bounds
            let newPageView = VCArray[page].view
            newPageView?.contentMode = .scaleToFill
            
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            newPageView?.frame = frame
            
            (VCArray[page] as! SectionViewController).parentVC = self
            
            sectionScrollView.addSubview(newPageView!)
            sectionScrollView.didAddSubview(newPageView!)
            
            sectionArray[page] = newPageView
        }
    }
    
    /**
     Purges pages from main view
     
     - parameter page: Curent page number to purge
     
     */
    func purgePage(_ page: Int) {
        
        if page < 0 || page >= 6  {
            return
        }
        
        if let _ = sectionArray[page] {
            sectionArray[page] = nil
        }
    }
    
    /**
     Loads and purges pages into view based on range.
     Loads current page, previous page, and following page into view.
     Purges all other pages.
     
     */
    func loadVisiblePages() {
       
        let firstPage = 0
        let lastPage = 5
        
        for index in 0 ..< firstPage {
            purgePage(index)
        }
        
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        for index in lastPage ..< 6{
            purgePage(index)
        }
    }
    
    
    // Misc Functions
    /* Function Directory:
        - printHeader()
        - configureView()
        - prepareForSegue()
     */
    // MARK: - Misc Funcitons
    func printHeader() {
        print("/////////////////////////////////")
        print("//                             //")
        print("//   QuadrangleViewController  //")
        print("//                             //")
        print("/////////////////////////////////\n")
    }
    
    func configureView() {
        
        print("Configuring View...")
        self.automaticallyAdjustsScrollViewInsets = false
        self.underline = UIView(frame: CGRect(x: (self.sectionScrollView.contentOffset.x/6) + (self.view.frame.size.width/6)/4 ,y: 110
            , width: (self.view.frame.size.width/6)/2, height: 3))
        self.underline.backgroundColor = UIColor.white
        self.view.addSubview(self.underline)
        self.view.bringSubview(toFront: self.underline)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "presentArticleSegue" {
            
            (segue.destination as! articleViewController).selectedArticle = self.currentArticle
            (segue.destination as! articleViewController).sectionTitle = parent!.navigationItem.title
        } 
    }
    
    func showAbout() {
        print("About")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AboutQuad") as! QuadrangleAboutTableViewController
        parent!.present(vc, animated: true, completion: nil)
    }
    
    
    
}
