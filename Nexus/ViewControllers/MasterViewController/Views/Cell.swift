//
//  Cell.swift
//  Nexus
//
//  Created by Clifford Yin on 2/5/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import UIKit
import Hero

protocol SegueDelegate {
    func push(from: UITextView)
}

class Cell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    var delegate: SegueDelegate!
    
    var labelName: String? {
        didSet {
            textView.heroID = labelName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let delegated = delegate as! MasterViewController
        delegated.performSegue(withIdentifier: "toEdit", sender: self.textView)
        return false
    }

}
