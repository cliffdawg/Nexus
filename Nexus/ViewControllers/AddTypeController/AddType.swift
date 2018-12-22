//
//  AddType.swift
//  Nexus
//
//  Created by Clifford Yin on 1/17/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit

protocol ChooseAddDelegate {
    func chooseAdd(chosenAdd: String)
}

/* Consists of all the types of items that can be added to a Nexus board */
class AddType: UITableViewController {
    
    let adds = ["Add Picture", "Add Note", "Create Connection", "Re-position Element", "Edit Element", "Delete Element"]
    var delegate2: ChooseAddDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        view.superview?.layer.masksToBounds = true
        view.superview?.layer.cornerRadius = 5.0
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adding", for: indexPath) as? AddTypeCell
        cell?.configure(added: adds[indexPath.row])
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath) as? AddTypeCell
        let cellText: String = (cell?.add.text)!
        delegate2.chooseAdd(chosenAdd: cellText)
        dismiss(animated: true, completion: nil)

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50.0
    }
}

