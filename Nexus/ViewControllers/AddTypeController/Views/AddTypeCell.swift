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
        self.add.text = added
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
