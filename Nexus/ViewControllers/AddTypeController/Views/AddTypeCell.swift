//
//  AddTypeCell.swift
//  Nexus
//
//  Created by Clifford Yin on 1/17/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit

class AddTypeCell: UITableViewCell {
    
    @IBOutlet weak var add: UILabel!
    
    func configure(added: String) {
        print("added: \(added)")
        if added == "Add Picture" {
            self.add.text = added
            self.add.textColor = .clear
            let picButton = UIButton(frame: CGRect(x: self.frame.midX - self.frame.height/2, y: self.frame.midY - self.frame.height/2, width: self.frame.height, height: self.frame.height))
            // Use stencil to overlay color on button image
            let stencil = UIImage(named: "Add Pic")!.withRenderingMode(.alwaysTemplate)
            picButton.setImage(stencil, for: .normal)
            picButton.contentVerticalAlignment = .fill
            picButton.contentHorizontalAlignment = .fill
            picButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            picButton.tintColor = UIColor(rgb: 0x34E5FF)
            picButton.isUserInteractionEnabled = false
            self.addSubview(picButton)
        } else {
            self.add.text = added
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        add.textColor = UIColor(rgb: 0x34E5FF)
        for view in subviews {
            print("asdf: \(Mirror(reflecting: view))")
            if "\(Mirror(reflecting: view))" == "Mirror for UIButton" {
                view.removeFromSuperview()
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
