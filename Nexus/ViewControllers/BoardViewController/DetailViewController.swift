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

/* ViewController that presents the Nexus as a pin-board type view. */
class DetailViewController: UIViewController, UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate, ChooseAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DrawLineDelegate {

    var imagePickerController: UIImagePickerController?
    
    var name = ""
    
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
        
        let halfSizeOfView = 25.0
        let maxViews = 3
        let insetSize = self.view.bounds.insetBy(dx: CGFloat(Int(2 * halfSizeOfView)), dy: CGFloat(Int(2 * halfSizeOfView))).size
        
        // Add the Views
        for _ in 0..<maxViews {
            let pointX = CGFloat(UInt(arc4random() % UInt32(UInt(insetSize.width))))
            let pointY = CGFloat(UInt(arc4random() % UInt32(UInt(insetSize.height))))
            let framed = CGRect(x: pointX, y: pointY, width: 50, height: 50)
            let newView = CustomImage(frame: framed)
            ItemFrames.shared.frames.append(newView)
            self.view.addSubview(newView)
            newView.delegate = self
            self.view.bringSubview(toFront: newView)
        }
        
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
            imageView.configureImage(setImage: pickedImage)
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
    //        let fadeAnimation = AnimationType.from(direction: .right, offset: 0)
    //        self.createNote.animate(animations: [fadeAnimation], initialAlpha: 1.0, finalAlpha: 0.0, delay: 0.0, duration: 1.0, completion: {
    //            self.view.sendSubview(toBack: self.createNote)
    //        })
        
            //createNote.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.createNote.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            }, completion: {_ in
                print("attempt transform complete")
                self.view.sendSubview(toBack: self.createNote)
                self.createNote.alpha = 0.0
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
    
    @IBAction func save(_ sender: Any) {
        
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
