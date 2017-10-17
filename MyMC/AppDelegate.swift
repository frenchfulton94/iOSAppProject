//
//  AppDelegate.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 1/14/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseAuth
import RealmSwift
import SwiftyJSON
import AEXML
import Alamofire
import GoogleMaps
import GoogleSignIn
import AlgoliaSearch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    lazy var calendars: Results<Calendar> = { self.realm.objects(Calendar.self) }()
    lazy var twitterUsers: FavoriteSet = { self.realm.objects(FavoriteSet.self).filter(NSPredicate(format: "type == %@", argumentArray: ["Twitter"]))[0] }()
    lazy var localTwitter: Results<Twitter> = { self.realm.objects(Twitter.self) }()
    lazy var localFac: FavoriteSet? = { self.realm.objects(FavoriteSet.self).filter(NSPredicate(format: "type == %@", argumentArray: ["Faculty"])).first }()
    lazy var localServ: FavoriteSet? = { self.realm.objects(FavoriteSet.self).filter(NSPredicate(format: "type == %@", argumentArray: ["Services"])).first }()
    lazy var favFaculty: Results<FavoriteFaculty> = { self.realm.objects(FavoriteFaculty.self) }()
    lazy var favServices: Results<FavoriteServices> = { self.realm.objects(FavoriteServices.self) }()
    lazy var tutorialPages: Results<tutSlide> = { self.realm.objects(tutSlide.self) }()



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        let completedTut = defaults.bool(forKey: "completedTutorial")
//        defaults.removeObjectForKey("completedTutorial")
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GMSServices.provideAPIKey("")
        FIRApp.configure()
        
  
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
             GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().hostedDomain = "manhattan.edu"
        if GIDSignIn.sharedInstance().currentUser == nil {
            do {
                try FIRAuth.auth()?.signOut()
            } catch {
                
            }
        }
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        }
        
        if completedTut {
            window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tutVC = storyboard.instantiateViewController(withIdentifier: "uniNav") as! uniNavViewController
            storyboard.instantiateInitialViewController()
            
            window?.rootViewController = tutVC
            window?.makeKeyAndVisible()
        }
        defaults.set(true, forKey: "Calendar State")

  


        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
     
    }
    

    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print(url)
        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
                                            UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication.rawValue] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsKey.annotation.rawValue])
    }
    

    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        let today = formatter.string(from: Date())
        for calendar in calendars {
            let url = calendar.url + "?xcal=1&months=12&startdate=\(today)"
            Alamofire.request(url)
                .validate()
                .response { response in
                    print(self.calendars)
                    if let responseData = response.data {
                        do {
                            let xml = try AEXMLDocument(xml: responseData)
                            let onlineDate = xml.root["channel"]["lastBuildDate"].string
                            if calendar.lastBuildDate != onlineDate {
                                do {
                                    try self.realm.write() {
                                        calendar.xmlData = responseData
                                    }
                                    
                                } catch {
                                    
                                }
                            }
                            print("I'm herer")
                        } catch {
                            
                        }
                    }
                    
            }
            
        }
        
        
    }
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "edu.manhattan.MyMC" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "MyMC", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            // ...
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "toggleUI"), object: nil, userInfo: nil)
            return
        }
        print("Im signing in")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshView"), object: nil, userInfo: nil)
        
        print(user.authentication.idTokenExpirationDate)
        guard let authentication = user.authentication else { return }
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
               print("sign in")
            if let error = error {
                print(error)
                print(error.localizedDescription)
                return
            }
            let userID = user!.uid
            let ref = FIRDatabase.database().reference().child("Users")
            ref.queryEqual(toValue: userID).observeSingleEvent(of: .value, with: {
                snapshot in
                
               
                    print("does not")
                   self.setUpwith(userID: userID)
                
                
            })
            
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("signout")
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshView"), object: nil, userInfo: nil)
        do {
               try FIRAuth.auth()?.signOut()
        } catch {
            
        }
    }
    
   
    func setUpwith(userID: String) {
        let ref = FIRDatabase.database().reference().child(
    "Users")
      
        syncTwitter(userID: userID)
        syncFavorites(userID: userID)
        syncPlanner()
    }
    
    
    func syncFavorites(userID: String) {
        let ref = FIRDatabase.database().reference().child(
            "Users/\(userID)/Favorites")
        ref.observeSingleEvent(of: .value, with: {
            snapshot in
            var facTemp: String = ""
            var servTemp: String = ""
            var facultyArr: [String] = (self.localFac?.idSet.components(separatedBy: ", ") ?? [""])
            print(facultyArr)
            facultyArr.removeLast()
            var servicesArr: [String] = (self.localServ?.idSet.components(separatedBy: ", ") ?? [""])
            servicesArr.removeLast()
            do {
            try self.realm.write {
            self.localServ?.idSet = ""
            self.localFac?.idSet = ""
            }
            } catch {
                
            }
            var localFacultySet: Set<String> = Set(facultyArr.map{ $0 })
            var localServiceSet: Set<String> = Set(servicesArr.map{ $0 })
            var finalFacultySet: Set<String> = []
            var finalServiceSet: Set<String> = []
            if snapshot.exists() {
                print("blubbs")
                print(snapshot.childSnapshot(forPath: "Faculty").value)
                var idArray = (snapshot.childSnapshot(forPath: "Faculty").value as! String).components(separatedBy: ", ")
               
                idArray.removeLast()
                finalFacultySet = Set(idArray.map { $0 })
                var services = (snapshot.childSnapshot(forPath: "Services").value as! String).components(separatedBy: ", ")
                services.removeLast()
                finalServiceSet = Set(services.map { $0 })

            }
            
            
            finalFacultySet.formUnion(localFacultySet)
            finalServiceSet.formUnion(localServiceSet)

            _ = finalFacultySet.map { facTemp.append("\($0), ") }
            _ = finalServiceSet.map { servTemp.append("\($0), ")}
            ref.child("Faculty").setValue(facTemp)
            ref.child("Services").setValue(servTemp)
            
        })
       
    }
    
    func syncPlanner() {
        
    }
    
    func autoFavorites() {
        if let user = GIDSignIn.sharedInstance().currentUser {
            let token = user.authentication.idToken
            var urlString = "https://jaspercardws.manhattan.edu/jaspercardtest/user/"
            let quoteauth: HTTPHeaders = ["Authorization" : "Bearer " + token!]
          
            Alamofire.request(urlString + "termlist_json" , headers: quoteauth).responseJSON {
                response in
                if let jsonData = response.result.value {
                    let json = JSON(jsonData)
                    
                    if !json.isEmpty {
                        
                        if json[0]["current_term"].stringValue == "Y" {
                            let termCode = json[0]["code"].stringValue
                           print("\(urlString)courses_json/\(termCode)")
                            Alamofire.request(urlString + "courses_json/\(termCode)", headers: quoteauth).responseJSON {
                                responseToo in
                                if let data = responseToo.result.value {
                                let jsonToo = JSON(data)
                                print(jsonToo)
                                print("IMMMMM")
                                let courses = jsonToo["courses"]
                                var nameArray: [String] = []
                                let client = Client(appID: "4HZF9PBKRR", apiKey: "cd0c24801408a3a43eb4156de1a24541")
                                let index = client.index(withName: "dev_MC_Employees")
                                    
                                for (_, course) in courses {
                                    let query = Query(query: course["instructor"]["full_name"].stringValue)
                                    query.hitsPerPage = 1
                                    index.search(query, completionHandler: {
                                        (content, error) -> Void in
                                        if error == nil {
                                            let json = JSON(content!)
                                            if let employee = json["hits"].arrayValue.first {
                                                
                                            }
                                        }
                                    })
                                }
                              
                                
                                
                                
                            }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func syncTwitter(userID: String) {
        let ref = FIRDatabase.database().reference().child(
            "Users/\(userID)/Twitter/Handles")
        var final: String = ""
       
        ref.observe(.value, with: {
            snapshot in
            var arr = self.twitterUsers.idSet.components(separatedBy: ",")
            arr.removeLast()
            
            print("FALALALAL")
            let localHandleSet: Set<String> = Set(arr.map { $0 })
            var cloudHandleSet: Set<String> = []
            if snapshot.exists() {
    
                var arr = (snapshot.value as! String).components(separatedBy: ", ")
                arr.removeLast()
             
                    cloudHandleSet = Set(arr.map { $0 })
                try! self.realm.write {
                        self.twitterUsers.idSet = (snapshot.value as! String)
                        self.realm.add(self.twitterUsers, update: true)
                        
                    }
                
                try! self.realm.write {
                    for users in self.localTwitter {
                        if !cloudHandleSet.contains(users.handle){
                            users.subscribed = false
                      
                        } else {
                            users.subscribed = true
                        }
                        self.realm.add(users, update: true)
                    }
                }
         
               
            } else {
            
                localHandleSet.map {final.append("\($0), ") }
                ref.setValue(final)
            }
            
            
                
            
            
            
            
            
        })
    }
    
}

