//
//  EditNameController.swift
//  Nexus
//
//  Created by Clifford Yin on 6/9/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import UIKit
import Hero

class EditNameController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var transition = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.heroID = transition
        textView.text = transition
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation
    */
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backEdit" {
            let destined = segue.destination as! MasterViewController
            destined.newValue = transition
            destined.editObject(sub: textView.text)
            destined.heroModalAnimationType = .pageOut(direction: .right)
        }
    }
 
}
