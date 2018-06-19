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

    var imagePickerController: UIImagePickerController?
    
    var name = ""
    
    var downloadConnect = [Connection]()
    
    var downloadItems = [DownloadItem]()
    
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
        
        
        self.customView.loadneo4j()
        
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
        
        //////////////////////////
        self.loadNexus()
        
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
    }
    
    @objc
    func back(_ sender: Any) {
        print("back")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // When shifting vert/horizontal, just rotate image/note itself
    func loadNexus() {
        
        var activity = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        let frame = CGRect(x: self.view.frame.midX - 45, y: self.view.frame.midY - 45, width: 90, height: 90)
        activity = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: 9), color: .blue, padding: nil)
        self.view.addSubview(activity)
        activity.startAnimating()
        
        self.downloadConnect.removeAll()
        ItemFrames.shared.connections.removeAll()
        let theo = RestClient(baseURL: "https://hobby-nalpfmhdkkbegbkehohghgbl.dbs.graphenedb.com:24780", user: "general", pass: "b.ViGagdahQiVM.Uq0mEcCiZCl4Bc5W")
        //let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)`) RETURN n"
        let cypherQuery = "MATCH (n:`\(UIDevice.current.identifierForVendor!.uuidString)`)-[r]->(m:`\(UIDevice.current.identifierForVendor!.uuidString)`) RETURN n, r, m"
//        MATCH ({name : "A"})-[r]->({name : "B"})
//        RETURN r
        let cypherParams = ["label" : "\(UIDevice.current.identifierForVendor!.uuidString)"]
        // prints normal string
        //print("cypherParams: \(cypherParams)")
//        theo.executeCypher(cypherQuery, params: cypherParams, completionBlock: { (cypher, error) in
//            print("query cypher: \(cypher?.description)")
//        })
        
        let resultDataContents = ["row", "graph"]
        let statement = ["statement" : cypherQuery, "resultDataContents" : resultDataContents] as [String : Any]
        let statements = [statement]
        
        theo.executeTransaction(statements, completionBlock: { (response, error) in
//            for node in response {
            //responsecount = 2
                print("response: \(response)")
            for respond in response {
                print("respond: \(respond.key)")
                }
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
                        var download = DownloadItem()
                        // This is where you can extract the node id
                        print("rort: \(rort)")
                        let rortarray = rort as! Dictionary<String, AnyObject>
                        print("rortarray: \(rortarray)")
                        // Pull id and properties from this dictionary
                        print("rortid: \(rortarray["id"])")
                        download.uniqueID = rortarray["id"] as! String
                        
//                        let dummyNode = DownloadItem()
//                        dummyNode.id = rortarray["id"] as! String
//                        self.downloadItems.append(dummyNode)
                        
                        let rortprop = rortarray["properties"] as! Dictionary<String, AnyObject>
                        for ror in rortprop {
                            print("ror: \(ror)")
                            if (ror.key == "note") {
                                print("note: \(ror.value as! String)")
                                download.note = ror.value as! String
                                ///// Works
                                
                            } else if (ror.key == "image") {
                                print("image: \(ror.value as! String)")
                                download.downloadImage(imageURL: ror.value as! String)
                                
                            }
//                            end.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
//                            end.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
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
                            if (loaded.uniqueID == connection.origin) {
                                print("woo")
                                connection.begin = loaded
                                connection.beginID = loaded.uniqueID
                                if ((self.downloadConnect.contains(where: {$0.connection == connection.connection}) == false)) {
                                    self.downloadConnect.append(connection)
                                    ItemFrames.shared.connections.append(connection)
                                }
                            } else if (loaded.uniqueID == connection.end) {
                                print("wee")
                                connection.finish = loaded
                                connection.finishID = loaded.uniqueID
                                if ((self.downloadConnect.contains(where: {$0.connection == connection.connection}) == false)) {
                                    self.downloadConnect.append(connection)
                                    ItemFrames.shared.connections.append(connection)
                                }
                            }
                        }
                    }
                }
            }
