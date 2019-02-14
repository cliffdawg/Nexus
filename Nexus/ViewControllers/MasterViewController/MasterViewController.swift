//
//  MasterViewController.swift
//  Nexus
//
//  Created by Clifford Yin on 1/11/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import UIKit
import CoreData
import TextFieldEffects
import ViewAnimator
import IQKeyboardManagerSwift
import Hero
import Theo


/* Stores all of the current board topics, loads from Core Data. */
class MasterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UITextFieldDelegate, SegueDelegate {

    var boards = [NSManagedObject]()
    var gradient: CAGradientLayer!
    var cellName = ""
    // New name for renaming board
    var newValue = ""
    var editingStatus = false
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tutorialButton: UIBarButtonItem!
    
    // Display the tutorials to the user
    @IBAction func displayTutorials(_ sender: Any) {
        let tutorial = self.storyboard?.instantiateViewController(withIdentifier: "tutorialViewController") as! TutorialViewController
        present(tutorial, animated: true, completion: nil)
    }
    
    // MARK: Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Attach a fade to the top and bottom of the scroll
        gradient = CAGradientLayer()
        gradient.frame = collectionView.bounds
        gradient.colors = [
            UIColor(white: 1, alpha: 0).cgColor,
            UIColor(white: 1, alpha: 1).cgColor,
            UIColor(white: 1, alpha: 1).cgColor,
            UIColor(white: 1, alpha: 0).cgColor
        ]
        var top = 0.05
        var bottom = 0.95
        if 0.05*collectionView.frame.height > 20 {
            top = Double(20/collectionView.frame.height)
            bottom = 1.0 - top
        }
        gradient.locations = [0, top, bottom, 1] as [NSNumber]
        self.collectionView.layer.mask = gradient
        
        textField.delegate = self

