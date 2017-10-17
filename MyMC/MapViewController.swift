//
//  MapViewController.swift
//  MyMC
//
//  Created by Michael Fulton Jr. on 8/15/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift
import FirebaseDatabase
import SwiftyJSON

class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var currentHeader: UIView!
    @IBOutlet weak var userLocationLabel: UILabel!
    //let calendars = try! Realm().objects(Calendar)
    var selectedBuilding: Building?
    var selectedPerson: Faculty?
    var selectedEvent: Event?
    var lattitude: Double!
    var longitude: Double!
    var position: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    var didFindMyLocation = false
    
    @IBOutlet weak var mapVisual: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
     
     
      
            let ref = FIRDatabase.database().reference()
        var bldCode: String!
        var markerTitle: String!
        var markerSnippet: String!
        var path: FIRDatabaseQuery!
        var campus:GMSCoordinateBounds!
        ref.child("Buildings").child("Manhattan College").child("BuildingOutline").observeSingleEvent(of: .value, with: {
            snapshot in
            let coordString = snapshot.value as! String
            let campusCoordArray = coordString.components(separatedBy: " ")
            let coordPath = GMSMutablePath()
            for coords in campusCoordArray {
                let long = Double(coords.components(separatedBy: ",")[0])!
                let lat = Double(coords.components(separatedBy: ",")[1])!
                let coord = CLLocationCoordinate2D(latitude:lat , longitude: long)
                coordPath.add(coord)
            }
            campus = GMSCoordinateBounds(path: coordPath)
        })
        if selectedPerson != nil {
            bldCode = (selectedPerson!.officeRoom)!.components(separatedBy: " ")[0]
            path = (ref.child("Buildings").queryOrdered(byChild: "BuildingCode").queryEqual(toValue: bldCode).queryLimited(toFirst: 1))
            markerTitle = self.selectedPerson!.name
            markerSnippet = self.selectedPerson!.officeRoom!
        } else if selectedEvent != nil {
            let arg = (selectedEvent!.eventLocation).components(separatedBy: ", ")
            var building:String!
            switch(arg[0]) {
                case "Student Commons":
                building = "Raymond W Kelly '63 Student Commons"
                case "Lobby of Chapel of De La Salle and His Brothers":
                    building = "Chapel of De La Salle and His Brothers"
            default:
                building = arg[0]
            }
            markerTitle = selectedEvent!.eventTitle
            markerSnippet = selectedEvent!.eventLocation
            
                path = ref.child("Buildings").queryOrderedByKey().queryEqual(toValue: building).queryLimited(toFirst: 1)
            
        } else if selectedBuilding != nil {
            
        }
        
        
            path.observe(FIRDataEventType.value, with: {
                (snapshot) in
                if snapshot.exists() {
                print(snapshot.value as! [String: AnyObject])
                let buildingDict = snapshot.value as! [String: AnyObject]
                let buildingJSON = JSON(buildingDict.first!.1)
                let bldCords = buildingJSON["Coordinates"].stringValue
                let bldOutline = buildingJSON["BuildingOutline"].stringValue
                let coordinateArray = bldOutline.components(separatedBy: " ")
                let coordinates = bldCords.components(separatedBy: ",")
                self.lattitude = Double(coordinates[0])
                self.longitude = Double(coordinates[1])
                self.position = CLLocationCoordinate2DMake(self.lattitude, self.longitude)
                self.navigationItem.title = buildingDict.first!.0
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.Grey.dark, NSFontAttributeName: UIFont(name: "ScalaSansOT-Light", size: 18)!]
                    var update: GMSCameraUpdate!
                    if let userLocation  = (self.view as! GMSMapView).myLocation {
                        if campus.contains(userLocation.coordinate) {
                            let bounds = GMSCoordinateBounds(coordinate: userLocation.coordinate, coordinate: self.position)
                            update = GMSCameraUpdate.fit(bounds)
                        } else {
                            update = GMSCameraUpdate.setTarget(self.position, zoom: 18.0)
                        }
                    } else {
                        update = GMSCameraUpdate.setTarget(self.position, zoom: 18.0)
                    }
                  // self.userLocationLabel.text = buildingDict.first!.0
                   
                    
                    let location = GMSMarker(position: self.position)
                    location.title = markerTitle
                    location.snippet = markerSnippet
                    location.isDraggable = false
                    location.icon = GMSMarker.markerImage(with: Colors.Grey.dark)
                    location.map = self.view as? GMSMapView
                    
                   // let campus = GMSCoordinateBounds(coordinate: , coordinate: )
                  
                    
                    
                    (self.view as! GMSMapView).animate(with: update)
                let outline = GMSMutablePath()
                for coords in coordinateArray {
                    let arr = coords.components(separatedBy: ",")
                    print(Double(arr[0]))
                    let coord = CLLocationCoordinate2D(latitude: Double(arr[1])! , longitude: Double(arr[0])!)
                    outline.add(coord)
                }
                
                let polygon = GMSPolygon(path: outline)
                polygon.fillColor = Colors.Green.light
                polygon.strokeColor = Colors.Green.medium
                polygon.strokeWidth = 2
                polygon.map = self.view as? GMSMapView
                
                } else {
                    let alertController = UIAlertController(title: "Location Not Available", message: "", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                        Void in
                        self.navigationController?.popViewController(animated: true)
                    })
                   
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                  
                    
                }
                   
                
                
            })
            
        

        
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let navBar = navigationController!.navigationBar
        navBar.isTranslucent = false
        navBar.tintColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        navBar.barStyle = .default
        
        navBar.barTintColor = Colors.Grey.light
   
    

    }
    override func loadView() {
           locationManager.delegate = self
          locationManager.requestWhenInUseAuthorization()
        let camera = GMSCameraPosition.camera(withLatitude: 40.889901, longitude: -73.90327, zoom: 17.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        
        mapView.mapType = .normal
        let mapInsets = UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0.0, right:0.0)
        mapView.padding = mapInsets
        
      
    
        mapView.settings.compassButton = true
        mapView.setMinZoom(17.0, maxZoom: 19)

        self.view = mapView
        
    }
    

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            (self.view as? GMSMapView)!.isMyLocationEnabled = true
             (self.view as? GMSMapView)!.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            print("bla")
             //(self.view as? GMSMapView)!.camera = GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 0, viewingAngle: 0)
            
            locationManager.stopUpdatingLocation()
        }
    }
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        locationManager.stopUpdatingLocation()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
