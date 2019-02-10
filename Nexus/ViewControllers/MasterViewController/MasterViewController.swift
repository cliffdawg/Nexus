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
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tutorialButton: UIBarButtonItem!
    
    
    var gradient: CAGradientLayer!
    
    var cellName = ""
    
    var newValue = ""
    var editingStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //////////////////
        self.collectionView.reloadData()
        self.load() { (success) -> Void in
            if success {
                self.setupActivityIndicator()
                self.activityIndicator.stopAnimating()
                
                self.collectionView.animateViews(animations: [AnimationType.from(direction: .right, offset: self.view.frame.width - 60)], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0, duration: 0.5, animationInterval: 0.1, completion: {})
            }
        }
        
        self.setUpOrientation()
        
        //* Maybe put a loading animation until it pushes through?
        self.setupTheo()
    }
    
    // Tracks the editing status of the boards
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editingStatus {
            // Currently editing
            editButtonItem.image = UIImage(named: "Edit")
            self.textField.isEnabled = true
        } else {
            editButtonItem.image = nil
            editButtonItem.title = "Done"
            self.textField.isEnabled = false
        }
        self.editingStatus = editing
        print("setEditing: \(editingStatus)")
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
        // Dispose of any resources that can be recreated.
    }

    private func setupActivityIndicator() {
        activityIndicator.center = CGPoint(x: view.center.x, y: 100.0)
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
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
    
    func setUpOrientation() {
        print("setuporientation")
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange,
                                               object: nil,
                                               queue: .main,
                                               using: didRotate)
    }
    
    // This works for orientation
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
    
    func delete(from: UITextView, cell: Cell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext
            context.delete(boards.remove(at: indexPath.row))
            collectionView.deleteItems(at: [indexPath])
            do {
                try context.save()
            } catch {
                print("Could not save")
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNewObject(_:)))
        saveButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "DINAlternate-Bold", size: 20)!], for: .normal)
        saveButton.tintColor = UIColor(rgb: 0x34E5FF)
        
        toolbar.items![0] = saveButton
        
        tintView.backgroundColor = UIColor(rgb: 0xADBDFF)
        self.tintView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.insertSubview(tintView, aboveSubview: self.collectionView)
        //* make button clear on input shift
        tutorialButton.tintColor = .clear
        self.view.bringSubview(toFront: toolbar)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        editButtonItem.image = UIImage(named: "Edit")
        toolbar.items![0] = editButtonItem
        textField.text?.removeAll()
        tutorialButton.tintColor = UIColor(rgb: 0x34E5FF)
        self.view.sendSubview(toBack: tintView)
        tintView.backgroundColor = UIColor.clear
    }
    
    // Limits title of board name
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
    
    @objc
    func preInsertNewObject(_ sender: Any) {
       
    }
    
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
                print("boards append")
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
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
        
            self.updateNeo4jBoard(fromBoard: self.newValue, toBoard: sub)
            
        }
    }
    
    // This is meant to establish an initial connection to database from the start
    func setupTheo() {
        print("setup theo")
        //let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: `\(self.name)`}) RETURN n"
        //MATCH (n:`30496B97-0AAB-4B7E-9423-50F37BC372A9`) RETURN n
        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)`) RETURN n"

        print("cypherQuery: \(cypherQuery)")
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        
        let theo = RestClient(baseURL: APIKeys.shared.baseURL, user: APIKeys.shared.user, pass: APIKeys.shared.pass)

        theo.executeTransaction(statements, completionBlock: { (response, error) in
    
            if error != nil {
                // what if we try to load again in response to the error
                // TODO: Add warning notifications to errors and segue back to home
                print("setup theo error: \(error)")
                self.setupTheo()
            } else {
                print("setup theo: \(response)")
            }
        })
    }
    
    func updateNeo4jBoard(fromBoard: String, toBoard: String) {
        print("updateBoard")

        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(fromBoard)'}) RETURN n"
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]

        let theo = RestClient(baseURL: APIKeys.shared.baseURL, user: APIKeys.shared.user, pass: APIKeys.shared.pass)
        
        ///* For some reason, loading nexus always fails on the first attempt. Maybe theo needs time to link through RestClient
        theo.executeTransaction(statements, completionBlock: { (response, error) in
            ///*
            if error != nil {
                print("loadIndividual error: \(error)")
                
            } else {
                print("response2: \(response)")
                for respond in response {
                    print("respond2: \(respond.key)")
                }
                // (key: NSObject, value: AnyObject) is a unit FOR A DICTIONARY
                print("results2: \(response["results"]!)")
                let resultobject = response["results"]!
                let mirrorResult = Mirror(reflecting: resultobject)
                print("mirror2: \(mirrorResult.subjectType)")
                let resulted = resultobject as! Array<AnyObject>
                print("resulted2: \(resulted)")
                // Array
                for res in resulted {
                    print("res2: \(res)")
                    let mirrorRes = Mirror(reflecting: res)
                    print("mirrorres2: \(mirrorRes.subjectType)")
                    let resp = res as! Dictionary<String, AnyObject>
                    // Dictionary
                    print("resp2[\"data\"]: \(resp["data"]!)")
                    let mirrordata = Mirror(reflecting: resp["data"]!)
                    print("mirrordata2: \(mirrordata.subjectType)")
                    let reyd = resp["data"]! as! Array<AnyObject>
                    // Array
                    for reyd2 in reyd {
                        print("reyd2.2: \(reyd2)")
                        let mirrorreyd2 = Mirror(reflecting: reyd2)
                        print("mirrorreyd2.2: \(mirrorreyd2.subjectType)")
                        let reydd = reyd2 as! Dictionary<String, AnyObject>
                        print("reyddgraph.2: \(reydd["graph"]!)")
                        let mirrorgraph = Mirror(reflecting: reydd["graph"]!)
                        print("mirrorgraph.2: \(mirrorgraph.subjectType)")
                        let rat = reydd["graph"]! as! Dictionary<String, AnyObject>
                        print("ratnodes.2: \(rat["nodes"]!)")
                        let mirrort = Mirror(reflecting: rat["nodes"]!)
                        print("mirrorrt.2: \(mirrort.subjectType)")
                        let mirrortarray = rat["nodes"]! as! Array<AnyObject>
                        // These loop through the nodes
                        for rort in mirrortarray {
                            
                            let rortarray = rort as! Dictionary<String, AnyObject>
                            print("rortarray: \(rortarray)")
                            // Pull id and properties from this dictionary
                            print("rortid: \(rortarray["id"])")
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
                            
                            theo.fetchNode(id, completionBlock: {(node, error) in
                                print("update id node: \(node)")
                                
                                theo.updateNode(node!, properties: updatedBoardProps, completionBlock: {(node, error) in
                                    print("updateboard error: \(error)")
                                })
                                
                            })
                            
                            
                            
                            }
                        
                        }
                    }
                }
          })
    }
    
    // Display the tutorials to the user
    @IBAction func displayTutorials(_ sender: Any) {
        let tutorial = self.storyboard?.instantiateViewController(withIdentifier: "tutorialViewController") as! TutorialViewController
        present(tutorial, animated: true, completion: nil)
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        print("insertNewObject")
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = self.tableView.cellForRow(at: indexPath) as! Cell
//        cellName = cell.textView.text!
//        self.performSegue(withIdentifier: "showDetail", sender: cell)
//
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gradient.frame = collectionView.bounds
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            let destined = segue.destination as! DetailViewController
            //self.addChildViewController(destined)
            destined.name = cellName
            print("prepare for segue")
            print(cellName)
        } else if segue.identifier == "toEdit" {
            print("sender: \(sender), destination: \(segue.destination)")
            if let view = sender as? CenteredTextView, let editController = segue.destination as? EditNameController {
                
                editController.textView = view
                editController.transition = view.hero.id!
                editController.hero.modalAnimationType = .zoomSlide(direction: .left)
                
                //view.heroModifiers = [.backgroundColor(.red)]
                //editController.textView.heroModifiers = [.backgroundColor(.blue)]
                
                print("toEdit: \(view.hero.id), \(editController.textView.hero.id)")
            }
        }
    }

    // MARK: - Table View

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return boards.count
//    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
//            let context:NSManagedObjectContext = appDel.managedObjectContext
//            context.delete(boards.remove(at: indexPath.row))
//
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
//        }
//    }
    
    
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80.0
//    }

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
        print("cell select")
        let cell = self.collectionView.cellForItem(at: indexPath) as! Cell
        cellName = cell.textView.text!
        self.performSegue(withIdentifier: "showDetail", sender: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat((collectionView.frame.size.width / 2) - 40), height: CGFloat((collectionView.frame.size.width / 2) - 40))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // row count
    }
    
    // MARK: TableViewController Overrides

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */
    
    // we override this method to manage what style status bar is shown

}

