//
//  DetailViewController.swift
//  Nexus
//
//  Created by Clifford Yin on 1/11/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import PanelKit
import ViewAnimator
import Theo
import Firebase
import FirebaseStorage
import FirebaseDatabase
import AlamofireImage
import Alamofire
import NVActivityIndicatorView

/* ViewController that presents the Nexus as a pin-board type view. */
class DetailViewController: UIViewController, UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate, ChooseAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DrawLineDelegate {
    
    var theo: RestClient!
    
    var name = ""
    
    var downloadItems = [DownloadItem]()
    
    var individualItems = [DownloadItem]()
    
    var imagePickerController: UIImagePickerController?
    
    var popoverViewController: AddType!
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    @IBOutlet weak var addSymbol: UIBarButtonItem!
    
    @IBOutlet weak var createNote: UIView!
    
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var topBar: UIToolbar!
    
    @IBOutlet weak var bottomBar: UIToolbar!
    
    @IBOutlet weak var customView: CustomView!
    
    @IBOutlet weak var newNoteLabel: UITextView!
    
    @IBOutlet weak var connectingBanner: UILabel!
    
    @IBOutlet weak var endConnect: UIBarButtonItem!
    
    let storageRef = Storage.storage().reference()
    var ref = Database.database().reference()
    
    var lineBegin = CGPoint(x: 30, y: 30)
    var lineEnd = CGPoint(x: 140, y: 140)
    
    var activity = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
    
    var imageToChange: CustomImage!
    
    func configureView() {
        // Update the user interface for the detail item.
        //titleView.frame = CGRect(x: titleView.frame.midX, y: titleView.frame.midY, width: 300, height: 20)
        //self.backButton.frame = CGRect(x: -20, y: 20, width: 40, height: 20)
        //self.navigationItem.title = detail.name
        //let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        // Have to learn safe areas
        
        
        //self.customView.loadneo4j()
        
        self.endConnect.isEnabled = false
        self.label.text = self.name
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(back(_:)))
        //navigationItem.leftBarButtonItem = backButton
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        self.titleView.animate(animations: [zoomAnimation], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: { })
        
        self.createNote.alpha = 0.0
        self.newNoteLabel.layer.borderWidth = 5.0
        self.newNoteLabel.layer.borderColor = UIColor.blue.cgColor
        /* Dragging image implementation */
    
        ///*
        self.connectTheo()
        //self.loadNexus()
        
        self.updateConnections()
        
        let halfSizeOfView = 25.0
//        let maxViews = 3
//        let insetSize = self.view.bounds.insetBy(dx: CGFloat(Int(2 * halfSizeOfView)), dy: CGFloat(Int(2 * halfSizeOfView))).size
        
        // Add the demo views
//        for _ in 0..<maxViews {
//            let pointX = CGFloat(UInt(arc4random() % UInt32(UInt(insetSize.width))))
//            let pointY = CGFloat(UInt(arc4random() % UInt32(UInt(insetSize.height))))
//            let framed = CGRect(x: pointX, y: pointY, width: 50, height: 50)
//            let newView = CustomImage(frame: framed)
//            ItemFrames.shared.frames.append(newView)
//            self.view.addSubview(newView)
//            newView.delegate = self
//            self.view.bringSubview(toFront: newView)
//        }
        
//        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//        self.navigationItem.leftItemsSupplementBackButton = true
//        let backButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(back(_:)))
//        backButton.tintColor = .blue
//        self.navigationItem.setLeftBarButton(backButton, animated: true)
//        let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
//        let zoomAnimation = AnimationType.zoom(scale: 0.2)
//        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
//        view.animate(animations: [rotateAnimation/*, zoomAnimation, rotateAnimation*/])
        self.view.bringSubview(toFront: topBar)
        self.view.bringSubview(toFront: bottomBar)
        
        
        
        /////////
        self.setUpOrientation()
    }
    
    @objc
    func back(_ sender: Any) {
        print("back")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func connectTheo() {
        
        ItemFrames.shared.frames.removeAll()
        ItemFrames.shared.connections.removeAll()
        
        self.theo = RestClient(baseURL: "https://hobby-nalpfmhdkkbegbkehohghgbl.dbs.graphenedb.com:24780", user: "general", pass: "b.ViGagdahQiVM.Uq0mEcCiZCl4Bc5W")
        
        activity = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        let frame = CGRect(x: self.view.frame.midX - 45, y: self.view.frame.midY - 45, width: 90, height: 90)
        activity = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: 9), color: .blue, padding: nil)
        self.view.addSubview(activity)
        if ItemFrames.shared.orientation != "" {
            ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: activity)
        }
        activity.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            print("loadNexus")
            self.loadNexus()
        }
    }
    
    // The new flow of downloading image data has an improvement over initial method, now tries to place and then load
    func loadNexus() {
        
        //let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: `\(self.name)`}) RETURN n"
        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'})-[r]->(m:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'}) RETURN n, r, m"
