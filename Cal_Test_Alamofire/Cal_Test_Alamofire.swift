//
//  Cal_Test_Alamofire.swift
//  Cal_Test_Alamofire
//
//  Created by Joe  Riess on 5/27/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import XCTest
import UIKit
import MyMC

class Cal_Test_Alamofire: XCTestCase {
    
    
    var viewController: NewCalendarTableViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewCalendarTableViewController") as! NewCalendarTableViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            self.viewController.viewDidLoad()
        }
    }
    
}
