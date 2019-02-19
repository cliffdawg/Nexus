//
//  Reachability.swift
//  Nexus
//
//  Created by Clifford Yin on 11/11/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import NotificationBannerSwift
import Alamofire

/* Object to track internet connectivity */
class Reachability: NSObject {
    
    let successBanner = NotificationBanner(title: "Internet Connection Established", subtitle: "You are successfully connected to a secure network.", style: .success)
    let warningBanner = NotificationBanner(title: "Unsecure Network", subtitle: "Please connect to a secure, encrypted network.", style: .warning)
    let dangerBanner = NotificationBanner(title: "Internet Connection Error", subtitle: "Please make sure you are connected to a network.", style: .danger)
    
    static let shared = Reachability()
    let reachabilityManager = NetworkReachabilityManager()
    
    override init() {
        super.init()
        warningBanner.autoDismiss = false
        dangerBanner.autoDismiss = false
        reachabilityManager?.listener = { status in
            if self.reachabilityManager?.isReachable ?? false {
                
                switch status {
                    case .reachable(.ethernetOrWiFi):
                        print("The network is reachable over the WiFi connection")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.checkConnection()
                    case .reachable(.wwan):
                        print("The network is reachable over the WWAN connection")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.checkConnection()
                    case .notReachable:
                        print("The network is not reachable")
                        self.dangerBanner.show()
                    case .unknown :
                        print("It is unknown whether the network is reachable")
                }
                
            } else {
                print ("Network closure not reached")
                self.warningBanner.dismiss()
                self.dangerBanner.show()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.listenForNetwork()
            }
        }
    }
    
}