//        MATCH ({name : "A"})-[r]->({name : "B"})
//        RETURN r
        print("cypherQuery: \(cypherQuery)")
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        
        let dispatchGroup = DispatchGroup()
        
        ///* For some reason, loading nexus always fails on the first attempt. Maybe theo needs time to link through RestClient
        theo.executeTransaction(statements, completionBlock: { (response, error) in
//            for node in response {
            //responsecount = 2
            ///*
            if error != nil {
                // what if we try to load again in response to the error
                print("loadnexus error: \(error)")
            } else {
                print("response: \(response)")
            for respond in response {
                print("respond: \(respond.key)")
                }
            //if (response != nil) {
                // (key: NSObject, value: AnyObject) is a unit FOR A DICTIONARY
                print("results: \(response["results"]!)")
                let resultobject = response["results"]!
                let mirrorResult = Mirror(reflecting: resultobject)
                print("mirror: \(mirrorResult.subjectType)")
                let resulted = resultobject as! Array<AnyObject>
                print("resulted: \(resulted)")
            
                // Array
                for res in resulted {
                    print("res: \(res)")
                    let mirrorRes = Mirror(reflecting: res)
                    print("mirrorres: \(mirrorRes.subjectType)")
                    let resp = res as! Dictionary<String, AnyObject>
                    // Dictionary
                    print("resp[\"data\"]: \(resp["data"]!)")
                    let mirrordata = Mirror(reflecting: resp["data"]!)
                    print("mirrordata: \(mirrordata.subjectType)")
                    let reyd = resp["data"]! as! Array<AnyObject>
                    // Array
                    for reyd2 in reyd {
                        print("reyd2: \(reyd2)")
                        let mirrorreyd2 = Mirror(reflecting: reyd2)
                        print("mirrorreyd2: \(mirrorreyd2.subjectType)")
                        let reydd = reyd2 as! Dictionary<String, AnyObject>
                        print("reyddgraph: \(reydd["graph"]!)")
                        let mirrorgraph = Mirror(reflecting: reydd["graph"]!)
                        print("mirrorgraph: \(mirrorgraph.subjectType)")
                        let rat = reydd["graph"]! as! Dictionary<String, AnyObject>
                        print("ratnodes: \(rat["nodes"]!)")
                        let mirrort = Mirror(reflecting: rat["nodes"]!)
                        print("mirrorrt: \(mirrort.subjectType)")
                        let mirrortarray = rat["nodes"]! as! Array<AnyObject>
                        // These loop through the nodes
                        for rort in mirrortarray {
                            let download = DownloadItem()
                            // This is where you can extract the node id
                            print("rort: \(rort)")
                            let rortarray = rort as! Dictionary<String, AnyObject>
                            print("rortarray: \(rortarray)")
                            // Pull id and properties from this dictionary
                            print("rortid: \(rortarray["id"])")
                            download.uniqueID = rortarray["id"] as! String
                            
                            let rortprop = rortarray["properties"] as! Dictionary<String, AnyObject>
                            for ror in rortprop {
                                print("ror: \(ror)")
                                if (ror.key == "note") {
                                    print("note: \(ror.value as! String)")
                                    download.note = ror.value as! String
                                    ///// Works
                                    
                                } else if (ror.key == "image") {
                                    print("image: \(ror.value as! String)")
                                    download.imageRef = ror.value as! String
                                    download.image = UIImage(named: "Image Placeholder")
                                    
                                }
                                if (ror.key == "x coordinate") {
                                    print("x value")
                                    let xSub = ror.value as! String
                                    download.xCoord = (xSub as NSString).doubleValue
                                }
                                if (ror.key == "y coordinate") {
                                    print("y value")
                                    let ySub = ror.value as! String
                                    download.yCoord = (ySub as NSString).doubleValue
                                    if (self.downloadItems.contains(where: {$0.uniqueID == download.uniqueID}) == false) {
                                    
                                        self.downloadItems.append(download)
                                        
                                    }
                                }
                                // This is where you can extract the node information
                                // key - value, "note/image" -> value
                                print("downloadcount: \(self.downloadItems.count)")
            
                            }
                        }
                        print("ratrelations: \(rat["relationships"]!)")
                        let mirrorrat = Mirror(reflecting: rat["relationships"]!)
                        print("mirrorrat: \(mirrorrat.subjectType)")
                        let ratarray = rat["relationships"]! as! Array<AnyObject>
                        print("ratarray: \(ratarray)")
                        // This prints out all the relationships
                        for ratt in ratarray {
                            let connection = Connection()
                            print("ratt: \(ratt)")
                            let mirrat = Mirror(reflecting: ratt)
                            let mirt = ratt as! Dictionary<String, AnyObject>
                            print("endNode: \(mirt["endNode"]!)")
                            connection.end = mirt["endNode"] as! String
                            print("startNode: \(mirt["startNode"]!)")
                            connection.origin = mirt["startNode"] as! String
                            print("connection: \(mirt["type"]!)")
                            connection.connection = mirt["type"] as! String
                            
                            for loaded in self.downloadItems {
                                
                                dispatchGroup.enter()
                                
                                if (loaded.uniqueID == connection.origin) {
                                    print("woo")
                                    connection.begin = loaded
                                    connection.beginID = loaded.uniqueID
                                    
                                    if ((ItemFrames.shared.connections.contains(where: {($0.connection == connection.connection) && ($0.end == connection.end) && ($0.origin == connection.origin)}) == false)) {
                                        ItemFrames.shared.connections.append(connection)
                                        
                                        dispatchGroup.leave()
                                        
                                    } else {
                                        
                                        dispatchGroup.leave()
                                        
                                    }
                                } else if (loaded.uniqueID == connection.end) {
                                    print("wee")
                                    connection.finish = loaded
                                    connection.finishID = loaded.uniqueID
                                    if ((ItemFrames.shared.connections.contains(where: {($0.connection == connection.connection) && ($0.end == connection.end) && ($0.origin == connection.origin)}) == false)) {
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
            //}
            ///*
            }
        
        })
            
            // This is threading; returning to the main thread to update UI
            // DispatchQueue.main.async
            
            // put activity indicator and thread at top of function
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.loadIndividual()
//            self.loadBoard()
//            activity.stopAnimating()
            // MOVE THESE ABOVE TWO TO LOADINDIVIDUAL AND 
        }
        
        
    }
    
    func loadBoard() {
        
//        for item in downloadItems {
//            var obj = CustomImage()
//            if (item.imageRef != nil) {
//                let rect = CGRect(x: (item.xCoord)!, y: (item.yCoord)!, width: 50.0, height: 50.0)
//                obj = CustomImage(frame: rect)
//                obj.configureImage(setImage: (item.image)!)
//                obj.configureImage(setImage: item.image)
//                obj.imageLink = item.imageRef
//                obj.uniqueID = item.uniqueID
//                ItemFrames.shared.frames.append(obj)
//            } else if (item.note != nil) {
//                let rect = CGRect(x: (item.xCoord)!, y: (item.yCoord)!, width: 100.0, height: 100.0)
//                obj = CustomImage(frame: rect)
//                obj.configureNote(setNote: (item.note)!)
//                obj.uniqueID = item.uniqueID
//                ItemFrames.shared.frames.append(obj)
//            }
//
//        }
        self.draw(start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: 0.0))
        self.customView.loadFrames(sender: self)
    }
    
    // Prior was for connections, this one is for individual
    func loadIndividual() {
        
        let theo = RestClient(baseURL: "https://hobby-nalpfmhdkkbegbkehohghgbl.dbs.graphenedb.com:24780", user: "general", pass: "b.ViGagdahQiVM.Uq0mEcCiZCl4Bc5W")
        let cypherQuery2 = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'}) RETURN n"
        let resultDataContents2 = ["row", "graph"]
        let statement2 = ["statement" : cypherQuery2, "resultDataContents" : resultDataContents2] as [String : Any]
        let statements2 = [statement2]
        
        theo.executeTransaction(statements2, completionBlock: { (response, error) in
            ///*
            if error != nil {
                print("loadIndividual error: \(error)")
                self.customView.loadImages(sender: self)
                
                print("loadBoard with error")
                self.loadBoard()
                ///*
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    //self.updateConnections()
                }
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
                            let download = DownloadItem()
                            // This is where you can extract the node id
                            print("rort.2: \(rort)")
                            let rortarray = rort as! Dictionary<String, AnyObject>
                            print("rortarray.2: \(rortarray)")
                            // Pull id and properties from this dictionary
                            print("rortid.2: \(rortarray["id"])")
                            download.uniqueID = rortarray["id"] as! String
                            
                            let rortprop = rortarray["properties"] as! Dictionary<String, AnyObject>
                            for ror in rortprop {
                                print("ror.2: \(ror)")
                                if (ror.key == "note") {
                                    print("note: \(ror.value as! String)")
                                    download.note = ror.value as! String
                                    ///// Works
                                    
                                } else if (ror.key == "image") {
                                    print("image.2: \(ror.value as! String)")
                                    download.imageRef = ror.value as! String
                                    
                                }
                                //                            end.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                                //                            end.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                                if (ror.key == "x coordinate") {
                                    print("x value.2")
                                    let xSub = ror.value as! String
                                    download.xCoord = (xSub as NSString).doubleValue
                                }
                                if (ror.key == "y coordinate") {
                                    print("y value.2")
                                    let ySub = ror.value as! String
                                    download.yCoord = (ySub as NSString).doubleValue
                                    if (self.individualItems.contains(where: {$0.uniqueID == download.uniqueID}) == false) {
                                        
                                        self.individualItems.append(download)
                                        
                                    }
                                }
                                // This is where you can extract the node information
                                // key - value, "note/image" -> value
                                print("individualItems: \(self.individualItems.count)")
                                ///
                                for item in self.individualItems {
                                    print("individual")
                                    if (self.downloadItems.contains(where: {$0.uniqueID == item.uniqueID}) == false) {
                                        print("append individual")
                                        self.downloadItems.append(item)
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
                // Manually download the image for each image object
    //            for item in self.downloadItems {
    //                if (item.imageRef != nil) {
    //                    item.downloadImage(imageURL: item.imageRef)
    //                }
    //            }
                
                DispatchQueue.main.async {
                    print("DispatchQueue for images")
                    for item in self.downloadItems {
                        var obj = CustomImage()
                        if item.imageRef != nil {
                            let rect = CGRect(x: (item.xCoord)!, y: (item.yCoord)!, width: 50.0, height: 50.0)
                            obj = CustomImage(frame: rect)
                            obj.imageLink = item.imageRef
                            obj.uniqueID = item.uniqueID
                            obj.type = "image"
                            ItemFrames.shared.frames.append(obj)
                        } else if item.note != nil {
                            let rect = CGRect(x: (item.xCoord)!, y: (item.yCoord)!, width: 100.0, height: 100.0)
                            obj = CustomImage(frame: rect)
                            obj.configureNote(setNote: (item.note)!)
                            obj.uniqueID = item.uniqueID
                            obj.type = "note"
                            ItemFrames.shared.frames.append(obj)
                        }
                        print("ASSIGNING DOWNLOAD CUSTOMIMAGES HERE")
                        for connect in ItemFrames.shared.connections {
                            if obj.uniqueID == connect.beginID {
                                connect.downloadBegin = obj
                            } else if obj.uniqueID == connect.finishID {
                                connect.downloadFinish = obj
                            }
                        }
                        
                    }
                    
                    ///*
                    self.customView.loadImages(sender: self)
                    
                    print("loadBoard")
                    self.loadBoard()
                    //self.updateConnections()
                    self.activity.stopAnimating()
                    }
                    
                    
                    ///*
                    //DispatchQueue.main.async {
                    
                    //}
                    
                    
                }
              
        })
    }
    
    ///* On startup, loadNexus doesn't work but updateConnections does
    func updateConnections() {
        ItemFrames.shared.downloadedConnections.removeAll()
        
        let theo = RestClient(baseURL: "https://hobby-nalpfmhdkkbegbkehohghgbl.dbs.graphenedb.com:24780", user: "general", pass: "b.ViGagdahQiVM.Uq0mEcCiZCl4Bc5W")

        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'})-[r]->(m:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'}) RETURN n, r, m"
    
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        
        theo.executeTransaction(statements, completionBlock: { (response, error) in
            ///*
            if error != nil {
                print("updateconnections error: \(error)")
                //self.activity.stopAnimating()
            } else {
                let resultobject = response["results"]!
                let mirrorResult = Mirror(reflecting: resultobject)
                let resulted = resultobject as! Array<AnyObject>
                // Array
                for res in resulted {
                    let mirrorRes = Mirror(reflecting: res)
                    let resp = res as! Dictionary<String, AnyObject>
                    // Dictionary
                    let mirrordata = Mirror(reflecting: resp["data"]!)
                    let reyd = resp["data"]! as! Array<AnyObject>
                    print("connectreyd:\(reyd)")
                    // Array
                    for reyd2 in reyd {
                        let mirrorreyd2 = Mirror(reflecting: reyd2)
                        let reydd = reyd2 as! Dictionary<String, AnyObject>
                        let mirrorgraph = Mirror(reflecting: reydd["graph"]!)
                        let rat = reydd["graph"]! as! Dictionary<String, AnyObject>
                        let mirrort = Mirror(reflecting: rat["nodes"]!)
                        let mirrortarray = rat["nodes"]! as! Array<AnyObject>
                        let mirrorrat = Mirror(reflecting: rat["relationships"]!)
                        let ratarray = rat["relationships"]! as! Array<AnyObject>
                        print("connectratarray:\(ratarray)")
                        // This prints out all the relationships
                        for ratt in ratarray {
                            let connection = Connection()
                            let mirrat = Mirror(reflecting: ratt)
                            print("connectmirrat: \(mirrat)")
                            let mirt = ratt as! Dictionary<String, AnyObject>
                            connection.end = mirt["endNode"] as! String
                            connection.origin = mirt["startNode"] as! String
                            connection.connection = mirt["type"] as! String
                    
                            // Also check for same beginNode and endNode
                            if ((ItemFrames.shared.downloadedConnections.contains(where: {($0.connection == connection.connection) && ($0.end == connection.end) && ($0.origin == connection.origin)}) == false)) {
                                    ItemFrames.shared.downloadedConnections.append(connection)
                                }
                            }
                        }
                    }
                }
//            DispatchQueue.main.async {
//                self.activity.stopAnimating()
//            }
        })
    }
    
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//
//        print("orientation change")
//        //coordinator.isCancelled
//
//    }
    
//    override open var shouldAutorotate: Bool {
//        print("shouldAutoRotate")
//        return false
//    }
    
    func setUpOrientation() {
        print("setuporientation")
        print("current: \(ItemFrames.shared.orientation)")
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange,
                                              object: nil,
                                              queue: .main,
                                              using: didRotate)
    }
    
    ///* TODO: Try to put orientation listener in ItemFrames static instance, so it can detect between segues
    
    // This works for orientation
    var didRotate: (Notification) -> Void = { notification in
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            print("landscapeLeft")
                ItemFrames.shared.rotate(toOrientation: "toLeft")
        case .landscapeRight:
            print("landscapeRight")
                ItemFrames.shared.rotate(toOrientation: "toRight")
        case .portrait:
            if ItemFrames.shared.orientation == "left" {
                ItemFrames.shared.rotate(toOrientation: "backFromLeft")
            } else if ItemFrames.shared.orientation == "right" {
                ItemFrames.shared.rotate(toOrientation: "backFromRight")
            }
            print("Portrait")
        default:
            print("other")
        }
    }
    
    // Selecting which item to add 
    func chooseAdd(chosenAdd: String) {
        print(chosenAdd)
        if (chosenAdd == "Picture") {
            // Allows user to choose between photo library and camera
            let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .default) { (action) in
                self.showImagePickerController(sourceType: .photoLibrary)
            }
            
            alertController.addAction(photoLibraryAction)
            
            // Only show camera option if rear camera is available
            if (UIImagePickerController.isCameraDeviceAvailable(.rear)) {
                let cameraAction = UIAlertAction(title: "Photo from Camera", style: .default) { (action) in
                    self.showImagePickerController(sourceType: .camera)
                }
                alertController.addAction(cameraAction)
            }
            if (self.presentedViewController == nil) {
                print("1")
                present(alertController, animated: true, completion: nil)
            }
            else {
                print("2")
                self.dismiss(animated: true, completion: nil)
                present(alertController, animated: true, completion: nil)
            }
        } else if (chosenAdd == "Note") {
            self.createNote.alpha = 1.0
            if (self.presentedViewController == nil) {
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
                self.view.addSubview(newView!)
            }
            else {
                self.dismiss(animated: true, completion: nil)
                let newView = self.createNote
                newView?.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                UIView.animate(withDuration: 2.0,
                               delay: 0,
                               usingSpringWithDamping: CGFloat(0.9),
                               initialSpringVelocity: CGFloat(6.0),
                               options: UIViewAnimationOptions.allowUserInteraction,
                               animations: {
                                //self.createNote.alpha = 1.0
                                newView?.transform = CGAffineTransform.identity
                },
                               completion: { Void in()  }
                )
                self.view.addSubview(newView!)
            }
            
        } else if (chosenAdd == "Connection") {
            self.connectingBanner.text = "Connecting"
            ItemFrames.shared.connectingState = true
            ItemFrames.shared.positioning = false
            ItemFrames.shared.deleting = false
            self.connectingBanner.alpha = 1.0
            let animate = AnimationType.from(direction: .right, offset: 100)
            self.connectingBanner.animate(animations: [animate], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: nil)
            self.endConnect.title = "Done"
            self.endConnect.isEnabled = true
            ItemFrames.shared.sendNotesToBack()
        } else if (chosenAdd == "Re-position") {
            self.connectingBanner.text = "Re-positioning"
            ItemFrames.shared.connectingState = false
            ItemFrames.shared.editing = false
            ItemFrames.shared.deleting = false
            ItemFrames.shared.positioning = true
            self.connectingBanner.alpha = 1.0
            let animate = AnimationType.from(direction: .right, offset: 100)
            self.connectingBanner.animate(animations: [animate], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: nil)
            self.endConnect.title = "Done"
            self.endConnect.isEnabled = true
            ItemFrames.shared.sendNotesToBack()
        } else if (chosenAdd == "Edit") {
            self.connectingBanner.text = "Editing"
            ItemFrames.shared.connectingState = false
            ItemFrames.shared.positioning = false
            ItemFrames.shared.deleting = false
            self.connectingBanner.alpha = 1.0
            let animate = AnimationType.from(direction: .right, offset: 100)
            self.connectingBanner.animate(animations: [animate], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: nil)
            self.endConnect.title = "Done"
            self.endConnect.isEnabled = true
            ItemFrames.shared.bringNotesToFront()
            ///*
            ItemFrames.shared.makeImagesEditable()
        } else if (chosenAdd == "Delete") {
            self.connectingBanner.text = "Deleting"
            ItemFrames.shared.connectingState = false
            ItemFrames.shared.positioning = false
            ItemFrames.shared.editing = false
            ItemFrames.shared.deleting = true
            self.connectingBanner.alpha = 1.0
            let animate = AnimationType.from(direction: .right, offset: 100)
            self.connectingBanner.animate(animations: [animate], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: nil)
            self.endConnect.title = "Done"
            self.endConnect.isEnabled = true
            ItemFrames.shared.sendNotesToBack()
            ItemFrames.shared.setupDeleteMode()
        }
        
    }
    
    @IBAction func pressAdd(_ sender: Any) {
        print("pressAdd")
        popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "addType") as! AddType
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize(width:200, height:200)
        popoverViewController.delegate2 = self
        
        // Reference to it so it can rotate as well
        ItemFrames.shared.rotatingTypeMenu = popoverViewController
        
        let popoverPresentationViewController = popoverViewController.popoverPresentationController
        popoverPresentationViewController?.permittedArrowDirections = UIPopoverArrowDirection.down
        popoverPresentationViewController?.delegate = self
        //popoverPresentationViewController?.sourceView = self.add
        popoverPresentationViewController?.barButtonItem = self.addSymbol
        popoverPresentationViewController?.sourceRect = CGRect(x:0, y:0, width: addSymbol.width/2, height: 30)
        
        if ItemFrames.shared.orientation != "" {
            ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: popoverViewController.view)
        }
        
        present(popoverViewController, animated: true, completion: nil)
        
    }

    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        present(imagePickerController!, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let frame = CGRect(x: view.frame.midX - 25 , y: view.frame.midY - 25, width: 50, height: 50)
            if self.imageToChange == nil {
                let imageView = CustomImage(frame: frame)
            
                let size = CGSize(width: 250.0, height: 250.0)
                let imageScaled = pickedImage.af_imageScaled(to: size)
            
                imageView.configureImage(setImage: imageScaled)
                imageView.delegate = self
                ItemFrames.shared.frames.append(imageView)
                //imageView.frame = CGRect(x: view.center.x - 200/2 , y: view.center.y - 200/2, width: 200, height: 200)
                imageView.tag = 5
                view.addSubview(imageView)
            } else {
                ///*
                let size = CGSize(width: 250.0, height: 250.0)
                let imageScaled = pickedImage.af_imageScaled(to: size)
                
                self.imageToChange.configureImage(setImage: imageScaled)
                self.imageToChange.delegate = self
                self.imageToChange.imageCache = "cacheForDelete"
                self.imageToChange = nil
                
                //imageView.frame = CGRect(x: view.center.x - 200/2 , y: view.center.y - 200/2, width: 200, height: 200)
            }
            //let pressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DetailViewController.selectImage))
            //imageView.isUserInteractionEnabled = true
            //imageView.addGestureRecognizer(pressGestureRecognizer)
            
            //imageView.contentMode = .center
            // Scale it so it occupies less data in Firebase storage
            //let size2 = CGSize(width: 150.0, height: 150.0)
            //image = pickedImage.af_imageScaled(to: size2)
            //let size = CGSize(width: 125.0, height: 125.0)
            //imageView.image = pickedImage.af_imageScaled(to: size)
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    ///* TODO
    // - Disable anything that can mess with it during loading/saving
    // - Make it so that the labels/views/notes/images are presented in the right orientation when created
    func changeImage(custom: CustomImage) {
        
        self.imageToChange = custom
        self.chooseAdd(chosenAdd: "Picture")
        print("changeImage: \(self.imageToChange)")
    }
    
    func draw(start: CGPoint, end: CGPoint) {
        self.customView.refresh(begin: start, stop: end)
    }
    
    func delete(object: CustomImage) {
    
        var index = 0
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        
        // Now delete them online as well, dont forget to test the most complex
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
                    print("connectionsCount: \(ItemFrames.shared.connections)")
                    print("indexCount: \(index)")
                    
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
            deleteFirebaseImage(link: storagePath!)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            object.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            object.alpha = 0.0
        }, completion: {_ in
            object.removeFromSuperview()
        })
    
        self.draw(start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: 0.0))
        
        let theo = RestClient(baseURL: "https://hobby-nalpfmhdkkbegbkehohghgbl.dbs.graphenedb.com:24780", user: "general", pass: "b.ViGagdahQiVM.Uq0mEcCiZCl4Bc5W")
        
        //F5D8A989-C917-46F0-995E-F4B46F3BBE99
        //MATCH (p:`F5D8A989-C917-46F0-995E-F4B46F3BBE99` { board: 'anoher'}) where ID(p)=40 OPTIONAL MATCH (p)-[r]-() DELETE r,p
        let cypher = "MATCH (p:`\(UIDevice.current.identifierForVendor!.uuidString)` { board: '\(self.name)'}) where ID(p)=\(object.uniqueID) OPTIONAL MATCH (p)-[r]-() DELETE r,p"
        
        print("uuid: \(UIDevice.current.identifierForVendor!.uuidString)", "name: \(self.name)")
        
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypher, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        theo.executeTransaction(statements, completionBlock: { (response, error) in
            print("delete response: \(response), delete error: \(error)")
        })
    }
    
    func deleteFirebaseImage(link: String) {
        let storagePath = link
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: storagePath)
        
        storageRef.delete { error in
            if let error = error {
                print("delete image error: \(error)")
                // Uh-oh, an error occurred!
            } else {
                print("delete image success")
                // File deleted successfully
            }
        }
    }
    
    func placeLabel (object: CustomImage) {
        
        var connections = [Connection]()
        print("connectionscount: \(ItemFrames.shared.connections.count)")
        for connect in ItemFrames.shared.connections {
            //if object.uniqueID == "" {
            print("just created: \(object.specific), \(connect.origin), \(connect.end), \(connect.connection)")
            if object.specific == connect.origin || object.specific == connect.end || object.uniqueID == connect.beginID || object.uniqueID == connect.finishID {
                    connections.append(connect)
            }
            //}
//                else {
//
//                if  {
//                    connections.append(connect)
//                }
//            }
        }
        
        self.customView.loadLabelAfterRedraw(connections: connections)
    }
    
    //limit number of char in note text
    @IBAction func addNote(_ sender: Any) {
        
        if newNoteLabel.text?.trimmingCharacters(in: .whitespaces).isEmpty == false {
            print("Add note")
            let pointX = CGFloat(self.view.frame.midX - 25)
            let pointY = CGFloat(self.view.frame.midY - 25)
            let framed = CGRect(x: pointX, y: pointY, width: 100, height: 100)
            let newView = CustomImage(frame: framed)
            newView.configureNote(setNote: newNoteLabel.text!)
            ItemFrames.shared.frames.append(newView)
            print("phone orientation: \(ItemFrames.shared.orientation)")
            if ItemFrames.shared.orientation == "right" {
                newView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
            }
            if ItemFrames.shared.orientation == "left" {
                newView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
            }
            self.view.addSubview(newView)
            newView.delegate = self
            self.view.bringSubview(toFront: newView)
            self.newNoteLabel.endEditing(true)
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.createNote.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            }, completion: {_ in
                print("attempt transform complete")
                self.view.sendSubview(toBack: self.createNote)
                self.createNote.alpha = 0.0
                self.newNoteLabel.text = ""
            })
        } else {
            print("no text")
            // notify that there is no text
        }
        
    }
    
    @IBAction func endConnect(_ sender: Any) {
        print("endConnect")
        let animate = AnimationType.from(direction: .left, offset: 0)
        self.connectingBanner.animate(animations: [animate], initialAlpha: 1.0, finalAlpha: 0.0, delay: 0.0, duration: 1.0, completion: nil)
        self.endConnect.title = ""
        self.endConnect.isEnabled = false
        ItemFrames.shared.connectingState = false
        ItemFrames.shared.positioning = false
        ItemFrames.shared.sendNotesToBack()
        ItemFrames.shared.exitDeleteMode()
    }
    
    // Now there is a weird gs:\ folder being made sometimes
    // Sometimes creating nodes take so long that the create relation runs too fast. But that was only during slow internet.
    // For some reason, it sometimes just doesn't save some pics in Firebase when doing 3 or more connect. Only up to 2. But sometimes it JUST DOESNT WORK
    // Duplicates are happening again
    // Could this error be a part?  errors encountered while discovering extensions: Error Domain=PlugInKit Code=13 "query cancelled" UserInfo={NSLocalizedDescription=query cancelled}
    // Or maybe, you have to wait for 2018-05-30 23:35:55.859907-0700 Nexus[44248:5614171] TIC Read Status [9:0x0]: 1:57 to show
    // Later make it so that the arrow might to able to point to child?
    ///* Have node/connection values able to be updated
    @IBAction func save(_ sender: Any) {
        print("save")
        
        self.loadAnimate()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            self.saveNexus()
        })
        
    }
    
    func saveNexus() {
        let theo = RestClient(baseURL: "https://hobby-nalpfmhdkkbegbkehohghgbl.dbs.graphenedb.com:24780", user: "general", pass: "b.ViGagdahQiVM.Uq0mEcCiZCl4Bc5W")
        
        // Creates nodes and connections in database
        for connect in ItemFrames.shared.connections {
            
            print("connect: \(connect.connection)")
            var relate = Relationship()
            var relateOrigin: Node!
            var relateEnd: Node!
            
            for item in ItemFrames.shared.frames {
                print("item1")
             
                let semaphore = DispatchSemaphore(value: 0) // create a semaphore with a value 0. signal() will make the value 1.
                
                if item.specific == connect.origin && item.uniqueID == "" {
                    var origin = Node()
                    if (item.type == "note") {
                        print("note1")
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        origin.setProp("note", propertyValue: "\(item.note)")
                        origin.setProp("board", propertyValue: "\(self.label.text!)")
                        origin.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        origin.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        theo.createNode(origin, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateOrigin = node
                            print("note error: \(error)")
                            let rawID = node?.id
                            let intID = 1*rawID!
                            item.uniqueID = "\(intID)"
                            print("intID:\(item.uniqueID)")
                            
                            semaphore.signal() // once you make the signal(), then only next loop will get executed.
                        })
                    } else if item.type == "image" {
                        print("image1")
                        let image = item.image
                        let refd = ref.childByAutoId()
                        let refdStore = refd.key
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        let path = storageRef.child("\(ided)/\(refdStore)")
                        origin.setProp("image", propertyValue: "\(path)")
                        origin.setProp("board", propertyValue: "\(self.label.text!)")
                        origin.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        origin.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        theo.createNode(origin, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateOrigin = node
                            print("image error: \(error)")
                            let rawID = node?.id
                            let intID = 1*rawID!
                            item.uniqueID = "\(intID)"
                            print("intID:\(item.uniqueID)")
                            item.imageLink = "\(refdStore)"
                            
                            ///
                            item.imageCache = "cacheForUpload"
                            
                            semaphore.signal() // once you make the signal(), then only next loop will get executed.
                        })
                    }
                    
                } else if item.uniqueID != "" {
                    // Locate node with this uniqueID
                    // Assign as beginning of relation, but don't create
                    
                    // (item.uniqueID != "") is not being run
                    print("already ID1: \(item.uniqueID)")
                    
                    var noteUpdate = false
                    var imageUpdate = false
                    var updatedNoteProperties = ["":""]
                    var updatedImageProperties = ["":""]
                    
                    if item.noteFrame != nil {
                        
                        //if item.type == "note" {
                        noteUpdate = true
                        //}
                        
                        updatedNoteProperties = ["note": "\(item.noteFrame.text!)", "board": "\(self.label.text!)", "x coordinate": "\(item.frame.minX)", "y coordinate": "\(item.frame.minY)"]
                    } else if item.imageFrame != nil {
                        if item.imageCache == "cacheForDelete" {
            
                            imageUpdate = true
                            
                            deleteFirebaseImage(link: item.imageLink)
                            
                            let refd = ref.childByAutoId()
                            let refdStore = refd.key
                            let ided = UIDevice.current.identifierForVendor!.uuidString
                            let path = storageRef.child("\(ided)/\(refdStore)")
                            updatedImageProperties = ["image": "\(path)", "board": "\(self.label.text!)", "x coordinate": "\(item.frame.minX)", "y coordinate": "\(item.frame.minY)"]
                            item.imageLink = refdStore
                            item.imageCache = "cacheForUpload"
                        }
                    }
                    
//                    if item.noteFrame.text != "" {
//                        noteUpdate = true
//                    }
                    
                    ///* Now have a way to update/delete for images like notes
                    theo.fetchNode(item.uniqueID, completionBlock: {(node, error) in
                        print("id node: \(node)")
                        
                        if item.specific == connect.origin {
                            relateOrigin = node
                        } else if item.specific == connect.end {
                            relateEnd = node
                        }
                        
                        ///* The issue is that for "item.specific == connect.origin" it is matching the dated1970 ID's for only when connection was just created before saving
                        /////
                        print("item note: \(item.note)")
                        if noteUpdate {
                        
                            theo.updateNode(node!, properties: updatedNoteProperties, completionBlock: {(node, error) in
                                    print("updatenote 1 error: \(error)")
                                    semaphore.signal()
                                })
                            
                        } else if imageUpdate {
                            
                            theo.updateNode(node!, properties: updatedImageProperties, completionBlock: {(node, error) in
                                print("updateimage 1 error: \(error)")
                                semaphore.signal()
                            })
                            
                        } else {
                            print("not note or image update 1")
                            semaphore.signal()
                        }
                        /////
                        // once you make the signal(), then only next loop will get executed.
                    })
                // This is the right formatting because needs to check when new connection made with already-saved object
                } else {
                    // Neither fits into the connection-itemFrames correspondence or is an already used item/is an end item
                    print("neither1")
                    semaphore.signal()
                }

                semaphore.wait() // asking the semaphore to wait, till it gets the signal.
                
            }
            
            for item in ItemFrames.shared.frames {
                print("item2")

                let semaphore2 = DispatchSemaphore(value: 0) // create a semaphore with a value 0. signal() will make the value 1.
                
                if item.specific == connect.end && item.uniqueID == "" {
                    var end = Node()
                    if (item.type == "note") {
                        print("note2")
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        end.setProp("note", propertyValue: "\(item.note)")
                        end.setProp("board", propertyValue: "\(self.label.text!)")
                        end.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        end.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        theo.createNode(end, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateEnd = node
                            print("note error: \(error)")
                            let rawID = node?.id
                            let intID = 1*rawID!
                            item.uniqueID = "\(intID)"
                            print("intID:\(item.uniqueID)")
                            
                            semaphore2.signal() // once you make the signal(), then only next loop will get executed.
                        })
                    } else if (item.type == "image") {
                        print("image2")
                        let image = item.image
                        let refd = ref.childByAutoId()
                        let refdStore = refd.key
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        let path = storageRef.child("\(ided)/\(refdStore)")
                        end.setProp("image", propertyValue: "\(path)")
                        end.setProp("board", propertyValue: "\(self.label.text!)")
                        end.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        end.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        theo.createNode(end, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateEnd = node
                            print("image error: \(error)")
                            let rawID = node?.id
                            let intID = 1*rawID!
                            item.uniqueID = "\(intID)"
                            print("intID:\(item.uniqueID)")
                            item.imageLink = "\(refdStore)"
                            
                            ///
                            item.imageCache = "cacheForUpload"
                            
                            semaphore2.signal() // once you make the signal(), then only next loop will get executed.
                        })
                    }
                } else if item.uniqueID != "" {
                    // Locate node with this uniqueID
                    // Assign as beginning of relation, but don't create
                    print("already ID2: \(item.uniqueID)")
                    
                    var noteUpdate = false
                    var imageUpdate = false
                    var updatedNoteProperties = ["":""]
                    var updatedImageProperties = ["":""]
                    
                    if item.noteFrame != nil {
                        //if item.type == "note" {
                        noteUpdate = true
                        //}
                        updatedNoteProperties = ["note": "\(item.noteFrame.text!)", "board": "\(self.label.text!)", "x coordinate": "\(item.frame.minX)", "y coordinate": "\(item.frame.minY)"]
                    } else if item.imageFrame != nil {
                        if item.imageCache == "cacheForDelete" {
                            
                            imageUpdate = true
                            
                            deleteFirebaseImage(link: item.imageLink)
                            
                            let refd = ref.childByAutoId()
                            let refdStore = refd.key
                            let ided = UIDevice.current.identifierForVendor!.uuidString
                            let path = storageRef.child("\(ided)/\(refdStore)")
                            updatedImageProperties = ["image": "\(path)", "board": "\(self.label.text!)", "x coordinate": "\(item.frame.minX)", "y coordinate": "\(item.frame.minY)"]
                            item.imageLink = refdStore
                            item.imageCache = "cacheForUpload"
                        }
                    }
                    
                    //                    if item.noteFrame.text != "" {
                    //                        noteUpdate = true
                    //                    }
                
                    
                    theo.fetchNode(item.uniqueID, completionBlock: {(node, error) in
                        print("id node2: \(node)")
                        
                        if item.specific == connect.end {
                            relateEnd = node
                        } else if item.specific == connect.end {
                            relateEnd = node
                        }
                        
                        /////
                        if noteUpdate {
                            
                            theo.updateNode(node!, properties: updatedNoteProperties, completionBlock: {(node, error) in
                                    print("updatenote 2 error: \(error)")
                                    semaphore2.signal()
                                })
                            
                        } else if imageUpdate {
                            
                            theo.updateNode(node!, properties: updatedImageProperties, completionBlock: {(node, error) in
                                print("updateimage 2 error: \(error)")
                                semaphore2.signal()
                            })
                            
                        } else {
                            print("not note or image update 2")
                            semaphore2.signal()
                        }
                        /////
                        
                        // once you make the signal(), then only next loop will get executed.
                    })
                    
                } else {
                    // Neither fits into the connection-itemFrames correspondence or is an already used item/is a begin item
                    print("neither2")
                    semaphore2.signal()
                }
                
                semaphore2.wait() // asking the semaphore to wait, till it gets the signal.
            }
            
            // Error is that the the 7 second delay allows the correct relateBegin and relateEnds to be switched around, so semaphore.wait should already account for it here
            // CreateRelationship can be run independently, at this point it has every info it needs
            if ((relateEnd != nil) && (relateOrigin != nil)) {
                relate.relate(relateOrigin, toNode: relateEnd, type: connect.connection)
                print("connectID: \(connect.connection)")
                print("downloadconnect count: \(ItemFrames.shared.downloadedConnections.count)")
                if (ItemFrames.shared.downloadedConnections.count == 0) {
                    theo.createRelationship(relate, completionBlock: {(node, error) in
                        print("relate error: \(error)")
                    })
                } else {
                    
                    
                    if ((ItemFrames.shared.downloadedConnections.contains(where: {($0.connection == connect.connection) && ($0.end == "\(1*relateEnd.id)") && ($0.origin == "\(1*relateOrigin.id)")}) == false)) {
                            theo.createRelationship(relate, completionBlock: {(node, error) in
                                print("relate error: \(error)")
                        })
                    }
                }
                
            } else {
                ///////// use Whisper to show that internet is slow/down
                print("no new nodes")
            }
            
        }
        
        // Delay is needed here to run saveindividuals after nodes completed
        //let when = DispatchTime.now() + 5
        //DispatchQueue.main.asyncAfter(deadline: when) {
        
        self.saveIndividuals()
        
        //}
        
