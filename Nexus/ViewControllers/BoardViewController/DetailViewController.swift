//
//  DetailViewController.swift
//  Nexus
//
//  Created by Clifford Yin on 1/11/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import ViewAnimator
import Theo
import Firebase
import FirebaseStorage
import FirebaseDatabase
import AlamofireImage
import Alamofire
import NVActivityIndicatorView
import NotificationBannerSwift

//* Optional(Error Domain=Invalid response Code=-1 "(null)")

// Convert hex to UIColor
// Color scheme:
// 007AFF - main blue
// A533FF - main purple
// B74F6F - cherry red
// ADBDFF - pastel blue
// 34E5FF - tael
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

/* ViewController that presents the Nexus as a pin-board type view. */
class DetailViewController: UIViewController, UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate, ChooseAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DrawLineDelegate, UITextViewDelegate, NotificationBannerDelegate {
    
    var name = ""
    var returnBoolean = false
    var lineBegin = CGPoint(x: 30, y: 30)
    var lineEnd = CGPoint(x: 140, y: 140)
    var imageToChange: CustomImage!
    var downloadItems = [DownloadItem]()
    var individualItems = [DownloadItem]()
    var imagePickerController: UIImagePickerController?
    var popoverViewController: AddType!
    let storageRef = Storage.storage().reference()
    var ref = Database.database().reference()
    var activity = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
    let banner = NotificationBanner(title: "Error", subtitle: "Loading and reconnecting...", style: .danger)
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var addSymbol: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var createNote: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var customView: CustomView!
    @IBOutlet weak var newNoteLabel: UITextView!
    @IBOutlet weak var addNoteButton: UIButton!
    @IBOutlet weak var connectingBanner: UILabel!
    @IBOutlet weak var endConnect: UIBarButtonItem!
    
