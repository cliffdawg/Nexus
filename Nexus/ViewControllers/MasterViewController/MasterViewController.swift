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

/* Stores all of the current board topics, loads from Core Data. */
class MasterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UITextFieldDelegate, SegueDelegate {

    var boards = [NSManagedObject]()
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var newValue = ""
    var editingStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textField.delegate = self
        //textField.alpha = 0.0
        toolbar.items![0] = editButtonItem
        //self.leftButton = toolbar.items![0]
        //textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        //let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(preInsertNewObject(_:)))
        //saveButton.isEnabled = false
        //saveButton.tintColor = .clear
        //navigationItem.rightBarButtonItem = saveButton
        //////////////////
        self.collectionView.reloadData()
        self.load() { (success) -> Void in
            if success {
                self.setupActivityIndicator()
                self.activityIndicator.stopAnimating()
                
                self.collectionView.animateViews(animations: [AnimationType.from(direction: .right, offset: self.view.frame.width - 60)], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0, duration: 0.5, animationInterval: 0.1, completion: {})
            }
        }
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
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
    
    func delete(from: UITextView, cell: Cell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext
            context.delete(boards.remove(at: indexPath.row))
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //let textFieldFrame = CGRect(x: 0, y: 0, width: 140, height: 20)
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNewObject(_:)))
        saveButton.tintColor = .purple
        //let addCancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelNewObject(_:)))
        //navigationItem.rightBarButtonItem?.tintColor = .none
        //navigationItem.setRightBarButtonItems([addSaveButton, addCancelButton], animated: true)
        toolbar.items![0] = saveButton
        //navigationItem.setLeftBarButton(saveButton, animated: true)
        
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MasterViewController.dismissKeyboard))
        //self.tintView.addGestureRecognizer(tap)
        tintView.backgroundColor = UIColor(red: 46/255, green: 177/255, blue: 135/255, alpha: 0.5)
        self.tintView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.insertSubview(tintView, aboveSubview: self.collectionView)
        self.view.bringSubview(toFront: toolbar)
        
        //self.view.sendSubview(toBack: tableView)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        if ((textField.text?.trimmingCharacters(in: .whitespaces).isEmpty) == true) {
//            toolbar.items![0].tintColor = .blue
//            toolbar.items![0].title = "Edit"
//            toolbar.items![0].action = editButtonItem.action
            toolbar.items![0] = editButtonItem
        }
        self.view.sendSubview(toBack: tintView)
        tintView.backgroundColor = UIColor.clear
        //view.gestureRecognizers?.removeAll()
    }
    
    @objc
    func dismissKeyboard(_ sender: Any) {
        textField.endEditing(true)
        //self.view.sendSubview(toBack: tintView)
        //view.endEditing(true)
        
    }
    
    @objc
    func preInsertNewObject(_ sender: Any) {
       
    }
    
    @objc
    func saveNewObject(_ sender: Any) {
        print("saveNewObject")
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "Board", in: context)
        
        let adding = NSManagedObject(entity: entity!, insertInto: context)
        adding.setValue(Date(), forKey: "timestamp")
        adding.setValue(textField.text, forKey: "name")
        
        do {
            
            try context.save()
            //let insertIndexPath = IndexPath(item: self.boards.count, section: 0)
            //self.collectionView.insertItems(at: [insertIndexPath])
            self.boards.append(adding)
            print("boards append")
            textField.text = ""
            textField.endEditing(true)
            //self.dismissKeyboard(self.view)
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        
        
        
        //tableView.reloadRows(at: [IndexPath.init(row: boards.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
        ///////////////////////
        self.collectionView.reloadData()
        
        // you need to press the done aspect
        // something to do with reloading the data itself
        // not editing when reload and then animate
        //let when = DispatchTime.now() + 2
        //DispatchQueue.main.asyncAfter(deadline: when) {
//        self.collectionView.cellForRow(at: IndexPath.init(row: self.boards.count-1, section: 0))?.animate(animations: [AnimationType.from(direction: .right, offset: self.view.frame.width - 60)], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: {})
        print("boards: \(self.boards.count)")
        // now indexpath(0, 0) works
        let indexedPath = IndexPath(item: self.boards.count-1, section: 0)
        print("indexPath: \(indexedPath)")
        //self.setupActivityIndicator()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.005) {
            self.collectionView.cellForItem(at: indexedPath)?.animate(animations: [AnimationType.from(direction: .right, offset: self.view.frame.width - 60)], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: {
                    print("animate")
            })
        }
//        self.collectionView.animateViews(animations: [AnimationType.from(direction: .right, offset: self.view.frame.width - 60)], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0, duration: 0.5, animationInterval: 0.1, completion: {
//                //self.activityIndicator.stopAnimating()
//            })
        self.view.sendSubview(toBack: tintView)
        tintView.backgroundColor = UIColor.clear
        
        //}
        //        [AnimationType.from(direction: .right, offset: view.frame.width - 60)], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0, duration: 0.5, animationInterval: 0.1, completion: {    }
        
//        view.gestureRecognizers?.removeAll()
//        textField.endEditing(true)
//        view.isUserInteractionEnabled = true
//        print("view: \(view.interactions)")
        
    }
    
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
    
    var cellName = ""
    
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
            if let view = sender as? UITextView, let editController = segue.destination as? EditNameController {
                
                editController.textView = view
                editController.transition = view.heroID!
                editController.heroModalAnimationType = .zoomSlide(direction: .left)
                
                //view.heroModifiers = [.backgroundColor(.red)]
                //editController.textView.heroModifiers = [.backgroundColor(.blue)]
                
                print("toEdit: \(view.heroID), \(editController.textView.heroID)")
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
        cell.textView.text = board.value(forKey: "name") as! String
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // row count
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 155, height: 155)
//    }
    
    // MARK: TableViewController Overrides

    // MARK: - Fetched results controller
    
    

//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }

//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//            case .insert:
//                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
//            case .delete:
//                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
//            default:
//                return
//        }
//    }

//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//            case .insert:
//                tableView.insertRows(at: [newIndexPath!], with: .fade)
//            case .delete:
//                tableView.deleteRows(at: [indexPath!], with: .fade)
//            case .update:
//                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
//            case .move:
//                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
//                tableView.moveRow(at: indexPath!, to: newIndexPath!)
//        }
//    }

//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }

    
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */
    
    // we override this method to manage what style status bar is shown

}

