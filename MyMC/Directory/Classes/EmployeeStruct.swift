//
//  EmployeeStruct.swift
//  AlgoliaSearchManhattan
//
//  Created by Joe  Riess on 1/20/16.
//  Copyright © 2016 Joe Riess. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Employee {
    let employeeFullName : String
    let employeeEmail : String
    let employeeTitle : String
    
    init (json:JSON) {
        employeeFullName = json["EMPL_FULL_NAME"].stringValue
        employeeEmail = json["EMPL_EMAIL"].stringValue
        employeeTitle = json["EMPL_JOB_DESC_1"].stringValue
    }
}