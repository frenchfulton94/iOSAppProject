//
//  tutorialViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 6/12/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import FirebaseDatabase
import RealmSwift
import SwiftyJSON
import Alamofire
import AlamofireImage


class tutorialViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var pageCounter: UIPageControl!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var topDescriptionLabel: UILabel!
    @IBOutlet weak var bottomDescriptionLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    var vcIndex: Int! = 0
    let realm = try! Realm()
    let tutorialPages = try! Realm().objects(tutSlide.self)
    
    
    @IBAction func nextAction(_ sender: UIButton) {
        
        defaults.set(true, forKey: "completedTutorial")
        let activity = UIAlertController(title: "Still don't get it?", message: "View the full tutorial in the Settings", preferredStyle: .alert)
        let alert = UIAlertAction(title: "Okay, Thanks!", style: .default, handler: {
            void in
            self.performSegue(withIdentifier: "goHome", sender: nil)
        })
            activity.addAction(alert)
        present(activity, animated: true, completion: nil)
     
    }
    @IBOutlet weak var skipButton: UIButton!
    @IBAction func skipTutorial(_ sender: UIButton) {
    }
    @IBOutlet weak var fullTutorialButton: UIButton!
    
    @IBAction func fullTutorial(_ sender: UIButton) {
    }
    @IBOutlet weak var pageControl: UIPageControl!
    var pageController: UIPageViewController!
    let defaults = UserDefaults.standard
  
    
    
    override func viewWillAppear(_ animated: Bool) {
        print(navigationItem.rightBarButtonItem)
        print(navigationController?.navigationItem.rightBarButtonItem)
        navigationItem.rightBarButtonItem = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(tutorialPages)
       //automaticallyAdjustsScrollViewInsets = false
//        fullTutorialButton.hidden = true
        populateTutorial()
        nextButton.isHidden = true
        pageController = storyboard?.instantiateViewController(withIdentifier: "pageViewController") as! UIPageViewController
        
        pageController.dataSource = self
        pageController.delegate = self

        pageController.view.frame = view.frame
        pageController.view.frame.size.height = view.frame.height + 44
        self.addChildViewController(pageController)
        self.view.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
        view.didAddSubview(pageController.view)
        let viewArray:[UIView] = [pageControl, nextButton, skipButton, fullTutorialButton, sectionLabel, bottomDescriptionLabel, topDescriptionLabel]
        for item in viewArray {
            view.bringSubview(toFront: item)
        }
        for view in pageController.view.subviews {
            if view.isKind(of: UIScrollView.self){
            
                (view as! UIScrollView).delegate = self
                  (view as! UIScrollView).isScrollEnabled = false
            }
        }
        
        for view in self.pageController.view.subviews {
            if view.isKind(of: UIPageControl.self) {
                let num = (view as! UIPageControl).currentPage
                self.pageControl.currentPage = num
                
                
                let color = Colors.Grey.dark
                
                
                
                self.pageControl.currentPageIndicatorTintColor = color
                self.pageControl.pageIndicatorTintColor = color.withAlphaComponent(0.5)
                self.nextButton.tintColor = color
                self.skipButton.tintColor = color
                
            }
        }
        if navigationController != nil {
            pageControl.isHidden = true
            
            pageLabel.isHidden = false
            pageLabel.text = "1 of \(tutorialPages.count)"
            pageLabel.textColor = Colors.Grey.dark
            view.bringSubview(toFront: pageLabel)
        }
        fullTutorialButton.isHidden = true
      
        
        if navigationController != nil {
            skipButton.isHidden = true
        }
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
//        pageCounter.pageIndicatorTintColor = Colors.Grey.dark
//        pageCounter.currentPageIndicatorTintColor = Colors.Green.light
//
//        view.bringSubviewToFront(pageCounter)
        
        
       // view.bringSubviewToFront(nextButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageContentViewController).page
      
        if index == 0 || index == NSNotFound {
            return nil
        }
        
      
        index -= 1
       
        
      
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PageContentViewController).page
        
        if index == NSNotFound {
            return nil
        }
      
        index += 1
        var count = 0
        if defaults.bool(forKey: "completedTutorial") {
        count = tutorialPages.count
        } else {
            count = tutorialPages.filter("slideIntro == true").count
        }
        
        if index == count {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(_ index: Int) -> PageContentViewController? {
        var count = 0
   
        var data: String
        if defaults.bool(forKey: "completedTutorial") {
            count = tutorialPages.count
            data = tutorialPages.filter("slideNumber == \(index)").first!.slideImageURL
            print(data)
        } else {
            count = tutorialPages.filter("slideIntro == true").count
            data = tutorialPages.filter("slideIntro == true").sorted(byProperty: "slideNumber", ascending: true)[index].slideImageURL
   
        }
        if index >= count {
            return nil
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PageContentViewController") as! PageContentViewController
  
        
        vc.page = index
        let img = data.replacingOccurrences(of: " ", with: "%20")
   
        let url = "https://mobileimagesmc.imgix.net/\(img)?h=\(UIScreen.main.bounds.height)&w=\(UIScreen.main.bounds.width)"
        print(url)

        vc.url = URL(string: url)
            
        
        return vc
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        for view in pageController.view.subviews {
            
            if view.isKind(of: UIPageControl.self) {
                let num = (view as! UIPageControl).currentPage
                if num != 0 || navigationController != nil {
                    skipButton.isHidden = true

                } else {
                    skipButton.isHidden = false
                }
                var slide: tutSlide
                
                if defaults.bool(forKey: "completedTutorial") {
                    slide = tutorialPages.filter("slideNumber == \(num)").first!

                } else {
                    slide = tutorialPages.filter("slideIntro == true").sorted(byProperty: "slideNumber", ascending: true)[num]

                }
                pageControl.currentPage = num
                let colorString = slide.slideColor
                var color = UIColor.white
                if colorString == "Grey" {
                    color = Colors.Grey.dark
                }
                if num > 1 {
                    pageControl.pageIndicatorTintColor = color.withAlphaComponent(0.5)
                }
                pageControl.currentPageIndicatorTintColor = color
                nextButton.tintColor = color
      
                   topDescriptionLabel.isHidden = true
                 bottomDescriptionLabel.isHidden = true
                 sectionLabel.isHidden = true
               
                    if let description = slide.slideDescription {
                         if slide.slideDescPosition == "Top" {
                    topDescriptionLabel.text = description
                            topDescriptionLabel.textColor = color
                            topDescriptionLabel.isHidden = false
                         } else {
                            bottomDescriptionLabel.text = description
                            bottomDescriptionLabel.textColor = color
                            bottomDescriptionLabel.isHidden = false
                        }
                }
                
                
                if let section = slide.slideSection {
                    sectionLabel.text = section.uppercased()
                    sectionLabel.textColor = color
                    sectionLabel.isHidden = false
                }
              
                if num != (view as! UIPageControl).numberOfPages - 1 {
//                    fullTutorialButton.hidden = true
                    nextButton.isHidden = true
                } else {
//                    fullTutorialButton.hidden = false
                     nextButton.isHidden = false
                    nextButton.tintColor = color
//                    fullTutorialButton.tintColor = color
                }
                if navigationController != nil {
                    pageLabel.text = "\(num + 1) of \(pageControl.numberOfPages)"
                    pageLabel.textColor = color
                    nextButton.isHidden = true
                    if !color.isEqual(Colors.Grey.dark){
                        navigationController?.navigationBar.tintColor = UIColor.white
                        navigationController?.navigationBar.barStyle = .black
                    } else {
                        navigationController?.navigationBar.tintColor = Colors.Grey.dark
                         navigationController?.navigationBar.barStyle = .default
                    }
                    
                    if num < (view as! UIPageControl).numberOfPages - 1  {
                        
                    }
                }
                
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
   
      
   
        
    }
    
    func populateTutorial() {
        
        var counter = 0
        let ref = FIRDatabase.database().reference().child("Tutorial")
        ref.observeSingleEvent(of: .value, with: {
            snapshot in

          
            
            var tempDict = snapshot.value as! [AnyObject]
            
            tempDict.removeFirst()
              
                    var i = 0
                    for json in tempDict {
                        let newJson = JSON(json)
                        let imageURL = newJson["ImageURL"].stringValue
                        let description = newJson["Description"].stringValue
                        let section = newJson["Section"].stringValue
                        let intro = newJson["Intro"].stringValue
                        let color = newJson["Color"].stringValue
                        let position = newJson["Position"].stringValue
                        let slide = tutSlide()
                        if self.tutorialPages.count <= i {
                            
                        print("(slideNumber: \(i) description: \(description)")
                        slide.slideNumber = i 
                        if description != "N/A" {
                        slide.slideDescription = description
                        }
                        if position != "N/A" {
                            slide.slideDescPosition = position
                        }
                        if section != "N/A" {
                        slide.slideSection = section
                        }
                        
                        
                            slide.slideColor = color
                            
                        
                        
                        if intro == "Y" {
                            slide.slideIntro = true
                        }
                        
                        slide.slideImageURL =  imageURL
                        
                      
                            do {
                            try self.realm.write {
                            
                            self.realm.add(slide)
                            }
                            } catch {
                                
                            }
                            counter += 1
                            if self.view != nil {
                            if counter == tempDict.count {
                                for view in self.pageController.view.subviews {
                                    if view.isKind(of: UIScrollView.self){
                                        
                                        
                                        (view as! UIScrollView).isScrollEnabled = true
                                    }
                                }
                                let start = self.viewControllerAtIndex(0)
                                self.pageController.setViewControllers([start!], direction: .forward, animated: true, completion: {
                                    void in
                                    var count = 0
                                    if self.defaults.bool(forKey: "completedTutorial") {
                                        count = self.tutorialPages.count
                                        
                                    } else {
                                        count = self.tutorialPages.filter("slideIntro == true").count
                                    }
                                      self.pageControl.numberOfPages = count
                                    
                                  

                                    
                                  
                                    
                                })
                            }
                            }
                       
                        
                        
                        
                        } else {
                            let slide = self.tutorialPages.filter("slideNumber == \(i)").first
                            do {
                                print(i)
                                print(slide!.slideImageURL)
                                print(imageURL)
                                try self.realm.write {
                            if slide!.slideImageURL != imageURL {
                                slide!.slideImageURL = imageURL
                                print("I was here")

                            }
                                    
                                    if slide!.slideDescription != description {
                                          if description != "N/A" {
                        slide!.slideDescription = description
                        }
                                    }
                                    
                                    if slide!.slideSection != section {
                                        if section != "N/A" {
                                            slide!.slideSection = section
                                        }
                                    }
                                
                                        if intro == "Y" {
                                            slide!.slideIntro = true
                                    }
                                
                                    if slide!.slideColor != color {
                                        slide!.slideColor = color
                                        
                                    } else {
                                        
                                    }
                                    
                                    if slide!.slideDescPosition != position {
                                        slide!.slideDescPosition = position
                                    }

                                }
                            } catch {
                                
                            }
                               if self.view != nil {
                            if i == tempDict.count - 1 {
                                for view in self.pageController.view.subviews {
                                    if view.isKind(of: UIScrollView.self){
                                        
                                        
                                        (view as! UIScrollView).isScrollEnabled = true
                                    }
                                }
                                let start = self.viewControllerAtIndex(0)
                                self.pageController.setViewControllers([start!], direction: .forward, animated: true, completion: {
                                    void in
                                    
                                    var count = 0
                                    if self.defaults.bool(forKey: "completedTutorial") {
                                        count = self.tutorialPages.count
                                    } else {
                                        count = self.tutorialPages.filter("slideIntro == true").count
                                    }
                                    self.pageControl.numberOfPages = count
                                   
                                    
                                    
                                    
                                })
                            }
                            }
                            
                        }
                        
                      i += 1
                        
                        
                    }
                    
                
                
            
        })
    }
    
    func checkIf(_ imageOne: UIImage, isEqualto imageTwo: UIImage) -> Bool {
        let dataOne = UIImagePNGRepresentation(imageOne)
        let dataTwo = UIImagePNGRepresentation(imageTwo)
        
        return (dataOne! == dataTwo!)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        var count = 0
        if defaults.bool(forKey: "completedTutorial") {
            count = tutorialPages.count
            
        } else {
            count = tutorialPages.filter("slideIntro == true").count
        }
            return count
        
        
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return 0
    }

    
    
    
}
