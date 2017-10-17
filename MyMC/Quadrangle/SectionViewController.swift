//
//  SectionViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/20/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class SectionViewController: UIViewController, UIScrollViewDelegate {
    
    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var articleView: UIScrollView!
    
    
    // Variables
    // MARK: - Variables
    var parentVC: QuadrangleViewController!
    var articleImages: [UIImage?] = []
    var articleArray: [article?] = []
    var imageArray: [UIImageView?] = []
    var screenFrame: CGRect!
    var JSONArray: [JSON] = []
    var currentPage: Int = 0
    var currentArticle: article!
    var totalNumberOfArticles: Int = 0
    var currentJSON: Int = 0
    var pageJSON: Int = 0
    var offset:Int = 0
    var currentIndexForArticles: Int = 0
    var currentSection: Bool!
    static var counters: Int = 0
    let placeholderImageArray:[UIImage] = [UIImage(named: "first")!,
                                           UIImage(named: "second")!,
                                           UIImage(named: "third")!,
                                           UIImage(named: "fourth")!,
                                           UIImage(named: "fifth")!,
                                           UIImage(named: "sixth")!,
                                           UIImage(named: "seventh")!]
    
    
    
    // UIView States
    // MARK: - UIView States
    override func viewDidLoad() {
        super.viewDidLoad()
        //articleView.scrollEnabled = false
        printHeader()
        screenFrame = UIScreen.main.bounds
        view.frame = screenFrame
        view.bounds = screenFrame
     
        SectionViewController.counters = 0
        parentVC = parent as! QuadrangleViewController
        parentVC.sectionScrollView.isScrollEnabled = false
        
        
        self.loadArticles()
    
       // self.configureParentView()
    }
    
    
    // UISCrollView Delegate Functions
    // MARK: - UIScrollView Delegate Functions
    /* Function Directory:
     - scrollViewWillBeginDragging
     
     */
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.tag == 0 {
            
        loadVisiblePages()
            let page = getCurrentPage()
            pageJSON = Int(floor(Float(page/20)))
            if page == totalNumberOfArticles - 10  && pageJSON + 1 == JSONArray.count   {
                print("I loaded more Articles")
                
                for _ in 0..<20 {
                    imageArray.append(nil)
                }
                
                
                self.offset = self.totalNumberOfArticles
               
                self.loadArticles()
            
                let articleSize = UIScreen.main.bounds
                
                self.articleView.contentSize = CGSize(width: articleSize.width, height: articleSize.height * CGFloat(self.totalNumberOfArticles))
                
            } else {
              
            }
            
            if page >= 0 && page < articleArray.count {
                currentArticle = articleArray[page]
                print("scrollWillBegin")
                configureParentView()
            }
            
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("ScrollViewDid")

        if scrollView.tag == 0 {
            
            let page = getCurrentPage()
            if page >= 0 && page < articleArray.count {
                currentArticle = articleArray[page]
                print("ScrollViewDid")
                configureParentView()
            }
        }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
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
        let page = Int(floor(articleView.contentOffset.y / UIScreen.main.bounds.height))
        return page
    }
    
    /**
     Loads subviews(pages) into main view with size and
     position
     
     - parameter page: Curent page number to load
     
     */
    func loadPage(_ page: Int) {
        if page < 0 || page >= totalNumberOfArticles {
            return
        }
        
        if imageArray[page] == nil {
            
            var frame = UIScreen.main.bounds
            frame.origin.y = frame.height * CGFloat(page)
            frame.origin.x = 0.0
            
            let newPageView = UIImageView()
            let article = articleArray[page]
            let imageURLString =  article!.imageURLString
            let urlString = "https://i0.wp.com/\(imageURLString!)?strip=all&quality=100&resize=\(UIScreen.main.bounds.width),\(UIScreen.main.bounds.height)"
            print(urlString)
            let url = URL(string: urlString)
            
            let num = Int(arc4random_uniform(UInt32(placeholderImageArray.count)))
         let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            newPageView.af_setImage(withURL: url!, placeholderImage: placeholderImageArray[num], filter: nil, progress: nil, progressQueue: queue, imageTransition: .crossDissolve(1.5), runImageTransitionIfCached: true, completion: nil)
            
            self.parentVC.shareButton.isEnabled = true
            self.parentVC.websiteButton.isEnabled = true
            newPageView.contentMode = .scaleAspectFill
            newPageView.frame = frame
            
            self.articleView.addSubview(newPageView)
            self.articleView.didAddSubview(newPageView)
            
            self.imageArray[page] = newPageView
            if page > 1 {
//                self.loadVisiblePages()
          
                self.parentVC.sectionScrollView.isScrollEnabled = true
              // self.articleView.scrollEnabled = true
                    
                
            }
            
            
            
         
        }
    }
    
    /**
     Purges pages from main view
     
     - parameter page: Curent page number to purge
     
     */
    func purgePage(_ page: Int) {
        if page < 0 || page >= totalNumberOfArticles  {
            return
        }
        
        if let _ = imageArray[page] {
            imageArray[page] = nil
        }
    }
    
    /**
     Loads and purges pages into view based on range.
     Loads current page, previous page, and following page into view.
     Purges all other pages.
     
     */
    func loadVisiblePages() {
        
        let page = getCurrentPage()
        if page >= 0 {
        let firstPage = page < 2 ? page : page - 2
        let lastPage = page + 2
        
        for index in 0..<firstPage {
            print("snoopy")
            purgePage(index)
        }
        
        for index in firstPage...lastPage {
            loadPage(index)
        }
        print("total \(totalNumberOfArticles)")
            if lastPage + 1 < totalNumberOfArticles {
        for index in lastPage + 1..<totalNumberOfArticles {
            purgePage(index)
            
                }
            }
        }
    }
    
    
    // Article Collection Functions
    /* Function Directory:
     - loadArticles()
     - createArticle()
     - loadArticleArray()
     - loadImages()
     */
    // MARK: - Article Collection Functions
    /**
     Load JSON file for the current section and add them to the `JSONArray`
     */
    func loadArticles(){
        
        var finalURLString: String!
        let vc: String! = title
        let baseURLString: String! = "https://public-api.wordpress.com/rest/v1.1/sites/mcquad.org/posts/?%20fields=posts,author,date,title,content,featured_image,short_URL,excerpt&order=DESC&order_by=date&offset=\(offset)"
        
        switch(vc) {
            
        case "Arts View":
            finalURLString = baseURLString + "&category=arts-entertainment"
        case "OpEd View":
            finalURLString = baseURLString + "&category=opinions-editorials"
        case "News View":
            finalURLString = baseURLString + "&category=News"
        case "Featured View":
            finalURLString = baseURLString + "&category=Features"
        case "Sports View":
            finalURLString = baseURLString + "&category=Sports"
        default:
            finalURLString = baseURLString
        }

        
        Alamofire.request(finalURLString)
            .validate()
            .responseJSON { response in
                let data = response.data!
                let json = JSON(data: data)
                self.JSONArray.append(json)
                self.totalNumberOfArticles += json["posts"].count
                self.loadArticleArray(json["posts"].count)

                let articleSize = self.screenFrame
                
                for _ in 0..<self.totalNumberOfArticles - self.offset {
                    self.imageArray.append(nil)
                }
                
                self.articleView.contentSize = CGSize(width: (articleSize?.width)!, height: (articleSize?.height)! * CGFloat(self.totalNumberOfArticles))
            
                
               
               
                DispatchQueue.main.async() {

                
//               self.currentArticle = self.articleArray[0]
                if SectionViewController.counters < self.parentVC.sectionTabBar.items!.count {
                    SectionViewController.counters += 1
                    
                    // Removes touches on tab bar until the data has been downloaded
                    if SectionViewController.counters == self.parentVC.sectionTabBar.items?.count {
                        for item in self.parentVC.sectionTabBar.items! {
                            
                            item.isEnabled = true
                        }
                        self.articleView.isScrollEnabled = true
//                        self.parentVC.sectionScrollView.scrollEnabled = true
                      
                    }
           
                    
                }
                
                }

                
                self.loadVisiblePages()
                print("loadArticles")
                let vArray = ["Latest View", "News View", "Featured View", "OpEd View", "Arts View", "Sport View"]
                let res = vArray[self.parentVC.getCurrentPage()]
                if  res == vc {
                    self.configureParentView()
                }
        }
    }
    
    /**
     Parses the current JSON file and creates article objects. The article
     objects are then added to the `articleArray`
     
     - parameter page: The index value corresponding to an  article in the JSON File
     
     */
    func createArticle(_ page:Int) {
        
        var Article: article! = article()
        var base = JSONArray[JSONArray.count - 1]["posts"][page]
        Article.vc = self
        let titleString = convertSpecialCharacters(base["title"].stringValue)
        Article.title = titleString
        Article.author = base["author"]["name"].stringValue
        Article.date = dateFormatter(base["date"].stringValue)
        Article.publisherString = "Published on \(Article.date!) by \(Article.author!)"
        Article.summary = base["excerpt"].stringValue
        Article.urlString = base["short_URL"].stringValue
        Article.imageURLString = parseImageURL(base["featured_image"].stringValue)
        Article.content = base["content"].stringValue
        
        articleArray.append(Article)
    }
    
    func loadArticleArray(_ num: Int!){
        
        for i in 0..<num {
            createArticle(i)
        }
    }
    
    func parseImageURL(_ url: String!) -> String! {
        var stringArray: [String] = url.components(separatedBy: "https://")
        return stringArray.count > 1 ? stringArray[1] : ""
    }
    
    /**
     Load images from each article object
     
     */
    func loadImages() {
        var imageURLString: String!
        let value = totalNumberOfArticles - 20
        let imageArray:[UIImage] = [UIImage(named: "first")!,
                                    UIImage(named: "second")!,
                                    UIImage(named: "third")!,
                                    UIImage(named: "fourth")!,
                                    UIImage(named: "fifth")!,
                                    UIImage(named: "sixth")!,
                                    UIImage(named: "seventh")!]
        
        for page in value..<totalNumberOfArticles {
            
            imageURLString = articleArray[page]!.imageURLString
            let num = Int(arc4random_uniform(UInt32(imageArray.count)))
            
            if imageURLString != "" {
                let urlString = "https://i0.wp.com/\(imageURLString)?strip=all&quality=50&resize=\(UIScreen.main.bounds.width),\(UIScreen.main.bounds.height)"
                guard let url = URL(string: urlString) else {
                    articleImages.append(imageArray[num])
                    return
                }
                
                guard let data = try? Data(contentsOf: url) else {
                    articleImages.append(imageArray[num])
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    articleImages.append(imageArray[num])
                    return
                }
                
                articleImages.append(image)
                
            } else {
                articleImages.append(imageArray[num])
            }
            
         
        }
    }
    
    
    // Misc. Functions
    /* Funtion Directory:
     - configureParentView()
     - convertSpecialCharacters(String) -> String
     - dateFormatter(String) -> String
     - printHeader()
     
     */
    // MARK: - Misc. Functions
    func configureParentView() {
        let page = getCurrentPage()
        print(page)
        currentArticle = articleArray[page]
        parentVC.articleTitleLabel.text = currentArticle.title
        parentVC.articlePublishedLabel.text = currentArticle.publisherString
        parentVC.currentArticle = currentArticle
    }
    
    /**
     Convert special characters in strings
     - parameter string: String with special characters
     
     */
    func convertSpecialCharacters(_ string: String) -> String {
        let encodedData = string.data(using: String.Encoding(rawValue: UInt(NSNumber(value: String.Encoding.utf8.rawValue))))!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
            NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue) as AnyObject
        ]
        var attributedString: NSAttributedString!
        do {
            attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch {
            
        }
        let decodedString = attributedString.string
        return decodedString
    }
    
    // TODO: Refactor date function for all classes
    /**
     Converts date string to medium style format, "Nov 23, 1937"
     - parameter dateStringSet: date string of article formatted as "yyyy-MM-dd"
     */
    func dateFormatter(_ dateStringSet: String!) -> String! {
        
        var dateFinalString: String! = String()
        let dateArr =  dateStringSet.components(separatedBy: "T")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let set: String! = dateArr[0]
        if let newDate: Date = dateFormatter.date(from: set!) {
            dateFormatter.dateStyle = .medium
            let dateFinal: String! = dateFormatter.string(from: newDate)
            dateFinalString = dateFinal
        }
        return dateFinalString
    }
    
    func printHeader() {
        print("///////////////////////////////")
        print("//                           //")
        print("//   SectionViewController   //")
        print("//                           //")
        print("///////////////////////////////\n")
    }
    
    
    
}
