//
//  LoadingViewController.swift
//  Nexus
//
//  Created by Clifford Yin on 2/11/19.
//  Copyright © 2019 Clifford Yin. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

/* Buffering view to connect to Neo4j before trying any action */
class LoadingViewController: UIViewController {

    var activity = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
    var nextController = "master"
    var boardController: DetailViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: self.view.frame.midX - 60, y: self.view.frame.midY - 60, width: 120, height: 120)
        self.activity = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: 22), color: .blue, padding: nil)
        self.view.addSubview(self.activity)
        self.activity.startAnimating()
        self.setupTheo()
    }
    
    // Make connection to database, keep trying until handshake established
    func setupTheo() {
        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)`) RETURN n"
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        
        APIKeys.shared.theo.executeTransaction(statements, completionBlock: { (response, error) in
            if error != nil {
                self.setupTheo()
            } else {
                DispatchQueue.main.async {
                    // Depending on which view it came from, segue to master or board
                    if self.nextController == "master" {
                        // If the network is secure, carry out the segue
                        if Reachability.shared.warningBanner.isDisplaying == false {
                            self.performSegue(withIdentifier: "startUp", sender: nil)
                        } else {
                            self.activity.stopAnimating()
                        }
                    } else if self.nextController == "board" {
                        if Reachability.shared.warningBanner.isDisplaying == false {
                            self.dismiss(animated: true, completion: nil)
                            self.boardController.connectTheo()
                        } else {
                            self.activity.stopAnimating()
                        }
                    }
                }
            }
        })
    }

}
