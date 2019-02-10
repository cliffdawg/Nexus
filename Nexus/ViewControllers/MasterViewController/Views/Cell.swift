//
//  Cell.swift
//  Nexus
//
//  Created by Clifford Yin on 2/5/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import UIKit
import Hero
import ChameleonFramework

protocol SegueDelegate {
    func delete(from: UITextView, cell: Cell)
}

class Cell: UICollectionViewCell, UITextViewDelegate {
    
    @IBOutlet weak var textView: CenteredTextView!
    @IBOutlet weak var deleteBackgroundView: UIVisualEffectView!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    var delegate: SegueDelegate!
    
    var isEditing: Bool = false {
        didSet {
            
            if isEditing {
                deleteButton.alpha =  1.0
                deleteButton.isUserInteractionEnabled = true
                self.textView.alpha = 0.75
                
                // Use Chameleon to give some haptic texture
                let colors:[UIColor] = [
                    UIColor(rgb: 0xA533FF),
                    .purple
                ]
                self.textView.backgroundColor = GradientColor(gradientStyle: .radial, frame: self.textView.frame, colors: colors)
                
                self.layer.borderColor = UIColor(rgb: 0x34E5FF).cgColor
                self.textView.isUserInteractionEnabled = true
            } else {
                deleteButton.alpha =  0.0
                deleteButton.isUserInteractionEnabled = false
                self.textView.alpha = 1.0
                self.textView.backgroundColor = UIColor(rgb: 0xA533FF)
                self.layer.borderWidth = 2.0
                self.layer.borderColor = UIColor.white.cgColor
                self.textView.isUserInteractionEnabled = false
            }
        }
    }
    
    // Hero component for the cell
    var labelName: String? {
        didSet {
            textView.hero.id = labelName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textView.delegate = self
        self.textView.clipsToBounds = true
        let stencil = UIImage(named: "X")!.withRenderingMode(.alwaysTemplate)
        deleteButton.setImage(stencil, for: .normal)
        deleteButton.tintColor = .red
    }

    // Placing the centering function in layout makes it work
    override func layoutSubviews() {
        self.textView.centerVertically()
    }
    
    // Sets up blur view
    func setUp (editing: Bool) {
        
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.white.cgColor
        
        // Snap the blur view to the front or back depending on editing status
        if editing {
            deleteButton.alpha = 1.0
            deleteButton.isUserInteractionEnabled = true
            self.textView.alpha = 0.75
            
            self.layer.borderColor = UIColor(rgb: 0x34E5FF).cgColor
            self.textView.isUserInteractionEnabled = true
        } else {
            deleteButton.alpha = 0.0
            deleteButton.isUserInteractionEnabled = false
            self.textView.alpha = 1.0
            self.textView.backgroundColor = UIColor(rgb: 0xA533FF)
            self.layer.borderWidth = 2.0
            self.layer.borderColor = UIColor.white.cgColor
            self.textView.isUserInteractionEnabled = false
            print("alpha: \(self.layer.borderColor?.alpha)")
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