        editButtonItem.tintColor = UIColor(rgb: 0x34E5FF)
        editButtonItem.image = UIImage(named: "Edit")
        editButtonItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "DINAlternate-Bold", size: 20)!], for: .normal)
        toolbar.items![0] = editButtonItem
        toolbar.clipsToBounds = true
        toolbar.layer.masksToBounds = true
        toolbar.layer.shadowColor = UIColor.clear.cgColor
        toolbar.layer.cornerRadius = 25.0
        
        self.collectionView.reloadData()
        self.load() { (success) -> Void in
            if success {
                self.collectionView.animateViews(animations: [AnimationType.from(direction: .right, offset: self.view.frame.width - 60)], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0, duration: 0.5, animationInterval: 0.1, completion: {})
            }
        }
        
        self.setUpOrientation()
    }
    
    // Tracks the editing status of the boards and updates options based on it
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editingStatus {
            editButtonItem.image = UIImage(named: "Edit")
            self.textField.isEnabled = true
        } else {
            editButtonItem.image = nil
            editButtonItem.title = "Done"
            self.textField.isEnabled = false
        }
        self.editingStatus = editing
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPath) as? Cell {
                    cell.isEditing = editing
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            let destined = segue.destination as! DetailViewController
            destined.name = cellName
        } else if segue.identifier == "toEdit" {
            if let view = sender as? CenteredTextView, let editController = segue.destination as? EditNameController {
                
                editController.textView = view
                editController.transition = view.hero.id!
                editController.hero.modalAnimationType = .zoomSlide(direction: .left)
            }
        }
    }
    
    // MARK: Construction functions
    
    // As it scrolls, clip the gradient to the edges
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gradient.frame = collectionView.bounds
    }
    
    // Load boards from Core Data
    func load(completion: @escaping (_ success: Bool) -> Void) {
    
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext =
            appDelegate.managedObjectContext
        
        let fetchRequest =
            NSFetchRequest<NSFetchRequestResult>(entityName: "Board")
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            self.boards = data as! [NSManagedObject]
            completion(true)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            completion(true)
        }
        
    }
    
    // Attaches an orientation observer
    func setUpOrientation() {
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange,
                                               object: nil,
                                               queue: .main,
                                               using: didRotate)
    }
    
    // Rotate elements based on orientation
    var didRotate: (Notification) -> Void = { notification in
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            ItemFrames.shared.rotate(toOrientation: "toLeft", sender: self)
        case .landscapeRight:
            ItemFrames.shared.rotate(toOrientation: "toRight", sender: self)
        case .portrait:
            if ItemFrames.shared.orientation == "left" {
                ItemFrames.shared.rotate(toOrientation: "backFromLeft", sender: self)
            } else if ItemFrames.shared.orientation == "right" {
                ItemFrames.shared.rotate(toOrientation: "backFromRight", sender: self)
            }
        default:
            print("Default")
        }
    }
    
    // Delete a board from Core Data
    func delete(from: UITextView, cell: Cell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext
            context.delete(boards.remove(at: indexPath.row))
            collectionView.deleteItems(at: [indexPath])
            do {
                try context.save()
            } catch {
                print("Could not successfully delete")
            }
        }
    }
    
    // MARK: TextField delegate functions
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNewObject(_:)))
        saveButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "DINAlternate-Bold", size: 20)!], for: .normal)
        saveButton.tintColor = UIColor(rgb: 0x34E5FF)
        toolbar.items![0] = saveButton
        tintView.backgroundColor = UIColor(rgb: 0xADBDFF)
        self.tintView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.insertSubview(tintView, aboveSubview: self.collectionView)
        tutorialButton.tintColor = .clear
        self.view.bringSubview(toFront: toolbar)
        
    }
    
    // Resets status when naming a board is finished
    func textFieldDidEndEditing(_ textField: UITextField) {
        editButtonItem.image = UIImage(named: "Edit")
        toolbar.items![0] = editButtonItem
        textField.text?.removeAll()
        tutorialButton.tintColor = UIColor(rgb: 0x34E5FF)
        self.view.sendSubview(toBack: tintView)
        tintView.backgroundColor = UIColor.clear
    }
    
    // Limits title length of board
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        return newLength <= 35
    }
    
    @objc
    func dismissKeyboard(_ sender: Any) {
        textField.endEditing(true)
    }
    
    // MARK: Saving board functions
    
    // Saving a new board
    @objc
    func saveNewObject(_ sender: Any) {
        
        if textField.text?.trimmingCharacters(in: .whitespaces).isEmpty != true {
            
            let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDel.managedObjectContext
            let entity =  NSEntityDescription.entity(forEntityName: "Board", in: context)
            let adding = NSManagedObject(entity: entity!, insertInto: context)
            adding.setValue(Date(), forKey: "timestamp")
            adding.setValue(textField.text, forKey: "name")
            
            do {
                try context.save()
                self.boards.append(adding)
                textField.text = ""
                textField.endEditing(true)
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            self.collectionView.reloadData()
            let indexedPath = IndexPath(item: self.boards.count - 1, section: 0)

            // Delay needed to offset tableView reloading
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.005) {
                self.collectionView.cellForItem(at: indexedPath)?.animate(animations: [AnimationType.from(direction: .right, offset: self.view.frame.width - 60)], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: nil)
            }
            self.view.sendSubview(toBack: tintView)
            tintView.backgroundColor = UIColor.clear
        } else {
            textField.endEditing(true)
        }
    }
    
    // Edit the persistent data when the user changes a board name
    func editObject(sub: String) {
    
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext =
            appDelegate.managedObjectContext
        
        let fetchRequest =
            NSFetchRequest<NSFetchRequestResult>(entityName: "Board")
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            let results = data as! [NSManagedObject]
            for object in results {
                if (object.value(forKey: "name") as! String == self.newValue) {
                    object.setValue(sub, forKey: "name")
                    print("saveValue")
                }
            }
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            
        }
        
        // Call function to update database
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.updateNeo4jBoard(fromBoard: self.newValue, toBoard: sub)
        }
    }
    
    func updateNeo4jBoard(fromBoard: String, toBoard: String) {
     
        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(fromBoard)'}) RETURN n"
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        
        APIKeys.shared.theo.executeTransaction(statements, completionBlock: { (response, error) in
            if error != nil {
                print("Updating Neo4j board error: \(error)")
            } else {
                // Parse data from Neo4j response
                // Dictionary
                let resultobject = response["results"]!
                let resulted = resultobject as! Array<AnyObject>
                // Array
                for res in resulted {
                    let resp = res as! Dictionary<String, AnyObject>
                    // Dictionary
                    let reyd = resp["data"]! as! Array<AnyObject>
                    // Array
                    for reyd2 in reyd {
                        let reydd = reyd2 as! Dictionary<String, AnyObject>
                        let rat = reydd["graph"]! as! Dictionary<String, AnyObject>
                        let mirrortarray = rat["nodes"]! as! Array<AnyObject>
                        // Loop through the nodes for the board
                        for rort in mirrortarray {
                            let rortarray = rort as! Dictionary<String, AnyObject>
                            // Pull id and properties from this dictionary
                            let id = rortarray["id"] as! String
                            var note: String!
                            var imageRef: String!
                            var xCoord = ""
                            var yCoord = ""
                            var updatedBoardProps = ["":""]
                            // Pulls other properties to preserve in update
                            let rortprop = rortarray["properties"] as! Dictionary<String, AnyObject>
                            for ror in rortprop {
                                if (ror.key == "note") {
                                    note = ror.value as! String
                                } else if (ror.key == "image") {
                                    imageRef = ror.value as! String
                                }
                                if (ror.key == "x coordinate") {
                                    xCoord = ror.value as! String
                                }
                                if (ror.key == "y coordinate") {
                                    yCoord = ror.value as! String
                                }
                            }

                            if note != nil {
                                updatedBoardProps = ["note": "\(note!)", "board": "\(toBoard)", "x coordinate": "\(xCoord)", "y coordinate": "\(yCoord)"]
                            } else if imageRef != nil {
                                updatedBoardProps = ["image": "\(imageRef!)", "board": "\(toBoard)", "x coordinate": "\(xCoord)", "y coordinate": "\(yCoord)"]
                            }
                            
                            APIKeys.shared.theo.fetchNode(id, completionBlock: {(node, error) in
                                APIKeys.shared.theo.updateNode(node!, properties: updatedBoardProps, completionBlock: {(node, error) in
                                    print("Updating node error: \(error)")
                                })
                            })
                        }
                    }
                }
            }
          })
    }
    
    // MARK: CollectionView delegate functions

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.boards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        let board = boards[indexPath.row]
        cell.textView.text = board.value(forKey: "name") as? String
        cell.labelName = cell.textView.text
        cell.delegate = self
        cell.setUp(editing: self.editingStatus)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView.cellForItem(at: indexPath) as! Cell
        cellName = cell.textView.text!
        self.performSegue(withIdentifier: "showDetail", sender: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat((collectionView.frame.size.width / 2) - 40), height: CGFloat((collectionView.frame.size.width / 2) - 40))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

