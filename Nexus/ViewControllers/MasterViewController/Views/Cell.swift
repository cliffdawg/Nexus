//
//  Cell.swift
//  Nexus
//
//  Created by Clifford Yin on 2/5/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
