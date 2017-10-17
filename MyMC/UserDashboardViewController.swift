//
//  UserDashboardViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/20/17.
//  Copyright © 2017 Manhattan College. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import Alamofire
import AlamofireImage
import SwiftyJSON

class UserDashboardViewController: UIViewController, GIDSignInUIDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.masksToBounds = true
            userImageView.layer.cornerRadius = 50
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var jasperCardBalanceLabel: UILabel!
    @IBOutlet weak var diningDollarsLabel: UILabel!
    @IBOutlet weak var jasperDollarsLabel: UILabel!
    @IBOutlet weak var diningDollarsProgressView: UIProgressView!
    @IBOutlet weak var jasperDollarsProgressView: UIProgressView!
    @IBOutlet weak var refreshLabel: UILabel!
    @IBOutlet weak var addJasperFundsButton: UIButton!
    @IBOutlet weak var addToAppleWalletButton: UIButton!
    @IBOutlet weak var barCodeImageView: UIImageView!
    @IBOutlet weak var userDashboardMenu: UITableView!
    @IBOutlet weak var topOfMenu: NSLayoutConstraint!
    @IBOutlet weak var userQuickView: UIView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var balanceMakeupView: UIView!
    @IBOutlet weak var spacingView: UIView!
    @IBOutlet weak var toolBar: UINavigationBar!{
        didSet {
            toolBar.setBackgroundImage(UIImage(), for: .default)
            toolBar.shadowImage = UIImage()
        }
    }
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var sumBar: UIToolbar! {
        didSet {
            sumBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            sumBar.setShadowImage(UIImage(), forToolbarPosition: .any)
            sumBar.isTranslucent = false
        }
    }
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
 
    
    let sections = ["Notifications", "Planner","Summary", "Schedule"]
    
    @IBAction func addJasperFunds(_ sender: UIButton) {
    }
    @IBAction func addToAppleWallet(_ sender: UIButton) {
    }
    @IBAction func refreshBalance(_ sender: UIButton) {
        //check the sign 
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        GIDSignIn.sharedInstance().signOut()
        do {
            try! FIRAuth.auth()!.signOut()
        } catch {
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showJasperCard(_ sender: UIButton) {
   print(userDashboardMenu.frame.origin.y)
        if userDashboardMenu.frame.origin.y != spacingView.frame.origin.y {
        UIView.animate(withDuration: 0.5) {
            self.userDashboardMenu.frame.origin.y = self.spacingView.frame.origin.y
        } }else {
            UIView.animate(withDuration: 0.5) {
               self.userDashboardMenu.frame.origin.y += self.spacingView.frame.height - 22
            }
        }
    }
    
    
    @IBAction func signIn(_ sender: UIButton) {
         GIDSignIn.sharedInstance().signIn()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        GIDSignIn.sharedInstance().uiDelegate = self
        print("current user: \(GIDSignIn.sharedInstance().currentUser)")
        print(GIDSignIn.sharedInstance().hasAuthInKeychain())
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
//            GIDSignIn.sharedInstance().signInSilently()
            summaryView.isHidden = true
        } else {
            summaryView.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getJasperInfo), name: NSNotification.Name(rawValue: "refreshView"), object: nil)

        getJasperInfo()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FIRAuth.auth()?.currentUser != nil {
            return sections.count
        } else {
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userMenuCell", for: indexPath) as! userDashboardMenuTableViewCell
        if sections[indexPath.row] == "Notifications" {
            cell.notificationsView.isHidden = false
        } else {
            cell.notificationsView.isHidden = true
        }
        
        cell.sectionLabel.text = sections[indexPath.row]
        
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshView(loggedin: Bool) {
            loadingIcon.stopAnimating()
            userQuickView.isHidden = !loggedin
            balanceView.isHidden = !loggedin
            balanceMakeupView.isHidden = !loggedin
            refreshLabel.isHidden = !loggedin
            addJasperFundsButton.isHidden = !loggedin
            addToAppleWalletButton.isHidden = !loggedin
            barCodeImageView.isHidden = !loggedin
            userDashboardMenu.isHidden = !loggedin
            summaryView.isHidden = loggedin
        
    }
    
    
    func getJasperInfo(){
        
        if let user = GIDSignIn.sharedInstance().currentUser {
            let token = user.authentication.idToken
            print(token)
            
            
            let urlString = "https://jaspercardws.manhattan.edu/jaspercardtest/user/cardDataGoogle"
            let quoteauth: HTTPHeaders = ["Authorization" : "Bearer " + token!]
            
            Alamofire.request(urlString, headers: quoteauth).responseJSON {
                response in
                print("Im hhhhhhheeeeee")
                print(response.result.value)
                if let jsonData = response.result.value {
                    
                    DispatchQueue.main.async {
                        let json = JSON(jsonData)
                        let card = JasperCard(json: json)
                        print(self.userNameLabel.text)
                        
                        if card.id != nil {
                            self.userNameLabel.text = card.getFullName()
                            self.IDLabel.text = card.id
                            self.jasperCardBalanceLabel.text =  String(format: "%.2f", card.getBalance()!)
                            self.diningDollarsLabel.text = card.diningDollars
                            self.jasperDollarsLabel.text = card.jasperDollars
                            let val = Float(card.diningDollars!)!/card.getBalance()!
                            self.diningDollarsProgressView.setProgress(val, animated: true)
                            self.jasperDollarsProgressView.setProgress(val, animated: true)
                            self.barCodeImageView.image = card.getBarcodeImage()
                            self.refreshLabel.text = card.lastUpdated
                            let imageURL = URL(string: card.getImageURLWithSize(width: 100, height: 100))
                            let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                            self.userImageView.af_setImage(withURL: imageURL!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: queue, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
                            
                            self.refreshView(loggedin: true)
                        }
                    }
                }
            }
        } else {
            refreshView(loggedin: false)
        }

    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "refreshView"), object: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
