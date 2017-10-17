//
//  FeedSort.swift
//  MyMC
//
//  Created by Joe  Riess on 5/27/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import XCTest

class FeedSort: XCTestCase {
    
    struct Feed {
        var date: String = ""
        var name: String = ""
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        var feedPost1: Feed = Feed()
        feedPost1.date = "Dec 1, 2016"
        feedPost1.name = "One"
        
        var feedPost2: Feed = Feed()
        feedPost2.date = "Jan 1, 2016"
        feedPost2.name = "Two"
        
        var feedPost3: Feed = Feed()
        feedPost3.date = "May 1, 2016"
        feedPost3.name = "Three"
        
        var feedArr: [Feed] = []
        
        feedArr.append(feedPost1)
        feedArr.append(feedPost2)
        feedArr.append(feedPost3)
        
        //let newFeed = testSort(feedArr)
        let newFeed = iSort(feedArr)
        
        print(newFeed)
        
//        feedArr.sortInPlace({
//            let dateFormatter1 = NSDateFormatter()
//            dateFormatter1.dateFormat = "MMM d, yyyy"
//            let date1 = dateFormatter1.dateFromString($0.date)
//            
//            let dateFormatter2 = NSDateFormatter()
//            dateFormatter2.dateFormat = "MMM d, yyyy"
//            let date2 = dateFormatter2.dateFromString($1.date)
//            
//            let result = date1!.compare(date2!)
//            
//            return result == NSComparisonResult.OrderedAscending
//        })
//        
//        print(feedArr)
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
        }
    }
    
    func testSort(_ feedArr: [Feed]) -> [Feed] {
        let newFeed = feedArr.sorted(by: {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "MMM d, yyyy"
            let date1 = dateFormatter1.date(from: $0.date)
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "MMM d, yyyy"
            let date2 = dateFormatter2.date(from: $1.date)
            
            let result = date1!.compare(date2!)
            
            return result == ComparisonResult.orderedDescending
        })
        
        return newFeed
    }
    
    func iSort(_ postArray: [Feed]) -> [Feed]
    {
        var postArray = postArray
        
        let nObjects = postArray.count
        
        for x in 0..<nObjects
        {
            
            //print("date1 \(date1!)")
            for y in x+1..<nObjects
            {
                
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "MMM d, yyyy"
                let date1 = dateFormatter1.date(from: postArray[x].date)
                
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "MMM d, yyyy"
                let date2 = dateFormatter2.date(from: postArray[y].date)
                // print("date2 \(date2!)")
                
                
                let result = date1!.compare(date2!)
                //let result = (self.globalPostArray[x].postDate.compare(globalPostArray[y].postDate))
                
                if result == ComparisonResult.orderedAscending
                {
                    
                    let tmp = postArray[y]
                    postArray[y] = postArray[x]
                    postArray[x] = tmp
                }
                
            }
        }
        return postArray
    }


    
}
