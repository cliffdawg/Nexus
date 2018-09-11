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
    func delete(from: UITextView, cell: Cell)
}

class Cell: UICollectionViewCell, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var deleteBackgroundView: UIVisualEffectView!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    var delegate: SegueDelegate!
    
    var isEditing: Bool = false {
        didSet {
            
            if isEditing {
                deleteButton.alpha =  1.0
                deleteButton.isUserInteractionEnabled = true
                self.textView.alpha = 0.75
                self.layer.borderWidth = 0.0
                self.textView.isUserInteractionEnabled = true
            } else {
                deleteButton.alpha =  0.0
                deleteButton.isUserInteractionEnabled = false
                self.textView.alpha = 1.0
                self.layer.borderWidth = 2.0
                self.textView.isUserInteractionEnabled = false
            }
        }
    }
    
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

    func setUp (editing: Bool) {
        
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.gray.cgColor
        
        if editing {
            deleteButton.alpha = 1.0
            deleteButton.isUserInteractionEnabled = true
            self.textView.alpha = 0.75
            self.layer.borderWidth = 0.0
            self.textView.isUserInteractionEnabled = true
        } else {
            deleteButton.alpha =  0.0
            deleteButton.isUserInteractionEnabled = false
            self.textView.alpha = 1.0
            self.layer.borderWidth = 2.0
            self.textView.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate.delete(from: textView, cell: self)
    }
    
    
    //override func setSelected(_ selected: Bool, animated: Bool)
    //    super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    //}
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let delegated = delegate as! MasterViewController
        delegated.performSegue(withIdentifier: "toEdit", sender: self.textView)
        return false
    }

}