//        let when2 = DispatchTime.now() + 7
//        // This is where remove blur and quit NVActivity indicator was
////        DispatchQueue.main.asyncAfter(deadline: when2) {
////
////
////
////        }
//
//        DispatchQueue.main.asyncAfter(deadline: when2) {
//
//        }
    }
    
    func saveIndividuals() {
        print("save individuals")
        let theo = RestClient(baseURL: "https://hobby-nalpfmhdkkbegbkehohghgbl.dbs.graphenedb.com:24780", user: "general", pass: "b.ViGagdahQiVM.Uq0mEcCiZCl4Bc5W")
        // MultipleConnect: Each object is confirmed to have a uniqueID by the time this runs, and the correct number is present
        for item in ItemFrames.shared.frames {
            print("UNIQUEID: \(item.uniqueID)")
        }
        
        let dispatchGroup = DispatchGroup()
        
        for item in ItemFrames.shared.frames {
            
            dispatchGroup.enter()
            
            if item.uniqueID == "" {
                var node = Node()
                print("unique")
                if (item.type == "note") {
                    print("note")
                    let ided = UIDevice.current.identifierForVendor!.uuidString
                    node.setProp("note", propertyValue: "\(item.note)")
                    node.setProp("board", propertyValue: "\(self.label.text!)")
                    node.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                    node.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                    theo.createNode(node, labels: ["\(ided)"], completionBlock: { (node, error) in
                        print("note error: \(error)")
                        let rawID = node?.id
                        ///* For some reason this crashed as nil
                        let intID = 1*rawID!
                        print("indieID:\(intID)")
                        item.uniqueID = "\(intID)"
                        
                        dispatchGroup.leave()
                        
                    })
                } else if (item.type == "image") {
                    print("image")
                    let refd = self.ref.childByAutoId()
                    let refdStore = refd.key
                    let ided = UIDevice.current.identifierForVendor!.uuidString
                    let path = self.storageRef.child("\(ided)/\(refdStore)")
                    node.setProp("image", propertyValue: "\(path)")
                    node.setProp("board", propertyValue: "\(self.label.text!)")
                    node.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                    node.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                    theo.createNode(node, labels: ["\(ided)"], completionBlock: { (node, error) in
                        print("image error: \(error)")
                        let rawID = node?.id
                        let intID = 1*rawID!
                        item.uniqueID = "\(intID)"
                        print("indieID:\(intID)")
                        item.imageLink = "\(refdStore)"
                        
                        ///
                        item.imageCache = "cacheForUpload"
                        
                        dispatchGroup.leave()
                        
                    })
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            print("dispatchGroup.notify")
            self.uploadImages()
            self.updateConnections()
        }
        
    }
    
    func uploadImages() {
        // This works
        for item in ItemFrames.shared.frames {
            print("upload pics")
            if (item.type == "image") {
                if (item.imageLink != nil) {
                    if item.imageCache == "cacheForUpload" {
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        let localFile = UIImagePNGRepresentation(item.image)
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/png"
                        let path = self.storageRef.child("\(ided)/\(item.imageLink!)")
                        // gs: folder keeps being created
                        // maybe it's because it keeps uploading no matter what
                        // this is probably it
                        print("upload pic: \(path)")
                        path.putData(localFile!, metadata: nil)
                        item.imageCache = ""
                    }
                }
            }
        }
        
        //
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
    }
    
    func loadAnimate() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        self.view.bringSubview(toFront: topBar)
        self.view.bringSubview(toFront: bottomBar)
        
        let frame = CGRect(x: self.view.frame.midX - 45, y: self.view.frame.midY - 45, width: 90, height: 90)
        activity = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: 12), color: .blue, padding: nil)
        self.view.addSubview(activity)
        if ItemFrames.shared.orientation != "" {
            ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: activity)
        }
        activity.startAnimating()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
