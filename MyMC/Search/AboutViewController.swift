//
//  AboutViewController.swift
//  MyMC
//
//  Created by Joe  Riess on 6/2/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import FirebaseDatabase
class AboutViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var versionLabel: UILabel! {
        didSet {
            // Setting the bundle version
            if let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                versionLabel.text = "Version \(versionString)"
            }
        }
    }
    
    var postArray: [String]!
    override func viewWillAppear(_ animated: Bool) {
       navigationItem.rightBarButtonItem = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Font settings
        let paragraphFont = UIFont(name: "MinionPro-Regular", size: 15.0) ?? UIFont.systemFont(ofSize: 15.0)
        let boldFont = UIFont(name: "MinionPro-Bold", size: 23.0) ?? UIFont.systemFont(ofSize: 23.0)
        let para = NSMutableAttributedString()
        
        let credits = postArray[1].replacingOccurrences(of: "\\n", with: "\n")
        // Add Text
        let aboutTitle = NSAttributedString(string: "About\n", attributes: [NSFontAttributeName: boldFont, NSForegroundColorAttributeName: UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)])
        let aboutSection = NSAttributedString(string: postArray[0] + "\n", attributes: [NSFontAttributeName: paragraphFont, NSForegroundColorAttributeName: UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)])
        let creditsTitle = NSAttributedString(string: "Credits\n", attributes: [NSFontAttributeName: boldFont, NSForegroundColorAttributeName: UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)])
        let creditsSection = NSAttributedString(string: credits, attributes: [NSFontAttributeName: paragraphFont, NSForegroundColorAttributeName: UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)])
        
        // Appending information to the attributed string
        para.append(aboutTitle)
        para.append(aboutSection)
        para.append(creditsTitle)
        para.append(creditsSection)
        
        // Define paragraph styling
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacingBefore = 10.0
        
        // Apply paragraph styles to paragraph
        para.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0,length: para.length))
        
        // Add string to UITextView
        textView.attributedText = para
       textView.scrollRangeToVisible(NSMakeRange(0, 0))
    }

}
