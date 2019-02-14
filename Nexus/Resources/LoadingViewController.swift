//
//  LoadingViewController.swift
//  Nexus
//
//  Created by Clifford Yin on 2/11/19.
//  Copyright © 2019 Clifford Yin. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingViewController: UIViewController {

    var activity = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
    var nextController = "master"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let frame = CGRect(x: self.view.frame.midX - 60, y: self.view.frame.midY - 60, width: 120, height: 120)
        self.activity = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: 22), color: .blue, padding: nil)
        self.view.addSubview(self.activity)
        self.activity.startAnimating()
        
        //* Maybe put a loading animation until it pushes through?
        self.setupTheo()
        
    }
    
    // This is meant to establish an initial connection to database from the start
    func setupTheo() {
        print("setup theo")
        //let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: `\(self.name)`}) RETURN n"
        //MATCH (n:`30496B97-0AAB-4B7E-9423-50F37BC372A9`) RETURN n
        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)`) RETURN n"
        
        print("cypherQuery: \(cypherQuery)")
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        
        APIKeys.shared.theo.executeTransaction(statements, completionBlock: { (response, error) in
            
            if error != nil {
                // what if we try to load again in response to the error
                // TODO: Add warning notifications to errors and segue back to home
                print("setup theo error: \(error)")
                self.setupTheo()
            } else {
                print("setup theo: \(response)")
                print("next: \(self.nextController)")
                DispatchQueue.main.async {
                    if self.nextController == "master" {
                        self.performSegue(withIdentifier: "startUp", sender: nil)
                    } else if self.nextController == "board" {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
