//
//  EditNameController.swift
//  Nexus
//
//  Created by Clifford Yin on 6/9/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import UIKit
import Hero

/* For editing the name of an existing board */
class EditNameController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: CenteredTextView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    
    var transition = ""
    
    // MARK: Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "DINAlternate-Bold", size: 20)!], for: .normal)
        
        textView.hero.id = transition
        textView.text = transition
        textView.delegate = self
        textView.layer.borderWidth = 3.0
        textView.layer.borderColor = UIColor(rgb: 0x34E5FF).cgColor
        ItemFrames.shared.updateTextFont(oneTextView: textView, fontSize: 25)
        
        toolBar.clipsToBounds = true
        toolBar.layer.masksToBounds = true
        toolBar.layer.cornerRadius = 25.0
        
    }
    
    override func viewDidLayoutSubviews() {
        textView.textAlignment = .center
        textView.centerVertically()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Return to Master
        if segue.identifier == "backEdit" {
            let destined = segue.destination as! MasterViewController
            destined.newValue = transition
            destined.editObject(sub: textView.text)
            destined.heroModalAnimationType = .pageOut(direction: .right)
        }
    }
 
    // MARK: TextView delegate functions
    
    // Limits characters in board creation to 60
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        ItemFrames.shared.updateTextFont(oneTextView: textView, fontSize: 25)
        let numberOfChars = newText.count
        return numberOfChars < 30
    }
    
}