//            let when = DispatchTime.now() + 2
//            DispatchQueue.main.asyncAfter(deadline: when) {
                //print("dispatch connect")
                for connect in self.downloadConnect {
                    print("downloadconnect: \(connect.beginID), \(connect.finishID), \(connect.connection)")
                }
            //}
            // This is threading; returning to the main thread to update UI
            // DispatchQueue.main.async
            
            // put activity indicator and thread at top of function
            let when = DispatchTime.now() + 4
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.loadBoard()
                activity.stopAnimating()
            }
        
        })
       
    }
    
    func loadBoard() {
        for item in downloadItems {
            var obj = CustomImage()
            if (item.image != nil) {
                let rect = CGRect(x: (item.xCoord)!, y: (item.yCoord)!, width: 50.0, height: 50.0)
                obj = CustomImage(frame: rect)
                obj.configureImage(setImage: (item.image)!)
                obj.uniqueID = item.uniqueID
                ItemFrames.shared.frames.append(obj)
            } else if (item.note != nil) {
                let rect = CGRect(x: (item.xCoord)!, y: (item.yCoord)!, width: 100.0, height: 100.0)
                obj = CustomImage(frame: rect)
                obj.configureNote(setNote: (item.note)!)
                obj.uniqueID = item.uniqueID
                ItemFrames.shared.frames.append(obj)
            }
            
        }
        self.draw(start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: 0.0))
        self.customView.loadFrames()
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
                present(alertController, animated: true, completion: nil)
            }
            else {
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
            self.connectingBanner.alpha = 1.0
            let animate = AnimationType.from(direction: .right, offset: 100)
            self.connectingBanner.animate(animations: [animate], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 1.0, completion: nil)
            self.endConnect.title = "Done"
            self.endConnect.isEnabled = true
            ItemFrames.shared.bringNotesToFront()
        }
        
    }
    
    @IBAction func pressAdd(_ sender: Any) {
        print("pressAdd")
        let popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "addType") as! AddType
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize(width:300, height:150)
        popoverViewController.delegate2 = self
        
        let popoverPresentationViewController = popoverViewController.popoverPresentationController
        popoverPresentationViewController?.permittedArrowDirections = UIPopoverArrowDirection.down
        popoverPresentationViewController?.delegate = self
        //popoverPresentationViewController?.sourceView = self.add
        popoverPresentationViewController?.barButtonItem = self.addSymbol
        popoverPresentationViewController?.sourceRect = CGRect(x:0, y:0, width: addSymbol.width/2, height: 30)
        
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
            let imageView = CustomImage(frame: frame)
            
            let size = CGSize(width: 250.0, height: 250.0)
            let imageScaled = pickedImage.af_imageScaled(to: size)
            
            imageView.configureImage(setImage: imageScaled)
            imageView.delegate = self
            ItemFrames.shared.frames.append(imageView)
            //imageView.frame = CGRect(x: view.center.x - 200/2 , y: view.center.y - 200/2, width: 200, height: 200)
            imageView.tag = 5
            view.addSubview(imageView)
            print("testtag: \(imageView.tag)")
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
    
    
    func draw(start: CGPoint, end: CGPoint) {
        self.customView.refresh(begin: start, stop: end)
    }
    
    @objc
    func selectImage(_ sender: Any) {
        
    }
    
    //limit number of char in note text
    // make it work only when text isn't blank
    @IBAction func addNote(_ sender: Any) {
        
        if ((newNoteLabel.text?.trimmingCharacters(in: .whitespaces).isEmpty) == false) {
            print("Add note")
            let pointX = CGFloat(self.view.frame.midX - 25)
            let pointY = CGFloat(self.view.frame.midY - 25)
            let framed = CGRect(x: pointX, y: pointY, width: 100, height: 100)
            let newView = CustomImage(frame: framed)
            newView.configureNote(setNote: newNoteLabel.text!)
            ItemFrames.shared.frames.append(newView)
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
    }
    
    // Sometimes creating nodes take so long that the create relation runs too fast. But that was only during slow internet.
    // For some reason, it sometimes just doesn't save some pics in Firebase when doing 3 or more connect. Only up to 2. But sometimes it JUST DOESNT WORK
    // Could this error be a part?  errors encountered while discovering extensions: Error Domain=PlugInKit Code=13 "query cancelled" UserInfo={NSLocalizedDescription=query cancelled}
    // Or maybe, you have to wait for 2018-05-30 23:35:55.859907-0700 Nexus[44248:5614171] TIC Read Status [9:0x0]: 1:57 to show
    // Later make it so that the arrow might to able to point to child?
    @IBAction func save(_ sender: Any) {
        print("save")
        let theo = RestClient(baseURL: "https://hobby-nalpfmhdkkbegbkehohghgbl.dbs.graphenedb.com:24780", user: "general", pass: "b.ViGagdahQiVM.Uq0mEcCiZCl4Bc5W")
        
        // Will only work if there are connections present
        for connect in ItemFrames.shared.connections {
            
            var relate = Relationship()
            var relateOrigin: Node!
            var relateEnd: Node!
            
            /////////// Fix this, it runs twice because of going over connections twice
            for item in ItemFrames.shared.frames {
                if (item.specific == connect.origin) {
                    var origin = Node()
                    if (item.type == "note") {
                        
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        origin.setProp("note", propertyValue: "\(item.note)")
                        origin.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        origin.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        theo.createNode(origin, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateOrigin = node
                            print("note error: \(error)")
                        })
                    }
                    if (item.type == "image") {
                        
                        let image = item.image
                        let refd = ref.childByAutoId()
                        let refdStore = refd.key
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        let path = storageRef.child("\(ided)/\(refdStore)")
                        let localFile = UIImagePNGRepresentation(image!)
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/png"
//                        let when = DispatchTime.now() + 2
//                        DispatchQueue.main.asyncAfter(deadline: when) {
                            path.putData(localFile!, metadata: nil)
                        //}
                        origin.setProp("image", propertyValue: "\(path)")
                        origin.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        origin.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        theo.createNode(origin, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateOrigin = node
                            print("image error: \(error)")
                        })
                    }
                    
                }
            }
            
            for item in ItemFrames.shared.frames {
                if (item.specific == connect.end) {
                    var end = Node()
                    if (item.type == "note") {
                        
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        end.setProp("note", propertyValue: "\(item.note)")
                        end.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        end.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        theo.createNode(end, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateEnd = node
                            print("note error: \(error)")
                        })
                    }
                    if (item.type == "image") {
                        
                        let image = item.image
                        let refd = ref.childByAutoId()
                        let refdStore = refd.key
                        let ided = UIDevice.current.identifierForVendor!.uuidString
                        let path = storageRef.child("\(ided)/\(refdStore)")
                        let localFile = UIImagePNGRepresentation(image!)
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/png"
//                        let when = DispatchTime.now() + 2
//                        DispatchQueue.main.asyncAfter(deadline: when) {
                            path.putData(localFile!, metadata: nil)
                        //}
                        end.setProp("image", propertyValue: "\(path)")
                        end.setProp("x coordinate", propertyValue: "\(item.frame.minX)")
                        end.setProp("y coordinate", propertyValue: "\(item.frame.minY)")
                        theo.createNode(end, labels: ["\(ided)"], completionBlock: { (node, error) in
                            relateEnd = node
                            print("image error: \(error)")
                        })
                    }
                    
                }
            }
            
            let when = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: when) {
                if ((relateEnd != nil) && (relateOrigin != nil)) {
                relate.relate(relateOrigin, toNode: relateEnd, type: connect.connection)
                theo.createRelationship(relate, completionBlock: {(node, error) in
                    print("relate error: \(error)")
                    })
                } else {
                    ///////// use Whisper to show that internet is slow/down
                }
            }
            
        }
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
