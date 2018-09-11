//
//  Connection.swift
//  Nexus
//
//  Created by Clifford Yin on 5/9/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/* A connection between two items */
class Connection {
    
    var origin: String!
    var end: String!
    var connection: String!
    var label: UILabel!
    
    ///// Use these only for pulling data from Neo4j
    var begin: DownloadItem!
    var finish: DownloadItem!
    var beginID: String!
    var finishID: String!
    /////
    
    var initialBegin: CustomImage!
    var initialFinish: CustomImage!
    
    init() {
        
    }
    
    func set(origin: CustomImage!, final: CustomImage!, connect: String!) {
        self.origin = origin.specific
        self.end = final.specific
        self.connection = connect
    }

    
}
