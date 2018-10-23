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
    // Raw data templates from downloading
    var begin: DownloadItem!
    var finish: DownloadItem!
    // ID's from downloaded data
    var beginID: String!
    var finishID: String!
    // The actual objects created from downloaded data
    var downloadBegin: CustomImage!
    var downloadFinish: CustomImage!
    /////
    
    // These are only for locally created objects which haven't been uploaded yet
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
