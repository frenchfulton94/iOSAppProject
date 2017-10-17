//
//  articleViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/27/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit

class articleViewController: UIViewController, UIScrollViewDelegate {
    
    // Outlets
    // MARK: - Outlets
    @IBOutlet weak var articleTitleLabel: UILabel! {
        didSet {
            articleTitleLabel.text = selectedArticle.title
        }
    }
    @IBOutlet weak var articlePublisherLabel: UILabel! {
        didSet {
            articlePublisherLabel.text = selectedArticle.publisherString
        }
    }
    @IBOutlet weak var articleToolBar: UIToolbar! {
        didSet {
            articleToolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            articleToolBar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        }
    }
    @IBOutlet weak var articleHeaderView: UIView!
    @IBOutlet weak var articleContentView: UIWebView! {
        didSet{
            articleContentView.scrollView.delegate = self
        }
    }
    @IBOutlet weak var mcLogoView: UIImageView!
    @IBOutlet weak var openLinkButton: UIButton!
    
    
    // Variables
    // MARK: - Variables
    var selectedArticle: article!
    var sectionTitle: String!
    
    
    // Actions
    // MARK: - Actions
    @IBAction func shareArticle(_ sender: UIBarButtonItem) {
        
        let string: String! = "Read " + selectedArticle.title + " from The Quadrangle on WordPress\n"
        let URL: Foundation.URL! = Foundation.URL(string: selectedArticle.urlString)
        
        let activityViewController = UIActivityViewController(activityItems: [string, URL], applicationActivities: nil)
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func openArticle(_ sender: UIButton) {
        UIApplication.shared.openURL(selectedArticle.url)
    }
    
    
    // UIView States Functions
    /* Function Directory:
        - viewDidLoad()
        - viewWillAppear()
        - viewDidAppear()
    */
    // MARK: - UIView States Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
        let navBar = self.navigationController!.navigationBar
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.barTintColor = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
            navBar.backgroundColor = Colors.Grey.dark
        navBar.isTranslucent = false
        navBar.shadowImage = UIImage()
        navBar.barStyle = .black
        navBar.tintColor = UIColor.white
        let backButton = UIBarButtonItem(title: "\(self.sectionTitle)", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "ScalaSansOT-Light", size: 14)!], for: UIControlState())
    print("I can do this all day/night")
            self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.backBarButtonItem = backButton
               // self.navigationItem.setHidesBackButton(false, animated: true)
        }) 
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //navigationController?.hidesBarsOnSwipe = hasJavaScript() ? false : true
    }
    
    // Misc Functions
    /* Function Directory
        - ConfigureView()
        - hasJavascript() -> Bool
    */
    // MARK: - Misc Functions
    func configureView(){
        
        let viewWidth = UIScreen.main.bounds.width - 40
        
        if hasJavaScript() {
            mcLogoView.isHidden = false
            openLinkButton.isHidden = false
            articleContentView.scrollView.isScrollEnabled = false
        } else {
            let contentDesignString = "<head><style> body{ width: \(viewWidth) !important; background-color:#F2F2F2; color: #666666; font-family: MinionPro-Regular; margin:0; padding:30 20 40 20 !important;} a img, img { width:\(viewWidth + 40) !important; height: auto !important; pointer-events: none; margin: 15px -20px !important;  padding: 0;} div, iframe {width: \(viewWidth) !important; margin:0; padding: 0; height:auto; }p {text-align: left; padding: 0; margin: 0; text-indent: 2em;} h1,h2,h3, h4, h5, h6 { margin: 8; text-align: center; } p.wp-caption-text { font-size:small; color: rgb(142, 142, 147); padding:20; text-align: center; padding-top:10; } blockquote {font-family:MinionPro-CnItCapt;} p + p { margin-bottom: 5px;} p b { text-indent: 0; } </style></head><body>" + selectedArticle.content + " </body>"
            selectedArticle.content = contentDesignString
            articleContentView.loadHTMLString(selectedArticle.content, baseURL: nil)
        }
    }
    
    func hasJavaScript() -> Bool {
        return selectedArticle.title.contains("Photo Gallery") ? true : false
    }
}