    // MARK: Lifecycle functinos
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSymbol.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "DINAlternate-Bold", size: 20)!], for: .normal)
        self.endConnect.isEnabled = false
        self.endConnect.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "DINAlternate-Bold", size: 20)!], for: .normal)
        self.saveButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "DINAlternate-Bold", size: 20)!], for: .normal)
        self.label.text = self.name
        self.backButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "DINAlternate-Bold", size: 20)!], for: .normal)
        
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        self.titleView.animate(animations: [zoomAnimation], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: { })
        
        // ItemFrames' controllerViews is used to rotate views on any screen
        ItemFrames.shared.controllerViews.append(self.createNote)
        ItemFrames.shared.controllerViews.append(self.connectingBanner)
        self.createNote.alpha = 0.0
        self.newNoteLabel.layer.borderWidth = 3.0
        self.newNoteLabel.layer.borderColor = UIColor(rgb: 0x34E5FF).cgColor
        self.newNoteLabel.dropShadow()
        self.addNoteButton.dropShadow()
        self.newNoteLabel.delegate = self
        
        self.connectTheo()

        self.view.bringSubview(toFront: topBar)
        self.view.bringSubview(toFront: bottomBar)
        
        topBar.clipsToBounds = true
        topBar.layer.masksToBounds = true
        topBar.layer.cornerRadius = 25.0
        bottomBar.clipsToBounds = true
        bottomBar.layer.masksToBounds = true
        bottomBar.layer.cornerRadius = 25.0
        self.setUpOrientation()
    }
    
    // MARK: Initialization functions
    
    func connectTheo() {
        
        // Clears away leftover UI elements
        self.draw(start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: 0.0))
        for object in ItemFrames.shared.frames {
            object.removeFromSuperview()
        }
        for connection in ItemFrames.shared.connections {
            connection.label.removeFromSuperview()
        }
        ItemFrames.shared.frames.removeAll()
        ItemFrames.shared.connections.removeAll()
        
        let frame = CGRect(x: self.view.frame.midX - 45, y: self.view.frame.midY - 45, width: 90, height: 90)
        self.activity = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: 9), color: .blue, padding: nil)
        self.view.addSubview(self.activity)
        if ItemFrames.shared.orientation != "" {
            ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: self.activity)
        }
        self.activity.startAnimating()
        safeDisable(wantToDisable: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.initialUpdateConnections()
        }
    }
    
    // Pulls connections right before loading to make sure local data is up-to-date
    func initialUpdateConnections() {
        
        banner.delegate = self
        
        ItemFrames.shared.downloadedConnections.removeAll()
        
        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'})-[r]->(m:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'}) RETURN n, r, m"
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        
        APIKeys.shared.theo.executeTransaction(statements, completionBlock: { (response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    if !self.banner.isDisplaying {
                        self.banner.show()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                            self.banner.isHidden = true
                            let loading = self.storyboard?.instantiateViewController(withIdentifier: "loadingController") as! LoadingViewController
                            loading.nextController = "board"
                            loading.boardController = self
                            self.present(loading, animated: true, completion: nil)
                        })
                    }
                }
            } else {
                let resultobject = response["results"]!
                let mirrorResult = Mirror(reflecting: resultobject)
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
                        let ratarray = rat["relationships"]! as! Array<AnyObject>
                        // This prints out all the relationships
                        for ratt in ratarray {
                            let connection = Connection()
                            let mirt = ratt as! Dictionary<String, AnyObject>
                            connection.end = mirt["endNode"] as! String
                            connection.origin = mirt["startNode"] as! String
                            connection.connection = mirt["type"] as! String
                            // Also check for same beginNode and endNode
                            if ItemFrames.shared.downloadedConnections.contains(where: {$0.connection == connection.connection && $0.end == connection.end && $0.origin == connection.origin}) == false {
                                ItemFrames.shared.downloadedConnections.append(connection)
                            }
                        }
                    }
                }
                self.loadNexus()
            }
        })
    }
    
    // Load objects that are present in connections
    func loadNexus() {
        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'})-[r]->(m:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'}) RETURN n, r, m"
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        
        // Use threading as async-await
        let dispatchGroup = DispatchGroup()
        
        APIKeys.shared.theo.executeTransaction(statements, completionBlock: { (response, error) in
            if error != nil {
                print("loadNexus() error: \(error)")
            } else {
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
                        let mirrorreyd2 = Mirror(reflecting: reyd2)
                        let reydd = reyd2 as! Dictionary<String, AnyObject>
                        let rat = reydd["graph"]! as! Dictionary<String, AnyObject>
                        let mirrortarray = rat["nodes"]! as! Array<AnyObject>
                        // These loop through the nodes
                        for rort in mirrortarray {
                            let download = DownloadItem()
                            // This is where you can extract the node id
                            let rortarray = rort as! Dictionary<String, AnyObject>
                            // Pull id and properties from this dictionary
                            download.uniqueID = rortarray["id"] as! String
                            
                            let rortprop = rortarray["properties"] as! Dictionary<String, AnyObject>
                            for ror in rortprop {
                                if ror.key == "note" {
                                    download.note = ror.value as! String
                                } else if ror.key == "image" {
                                    download.imageRef = ror.value as! String
                                    download.image = UIImage(named: "Image Placeholder")
                                }
                                if ror.key == "x coordinate" {
                                    let xSub = ror.value as! String
                                    download.xCoord = (xSub as NSString).doubleValue
                                }
                                if ror.key == "y coordinate" {
                                    let ySub = ror.value as! String
                                    download.yCoord = (ySub as NSString).doubleValue
                                    if self.downloadItems.contains(where: {$0.uniqueID == download.uniqueID}) == false {
                                        self.downloadItems.append(download)
                                    }
                                }
                            }
                        }
                        let mirrorrat = Mirror(reflecting: rat["relationships"]!)
                        let ratarray = rat["relationships"]! as! Array<AnyObject>
                        // This collects all the relationships
                        for ratt in ratarray {
                            let connection = Connection()
                            let mirt = ratt as! Dictionary<String, AnyObject>
                            connection.end = mirt["endNode"] as! String
                            connection.origin = mirt["startNode"] as! String
                            connection.connection = mirt["type"] as! String
                            
                            for loaded in self.downloadItems {
                                
                                dispatchGroup.enter()
                                
                                if loaded.uniqueID == connection.origin {
                                    connection.begin = loaded
                                    connection.beginID = loaded.uniqueID
                                    
                                    if ItemFrames.shared.connections.contains(where: {$0.connection == connection.connection && $0.end == connection.end && $0.origin == connection.origin}) == false {
                                        
                                        ItemFrames.shared.connections.append(connection)
                                        dispatchGroup.leave()
                                        
                                    } else {
                                        dispatchGroup.leave()
                                    }
                                } else if loaded.uniqueID == connection.end {
                                    connection.finish = loaded
                                    connection.finishID = loaded.uniqueID
                                    
                                    if ItemFrames.shared.connections.contains(where: {$0.connection == connection.connection && $0.end == connection.end && $0.origin == connection.origin}) == false {
                                        
                                        ItemFrames.shared.connections.append(connection)
                                        dispatchGroup.leave()
                                        
                                    } else {
                                        dispatchGroup.leave()
                                    }
                                }
                            }
                        }
                    }
                }
                self.loadIndividual()
            }
        })
    }
    
    // Prior was for connections with objects, this one is for individual ones
    func loadIndividual() {
        let cypherQuery2 = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'}) RETURN n"
        let resultDataContents2 = ["row", "graph"]
        let statement2 = ["statement" : cypherQuery2, "resultDataContents" : resultDataContents2] as [String : Any]
        let statements2 = [statement2]
        
        APIKeys.shared.theo.executeTransaction(statements2, completionBlock: { (response, error) in
            if error != nil {
                print("loadIndividual() error: \(error)")
            } else {
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
                        // These loop through the nodes
                        for rort in mirrortarray {
                            let download = DownloadItem()
                            // This is where you can extract the node id
                            let rortarray = rort as! Dictionary<String, AnyObject>
                            // Pull id and properties from this dictionary
                            download.uniqueID = rortarray["id"] as! String
                            
                            let rortprop = rortarray["properties"] as! Dictionary<String, AnyObject>
                            for ror in rortprop {
                                if ror.key == "note" {
                                    download.note = ror.value as! String
                                } else if ror.key == "image" {
                                    download.imageRef = ror.value as! String
                                }
                                if ror.key == "x coordinate" {
                                    let xSub = ror.value as! String
                                    download.xCoord = (xSub as NSString).doubleValue
                                }
                                if ror.key == "y coordinate" {
                                    let ySub = ror.value as! String
                                    download.yCoord = (ySub as NSString).doubleValue
                                    if self.individualItems.contains(where: {$0.uniqueID == download.uniqueID}) == false {
                                        self.individualItems.append(download)
                                    }
                                }
                                for item in self.individualItems {
                                    if self.downloadItems.contains(where: {$0.uniqueID == item.uniqueID}) == false {
                                        self.downloadItems.append(item)
                                    }
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    for item in self.downloadItems {
                        var obj = CustomImage()
                        if item.imageRef != nil {
                            let rect = CGRect(x: (item.xCoord)!, y: (item.yCoord)!, width: ItemFrames.shared.imageDimension, height: ItemFrames.shared.imageDimension)
                            obj = CustomImage(frame: rect)
                            obj.imageLink = item.imageRef
                            obj.uniqueID = item.uniqueID
                            obj.type = "image"
                            ItemFrames.shared.frames.append(obj)
                        } else if item.note != nil {
                            let rect = CGRect(x: (item.xCoord)!, y: (item.yCoord)!, width: ItemFrames.shared.noteDimension, height: ItemFrames.shared.noteDimension)
                            obj = CustomImage(frame: rect)
                            obj.configureNote(setNote: (item.note)!)
                            obj.uniqueID = item.uniqueID
                            obj.type = "note"
                            ItemFrames.shared.frames.append(obj)
                        }
                        // Assigned downloaded ID's here
                        for connect in ItemFrames.shared.connections {
                            if obj.uniqueID == connect.beginID {
                                connect.downloadBegin = obj
                            } else if obj.uniqueID == connect.finishID {
                                connect.downloadFinish = obj
                            }
                        }
                        
                    }
                    self.customView.loadImages(sender: self)
                    self.loadBoard()
                    self.activity.stopAnimating()
                    self.safeDisable(wantToDisable: false)
                }
            }
        })
    }
    
    // Trigger customView set up
    func loadBoard() {
        self.draw(start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: 0.0))
        self.customView.loadFrames(sender: self)
    }
    
    // MARK: Notification delegate functions
    
    func notificationBannerWillAppear(_ banner: BaseNotificationBanner) {
        // Dud
    }
    
    func notificationBannerDidAppear(_ banner: BaseNotificationBanner) {
        // Dud
    }
    
    func notificationBannerWillDisappear(_ banner: BaseNotificationBanner) {
        // Dud
    }
    
    func notificationBannerDidDisappear(_ banner: BaseNotificationBanner){
        // Redundant because of loading view implementation
        self.returnBoolean = true
    }
    
    // MARK: Orientation rotation listener
    
    // Attaches orientation observor
    func setUpOrientation() {
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange,
                                              object: nil,
                                              queue: .main,
                                              using: didRotate)
    }
    
    // Implement orientation and rotate listener
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
            print("Other orientation")
        }
    }
    
    // MARK: Adding-menu capability
    
    // Present the adding menu
    @IBAction func pressAdd(_ sender: Any) {
        popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "addType") as! AddType
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize(width:200, height:200)
        popoverViewController.delegate2 = self
        
        // Reference to it so it can rotate as well when presented
        ItemFrames.shared.rotatingTypeMenu = popoverViewController
        
        let popoverPresentationViewController = popoverViewController.popoverPresentationController
        popoverPresentationViewController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        popoverPresentationViewController?.delegate = self
        popoverPresentationViewController?.barButtonItem = self.addSymbol
        popoverPresentationViewController?.sourceRect = CGRect(x:0, y:0, width: addSymbol.width/2, height: 30)
        popoverPresentationViewController?.backgroundColor = UIColor(rgb: 0x007AFF)
        
        if ItemFrames.shared.orientation != "" {
            ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: popoverViewController.view)
        }
        present(popoverViewController, animated: true, completion: nil)
    }
    
    // Selecting which item to add 
    func chooseAdd(chosenAdd: String) {
        print(chosenAdd)
        if chosenAdd == "Add Picture" {
            self.endEditing()
            // Allows user to choose between photo library and camera
            let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.imageToChange = nil
            })
            alertController.addAction(cancelAction)
            let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .default) { (action) in
                self.showImagePickerController(sourceType: .photoLibrary)
            }
            alertController.addAction(photoLibraryAction)
            // Only show camera option if rear camera is available
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                let cameraAction = UIAlertAction(title: "Photo from Camera", style: .default) { (action) in
                    self.showImagePickerController(sourceType: .camera)
                }
                alertController.addAction(cameraAction)
            }
            if self.presentedViewController == nil {
                present(alertController, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
                present(alertController, animated: true, completion: nil)
            }
        } else if chosenAdd == "Add Note" {
            self.endEditing()
            self.createNote.alpha = 1.0
            if self.presentedViewController != nil {
                self.dismiss(animated: true, completion: nil)
            }
            let newView = self.createNote
            newView?.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            UIView.animate(withDuration: 2.0,
                               delay: 0,
                               usingSpringWithDamping: CGFloat(0.9),
                               initialSpringVelocity: CGFloat(6.0),
                               options: UIViewAnimationOptions.allowUserInteraction,
                               animations: {
                                newView?.alpha = 1.0
                                newView?.transform = CGAffineTransform.identity
                },
                               completion: { Void in()  }
                )
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: newView!)
            }
            self.view.addSubview(newView!)
        } else if chosenAdd == "Create Connection" {
            self.connectingBanner.text = "Connecting"
            connectingBanner.sizeToFit()
            self.view.bringSubview(toFront: connectingBanner)
            ItemFrames.shared.connectingState = true
            ItemFrames.shared.positioning = false
            ItemFrames.shared.deleting = false
            self.connectingBanner.alpha = 1.0
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: connectingBanner)
            }
            let animate = AnimationType.from(direction: .right, offset: 100)
            self.connectingBanner.animate(animations: [animate], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: nil)
            self.endConnect.title = "Done"
            self.endConnect.isEnabled = true
            ItemFrames.shared.sendNotesToBack()
        } else if chosenAdd == "Re-position Element" {
            self.connectingBanner.text = "Re-positioning"
            connectingBanner.sizeToFit()
            self.view.bringSubview(toFront: connectingBanner)
            ItemFrames.shared.connectingState = false
            ItemFrames.shared.editing = false
            ItemFrames.shared.deleting = false
            ItemFrames.shared.positioning = true
            self.connectingBanner.alpha = 1.0
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: connectingBanner)
            }
            let animate = AnimationType.from(direction: .right, offset: 100)
            self.connectingBanner.animate(animations: [animate], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: nil)
            self.endConnect.title = "Done"
            self.endConnect.isEnabled = true
            ItemFrames.shared.sendNotesToBack()
        } else if chosenAdd == "Edit Element" {
            self.connectingBanner.text = "Editing"
            connectingBanner.sizeToFit()
            self.view.bringSubview(toFront: connectingBanner)
            ItemFrames.shared.connectingState = false
            ItemFrames.shared.positioning = false
            ItemFrames.shared.deleting = false
            self.connectingBanner.alpha = 1.0
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: connectingBanner)
            }
            let animate = AnimationType.from(direction: .right, offset: 100)
            self.connectingBanner.animate(animations: [animate], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: nil)
            self.endConnect.title = "Done"
            self.endConnect.isEnabled = true
            ItemFrames.shared.bringNotesToFront()
        } else if chosenAdd == "Delete Element" {
            self.connectingBanner.text = "Deleting"
            connectingBanner.sizeToFit()
            self.view.bringSubview(toFront: connectingBanner)
            ItemFrames.shared.connectingState = false
            ItemFrames.shared.positioning = false
            ItemFrames.shared.editing = false
            ItemFrames.shared.deleting = true
            self.connectingBanner.alpha = 1.0
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: connectingBanner)
            }
            let animate = AnimationType.from(direction: .right, offset: 100)
            self.connectingBanner.animate(animations: [animate], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: nil)
            self.endConnect.title = "Done"
            self.endConnect.isEnabled = true
            ItemFrames.shared.sendNotesToBack()
            ItemFrames.shared.setupDeleteMode()
        }
    }

    // Clear out all editing statuses
    @IBAction func endConnect(_ sender: Any) {
        self.endEditing()
    }
    
    func endEditing() {
        let animate = AnimationType.from(direction: .left, offset: 0)
        self.connectingBanner.text = ""
        self.connectingBanner.animate(animations: [animate], initialAlpha: 1.0, finalAlpha: 0.0, delay: 0.0, duration: 1.0, completion: {
            self.view.sendSubview(toBack: self.connectingBanner)
        })
        self.endConnect.title = ""
        self.endConnect.isEnabled = false
        ItemFrames.shared.connectingState = false
        ItemFrames.shared.positioning = false
        ItemFrames.shared.sendNotesToBack()
        ItemFrames.shared.exitDeleteMode()
        ItemFrames.shared.removeAllHighlights()
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        present(imagePickerController!, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let frame = CGRect(x: view.frame.midX - 25 , y: view.frame.midY - 25, width: CGFloat(ItemFrames.shared.imageDimension), height: CGFloat(ItemFrames.shared.imageDimension))
            if self.imageToChange == nil {
                let imageView = CustomImage(frame: frame)
                let size = CGSize(width: 250.0, height: 250.0)
                let imageScaled = pickedImage.af_imageScaled(to: size)
                imageView.configureImage(setImage: imageScaled)
                imageView.delegate = self
                ItemFrames.shared.frames.append(imageView)
                imageView.tag = 5
                view.addSubview(imageView)
                if ItemFrames.shared.orientation != "" {
                    ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: imageView)
                }
                ItemFrames.shared.recenterNoteviews()
            } else {
                let size = CGSize(width: 250.0, height: 250.0)
                let imageScaled = pickedImage.af_imageScaled(to: size)
                self.imageToChange.configureImage(setImage: imageScaled)
                self.imageToChange.delegate = self
                self.imageToChange.imageCache = "cacheForDelete"
                self.imageToChange = nil
                ItemFrames.shared.recenterNoteviews()
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Board interaction implementations
    
    func draw(start: CGPoint, end: CGPoint) {
        self.customView.refresh(begin: start, stop: end)
    }
    
    // Re-positions label on a re-positioned connection
    func placeLabel (object: CustomImage) {
        var connections = [Connection]()
        for connect in ItemFrames.shared.connections {
            if object.specific == connect.origin || object.specific == connect.end || object.uniqueID == connect.beginID || object.uniqueID == connect.finishID {
                connections.append(connect)
            }
        }
        self.customView.loadLabelAfterRedraw(connections: connections)
    }
    
    // Adds a note object to the current board
    @IBAction func addNote(_ sender: Any) {
        if newNoteLabel.text?.trimmingCharacters(in: .whitespaces).isEmpty == false {
            let pointX = CGFloat(self.view.frame.midX - 25)
            let pointY = CGFloat(self.view.frame.midY - 25)
            let framed = CGRect(x: pointX, y: pointY, width: 100, height: 100)
            let newView = CustomImage(frame: framed)
            newView.configureNote(setNote: newNoteLabel.text!)
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: newView)
            }
            ItemFrames.shared.frames.append(newView)
            ItemFrames.shared.updateTextFont(oneTextView: newView.noteFrame, fontSize: Int(newView.noteFrame.font!.pointSize))
            self.view.addSubview(newView)
            newView.delegate = self
            self.view.bringSubview(toFront: newView)
            self.newNoteLabel.endEditing(true)
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.createNote.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
            }, completion: {_ in
                self.view.sendSubview(toBack: self.createNote)
                self.createNote.alpha = 0.0
                self.newNoteLabel.text = ""
                self.addNoteButton.setTitle("Cancel", for: .normal)
            })
        } else {
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.createNote.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
            }, completion: {_ in
                self.view.sendSubview(toBack: self.createNote)
                self.createNote.alpha = 0.0
                self.newNoteLabel.text = ""
                self.addNoteButton.setTitle("Cancel", for: .normal)
            })
        }
    }
    
    // Edit existing image
    func changeImage(custom: CustomImage) {
        self.imageToChange = custom
        self.chooseAdd(chosenAdd: "Picture")
    }
    
    // Delete an object
    func delete(object: CustomImage) {
        var index = 0
        let storage = Storage.storage()
        let storageRef = storage.reference()
        var index2 = 0
        for frame in ItemFrames.shared.frames {
            if frame === object {
                ItemFrames.shared.frames.remove(at: index2)
            }
            index2 += 1
        }
        
        // Remove corresponding connection
        for connect in ItemFrames.shared.connections {
            if object.uniqueID == "" {
                if object.specific == connect.origin || object.specific == connect.end {
                    ItemFrames.shared.connections.remove(at: index)
                    // Decrement is needed because elements shift one space to left after a deletion
                    index -= 1
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                        connect.label.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
                        connect.label.alpha = 0.0
                    }, completion: {_ in
                        object.removeFromSuperview()
                    })
                }
            } else {
                if object.uniqueID == connect.beginID || object.uniqueID == connect.finishID {
                    ItemFrames.shared.connections.remove(at: index)
                    index -= 1
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                        connect.label.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
                        connect.label.alpha = 0.0
                    }, completion: {_ in
                        object.removeFromSuperview()
                    })
                }
            }
            index += 1
        }
        if object.type == "image" {
            let storagePath = object.imageLink
            if let storedImage = storagePath as? String {
                // Delete the stored image online
                deleteFirebaseImage(link: storedImage)
            } else {
                // Image hasn't been uploaded
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            object.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            object.alpha = 0.0
        }, completion: {_ in
            object.removeFromSuperview()
        })
    
        self.draw(start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: 0.0))
        
        let cypher = "MATCH (p:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'}) where ID(p)=\(object.uniqueID) OPTIONAL MATCH (p)-[r]-() DELETE r,p"
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypher, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        APIKeys.shared.theo.executeTransaction(statements, completionBlock: { (response, error) in
            print("delete(object: CustomImage) error: \(error)")
        })
    }
    
    // Deletes the uploaded image from Firebase storage
    func deleteFirebaseImage(link: String) {
        let storagePath = link
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: storagePath)
        storageRef.delete { error in
            if let error = error {
                print("deleteFirebaseImage(link: String) error: \(error)")
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        }
    }
    
    // MARK: Uploading/saving functions
    
    // Save data
    @IBAction func save(_ sender: Any) {
        self.loadAnimate()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            self.saveNexus()
        })
    }
    
    // Upload data to Neo4j
    func saveNexus() {
        // Creates nodes and connections in database
        for connect in ItemFrames.shared.connections {
            var relate = Relationship()
            var relateOrigin: Node!
            var relateEnd: Node!
            for item in ItemFrames.shared.frames {
                // Use threading as an async-await
                let semaphore = DispatchSemaphore(value: 0)

                if item.specific == connect.origin && item.uniqueID == "" {
                    var origin = Node()
                    if item.type == "note" {
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        origin.setProp("note", propertyValue: "\(item.note)")
                        origin.setProp("board", propertyValue: "\(self.label.text!)")
                        origin.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        origin.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        // Create the node
                        APIKeys.shared.theo.createNode(origin, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateOrigin = node
                            let rawID = node?.id
                            let intID = 1*rawID!
                            item.uniqueID = "\(intID)"
                            // Once you make the signal(), then only next loop will get executed
                            semaphore.signal()
                        })
                    } else if item.type == "image" {
                        let image = item.image
                        let refd = ref.childByAutoId()
                        let refdStore = String(describing: refd.key!)
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        let path = storageRef.child("\(ided)/\(refdStore)")
                        origin.setProp("image", propertyValue: "\(path)")
                        origin.setProp("board", propertyValue: "\(self.label.text!)")
                        origin.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        origin.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        APIKeys.shared.theo.createNode(origin, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateOrigin = node
                            let rawID = node?.id
                            let intID = 1*rawID!
                            item.uniqueID = "\(intID)"
                            item.imageLink = "\(refdStore)"
                            item.imageCache = "cacheForUpload"
                            semaphore.signal()
                        })
                    }
                    
                } else if item.uniqueID != "" {
                    // Locate node with this uniqueID
                    // Assign as beginning of relation, but don't create
                    
                    var noteUpdate = false
                    var imageUpdate = false
                    var updatedNoteProperties = ["":""]
                    var updatedImageProperties = ["":""]
                    
                    if item.noteFrame != nil {
            
                        noteUpdate = true
                        updatedNoteProperties = ["note": "\(item.noteFrame.text!)", "board": "\(self.label.text!)", "x coordinate": "\(item.frame.minX)", "y coordinate": "\(item.frame.minY)"]
                        
                    } else if item.imageFrame != nil {
                        if item.imageCache == "cacheForDelete" {
            
                            imageUpdate = true
                            deleteFirebaseImage(link: item.imageLink)
                            
                            let refd = ref.childByAutoId()
                            let refdStore = String(describing: refd.key!)
                            let ided = UIDevice.current.identifierForVendor!.uuidString
                            let path = storageRef.child("\(ided)/\(refdStore)")
                            updatedImageProperties = ["image": "\(path)", "board": "\(self.label.text!)", "x coordinate": "\(item.frame.minX)", "y coordinate": "\(item.frame.minY)"]
                            item.imageLink = refdStore
                            item.imageCache = "cacheForUpload"
                        }
                    }
                    // Now have a way to update/delete for images like notes
                    APIKeys.shared.theo.fetchNode(item.uniqueID, completionBlock: {(node, error) in
                        
                        if item.specific == connect.origin {
                            relateOrigin = node
                        } else if item.specific == connect.end {
                            relateEnd = node
                        }
                        
                        if noteUpdate {
                            APIKeys.shared.theo.updateNode(node!, properties: updatedNoteProperties, completionBlock: {(node, error) in
                                    semaphore.signal()
                                })
                        } else if imageUpdate {
                            APIKeys.shared.theo.updateNode(node!, properties: updatedImageProperties, completionBlock: {(node, error) in
                                semaphore.signal()
                            })
                        } else {
                            semaphore.signal()
                        }
                    })
                // This checked when new connection made with already-saved object
                } else {
                    // Neither fits into the connection-itemFrames correspondence or is an already used item/is an end item
                    semaphore.signal()
                }
                // Asking the semaphore to wait, till it gets the signal
                semaphore.wait()
            }
            
            for item in ItemFrames.shared.frames {
                let semaphore2 = DispatchSemaphore(value: 0)
                
                if item.specific == connect.end && item.uniqueID == "" {
                    var end = Node()
                    if item.type == "note" {
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        end.setProp("note", propertyValue: "\(item.note)")
                        end.setProp("board", propertyValue: "\(self.label.text!)")
                        end.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        end.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        APIKeys.shared.theo.createNode(end, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateEnd = node
                            let rawID = node?.id
                            let intID = 1*rawID!
                            item.uniqueID = "\(intID)"
                            semaphore2.signal()
                        })
                    } else if (item.type == "image") {
                        let image = item.image
                        let refd = ref.childByAutoId()
                        let refdStore = String(describing: refd.key!)
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        let path = storageRef.child("\(ided)/\(refdStore)")
                        end.setProp("image", propertyValue: "\(path)")
                        end.setProp("board", propertyValue: "\(self.label.text!)")
                        end.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        end.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        APIKeys.shared.theo.createNode(end, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateEnd = node
                            let rawID = node?.id
                            let intID = 1*rawID!
                            item.uniqueID = "\(intID)"
                            item.imageLink = "\(refdStore)"
                            item.imageCache = "cacheForUpload"
                            semaphore2.signal()
                        })
                    }
                } else if item.uniqueID != "" {
                    // Locate node with this uniqueID
                    // Assign as beginning of relation, but don't create
                var noteUpdate = false
                    var imageUpdate = false
                    var updatedNoteProperties = ["":""]
                    var updatedImageProperties = ["":""]
                    
                    if item.noteFrame != nil {
                        noteUpdate = true
                        updatedNoteProperties = ["note": "\(item.noteFrame.text!)", "board": "\(self.label.text!)", "x coordinate": "\(item.frame.minX)", "y coordinate": "\(item.frame.minY)"]
                    } else if item.imageFrame != nil {
                        if item.imageCache == "cacheForDelete" {
                            
                            imageUpdate = true
                            deleteFirebaseImage(link: item.imageLink)
                            
                            let refd = ref.childByAutoId()
                            let refdStore = String(describing: refd.key!)
                            let ided = UIDevice.current.identifierForVendor!.uuidString
                            let path = storageRef.child("\(ided)/\(refdStore)")
                            updatedImageProperties = ["image": "\(path)", "board": "\(self.label.text!)", "x coordinate": "\(item.frame.minX)", "y coordinate": "\(item.frame.minY)"]
                            item.imageLink = refdStore
                            item.imageCache = "cacheForUpload"
                        }
                    }
                    APIKeys.shared.theo.fetchNode(item.uniqueID, completionBlock: {(node, error) in
                        if item.specific == connect.end {
                            relateEnd = node
                        } else if item.specific == connect.end {
                            relateEnd = node
                        }
                        if noteUpdate {
                            APIKeys.shared.theo.updateNode(node!, properties: updatedNoteProperties, completionBlock: {(node, error) in
                                    semaphore2.signal()
                                })
                        } else if imageUpdate {
                            APIKeys.shared.theo.updateNode(node!, properties: updatedImageProperties, completionBlock: {(node, error) in
                                semaphore2.signal()
                            })
                        } else {
                            semaphore2.signal()
                        }
                    })
                } else {
                    // Neither fits into the connection-itemFrames correspondence or is an already used item/is a begin item
                    semaphore2.signal()
                }
                semaphore2.wait()
            }
            
            // Creating relationships can be run independently, at this point it has all info it needs
            if relateEnd != nil && relateOrigin != nil {
                relate.relate(relateOrigin, toNode: relateEnd, type: connect.connection)
                if ItemFrames.shared.downloadedConnections.count == 0 {
                    APIKeys.shared.theo.createRelationship(relate, completionBlock: {(node, error) in
                        print("createRelationship error: \(error)")
                    })
                } else {
                    if ItemFrames.shared.downloadedConnections.contains(where: {$0.connection == connect.connection && $0.end == "\(1*relateEnd.id)" && $0.origin == "\(1*relateOrigin.id)"}) == false {
                            APIKeys.shared.theo.createRelationship(relate, completionBlock: {(node, error) in
                                print("createRelationship error: \(error)")
                        })
                    }
                }
            } else {
                // No new nodes
            }
        }
        self.saveIndividuals()
    }
    
    // Uploads individual objects
    func saveIndividuals() {
        // Each object is confirmed to have a uniqueID by the time this runs, and the correct number is present
        let dispatchGroup = DispatchGroup()
        
        for item in ItemFrames.shared.frames {
            dispatchGroup.enter()
            
            if item.uniqueID == "" {
                var node = Node()
                if item.type == "note" {
                    let ided = UIDevice.current.identifierForVendor!.uuidString
                    node.setProp("note", propertyValue: "\(item.note)")
                    node.setProp("board", propertyValue: "\(self.label.text!)")
                    node.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                    node.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                    APIKeys.shared.theo.createNode(node, labels: ["\(ided)"], completionBlock: { (node, error) in
                        let rawID = node?.id
                        let intID = 1*rawID!
                        item.uniqueID = "\(intID)"
                        dispatchGroup.leave()
                    })
                } else if item.type == "image" {
                    let refd = self.ref.childByAutoId()
                    let refdStore = String(describing: refd.key!)
                    let ided = UIDevice.current.identifierForVendor!.uuidString
                    let path = self.storageRef.child("\(ided)/\(refdStore)")
                    node.setProp("image", propertyValue: "\(path)")
                    node.setProp("board", propertyValue: "\(self.label.text!)")
                    node.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                    node.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                    APIKeys.shared.theo.createNode(node, labels: ["\(ided)"], completionBlock: { (node, error) in
                        let rawID = node?.id
                        let intID = 1*rawID!
                        item.uniqueID = "\(intID)"
                        item.imageLink = "\(refdStore)"
                        item.imageCache = "cacheForUpload"
                        dispatchGroup.leave()
                    })
                }
            } else {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.uploadImages()
            self.updateConnections()
        }
    }
    
    // Updates new connections, arrived at by comparing with initial connections
    func updateConnections() {
        ItemFrames.shared.downloadedConnections.removeAll()
        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'})-[r]->(m:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'}) RETURN n, r, m"
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        
        APIKeys.shared.theo.executeTransaction(statements, completionBlock: { (response, error) in
            if error != nil {
                print("updateConnections() error: \(error)")
            } else {
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
                        let ratarray = rat["relationships"]! as! Array<AnyObject>
                        // This prints out all the relationships
                        for ratt in ratarray {
                            let connection = Connection()
                            let mirt = ratt as! Dictionary<String, AnyObject>
                            connection.end = mirt["endNode"] as! String
                            connection.origin = mirt["startNode"] as! String
                            connection.connection = mirt["type"] as! String
                            // Also check for same beginNode and endNode
                            if ItemFrames.shared.downloadedConnections.contains(where: {$0.connection == connection.connection && $0.end == connection.end && $0.origin == connection.origin}) == false {
                                ItemFrames.shared.downloadedConnections.append(connection)
                            }
                        }
                    }
                }
            }
        })
    }
    
    // Uploads images to Firebase Storage
    func uploadImages() {
        for item in ItemFrames.shared.frames {
            if item.type == "image" {
                if item.imageLink != nil {
                    if item.imageCache == "cacheForUpload" {
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        let localFile = UIImagePNGRepresentation(item.image)
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/png"
                        let path = self.storageRef.child("\(ided)/\(item.imageLink!)")
                        path.putData(localFile!, metadata: nil)
                        item.imageCache = ""
                        item.imageLink = "\(path)"
                    }
                }
            }
        }
        // Remove blurred effect
        let blurredEffectViews = self.view.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            let animation = AnimationType.from(direction: .right, offset: 0)
            blurView.animate(animations: [animation], initialAlpha: 0.8, finalAlpha: 0.0, delay: 0.0, duration: 1.5, completion: {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    blurView.removeFromSuperview()
                }
            })
        }
        self.activity.stopAnimating()
        safeDisable(wantToDisable: false)
    }
    
    // Loading animation for saving
    func loadAnimate() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        self.view.bringSubview(toFront: topView)
        self.view.bringSubview(toFront: bottomView)
        self.view.bringSubview(toFront: topBar)
        self.view.bringSubview(toFront: bottomBar)
        
        let frame = CGRect(x: self.view.frame.midX - 45, y: self.view.frame.midY - 45, width: 90, height: 90)
        activity = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: 12), color: .blue, padding: nil)
        self.view.addSubview(activity)
        if ItemFrames.shared.orientation != "" {
            ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: activity)
        }
        activity.startAnimating()
        safeDisable(wantToDisable: true)
    }
    
    // MARK: Safeguard functionalities
    
    // Disable sensitive buttons during loading/saving
    func safeDisable(wantToDisable value: Bool) {
        if value == true {
            backButton.isEnabled = false
            addSymbol.isEnabled = false
            endConnect.isEnabled = false
            saveButton.isEnabled = false
        } else {
            backButton.isEnabled = true
            addSymbol.isEnabled = true
            endConnect.isEnabled = true
            saveButton.isEnabled = true
        }
    }
    
    // Required for popover use
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc
    func back(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: textView delegate functions
    
    // Limits characters in note creation to 45, and displays cancel button if empty
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        print("newNum: \(newText.count)")
        ItemFrames.shared.updateTextFont(oneTextView: textView, fontSize: 17)
        if numberOfChars == 0 {
            addNoteButton.setTitle("Cancel", for: .normal)
        } else {
            addNoteButton.setTitle("Add Note", for: .normal)
        }
        return numberOfChars <= 75
    }
    
}
