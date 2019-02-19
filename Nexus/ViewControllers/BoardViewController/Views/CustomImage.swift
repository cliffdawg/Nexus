//
//  CustomImage.swift
//  Nexus
//
//  Created by Clifford Yin on 1/22/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import ViewAnimator
import TinyConstraints
import FirebaseStorage

protocol DrawLineDelegate {
    func draw(start: CGPoint, end: CGPoint)
    func delete(object: CustomImage)
    func placeLabel(object: CustomImage)
    func changeImage(custom: CustomImage)
}

extension UIView {
    // Provides a drop shadow
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 2)
        layer.shadowRadius = 1
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}

/* Custom view that can represent a note or picture. Can be interacted with, repositioned, connected, and is touch/pan/press-enabled. */
class CustomImage: UIView {
    
    let border = 15
    var id = UIDevice.current.identifierForVendor?.uuidString
    
    // Tracks last location of currently selected item
    var lastLocation = CGPoint(x: 0, y: 0)
    // Tracks unique objects
    var uniqueID = ""
    // Local ID when created used as a unique identifier
    var specific = ""
    // Whether this is a note or image
    var type = ""
    var note = ""
    // For determining whether or not image has been uploaded
    var imageCache = ""
    // Whether the user is currently trying to create a connection
    var connecting = false
    // Whether the objects are overlayed with red signifier borders
    var bordering = false
    
    var delegate: DrawLineDelegate!
    var image: UIImage!
    var imageLink: String!
    var imageFrame: UIImageView!
    var noteFrame: UITextView!
    
    // MARK: Lifecycle functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(CustomImage.detectPan(_:)))
        let pressRecognizer = UILongPressGestureRecognizer(target:self, action:#selector(CustomImage.detectPress(_:)))
        self.gestureRecognizers = [panRecognizer, pressRecognizer]
        
        let placeholder = UIImage(named: "Image Placeholder")!
        let imageView = UIImageView(image: placeholder)
        self.addSubview(imageView)
        imageView.edgesToSuperview()
        self.layer.borderColor = UIColor(rgb: 0x34E5FF).cgColor
        self.dropShadow()
        
        self.specific = String(Date().timeIntervalSince1970)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.noteFrame != nil {
            noteFrame.centerVertically()
        }
    }
    
    // Brings object to front when pressed
    override func touchesBegan(_ touches: (Set<UITouch>!), with event: UIEvent!) {
        UserDefaults.standard.set(nil, forKey: "changingImage")
        if (self.connecting == false) {
            // Promote the touched view
            self.superview?.bringSubview(toFront: self)
            // Remember original location
            lastLocation = self.center
        } else {
            let touch = touches?.first!
            lastLocation = (touch?.location(in: self.superview))!
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initialization functions
    
    // Generate qualities of an image
    func configureImage(setImage: UIImage) {
        self.type = "image"
        self.image = setImage
        let imageView = UIImageView(image: setImage)
        imageView.frame = CGRect(x: 0, y: 0, width: ItemFrames.shared.imageDimension, height: ItemFrames.shared.imageDimension)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5.0
        self.imageFrame = imageView
        self.addSubview(imageView)
    }
    
    // Generate qualities of a note
    func configureNote(setNote: String) {
        self.type = "note"
        var noteView = UITextView()
        noteView.text = setNote
        let heighted = ItemFrames.shared.noteDimension
        let widthed = ItemFrames.shared.noteDimension
        let framed = CGRect(x: 0, y: 0, width: widthed, height: heighted)
        noteView = CenteredTextView(frame: framed)
        self.note = setNote
        noteView.text = setNote
        noteView.font = UIFont(name: "Futura", size: 17)
        
        // Set auto-correction options
        noteView.autocapitalizationType = .none
        noteView.autocorrectionType = .no
        noteView.spellCheckingType = .no
        if #available(iOS 11.0, *) {
            noteView.smartDashesType = .no
            noteView.smartInsertDeleteType = .no
            noteView.smartQuotesType = .no
        } else {
            // Fallback on earlier versions
        }
        
        noteView.backgroundColor = UIColor(rgb: 0x007AFF)
        noteView.textColor = UIColor.white
        noteView.layer.cornerRadius = 5.0
        noteView.textAlignment = .center
        noteView.centerVertically()
        self.noteFrame = noteView
        self.addSubview(noteView)
        noteView.isUserInteractionEnabled = false
    }
    
    // Download the image from Firebase Storage
    func loadImage() {
        let gsReference = Storage.storage().reference(forURL: imageLink)
        gsReference.getData(maxSize: 1 * 2048 * 2048) { data, error in
            if error != nil {
                print("Load image error: \(error)")
            } else {
                // Convert data to image
                var imaged = UIImage(data: data!)!
                let trueImage = self.resizeImage(image: imaged, newWidth: CGFloat(ItemFrames.shared.imageDimension)) as! UIImage
                self.configureImage(setImage: trueImage)
            }
        }
    }
    
    // Scale the image if needed
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // MARK: Gesture implementations
    
    @objc
    func detectPan(_ recognizer: UIPanGestureRecognizer) {
        
        // When re-positioning an object
        if (connecting == false && ItemFrames.shared.editing == false) && (ItemFrames.shared.positioning == true) {
            
            let translation = recognizer.translation(in: self.superview)
            self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
            self.delegate.draw(start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: 0.0))
            
        } else if (connecting == true) && (ItemFrames.shared.editing == false) {
            
            // When drawing a connection
            let translation = recognizer.translation(in: self.superview)
            let start = CGPoint(x: lastLocation.x, y: lastLocation.y)
            let end = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
            self.delegate.draw(start: start, end: end)
            
        }
        
        if recognizer.state == .ended {
            // Re-positions labels for connections with them
            if (connecting == false) && (ItemFrames.shared.editing == false) && (ItemFrames.shared.positioning == true) {
                self.delegate.placeLabel(object: self)
            }
            // Ends the process of connecting
            if (self.connecting == true) {
                let starting = CGPoint(x: 0.0, y: 0.0)
                let ending = CGPoint(x: 0.0, y: 0.0)
                self.delegate.draw(start: starting, end: ending)
            }
            self.connecting = false
        }
    }
    
    // For long presses while connecting, and while editing
    @objc
    func detectPress(_ recognizer: UILongPressGestureRecognizer) {
        
        if (self.connecting == false) && (ItemFrames.shared.connectingState == true) {
            
            let tintRect = CGRect(x: -(border/2), y: -(border/2), width: Int.init(self.frame.width) + border, height: Int.init(self.frame.height) + border)
            let tintView = UIView(frame: tintRect)
            tintView.backgroundColor = .red
            tintView.layer.cornerRadius = 10.0
            self.addSubview(tintView)
            self.bringSubview(toFront: tintView)
            let zoomAnimation = AnimationType.zoom(scale: 0.2)
            tintView.animate(animations: [zoomAnimation], initialAlpha: 0.0, finalAlpha: 0.5, delay: 0.0, duration: 0.3, completion: { })
            self.connecting = true
            self.bordering = true
            ItemFrames.shared.removeOtherHighlights(object: self)
            
        } else {
            // Is not in connecting mode and if it is in editing mode
            if ItemFrames.shared.editing == true {
                if type == "image" {
                    if UserDefaults.standard.string(forKey: "changingImage") == nil {
                        UserDefaults.standard.set("changing", forKey: "changingImage")
                        delegate.changeImage(custom: self)
                    }
                }
            }
        }
    }
    
    // MARK: UI and UX functions
    
    func borderView() {
        let tintRect = CGRect(x: -(border/2), y: -(border/2), width: Int.init(self.frame.width) + border, height: Int.init(self.frame.height) + border)
        let tintView = UIView(frame: tintRect)
        tintView.backgroundColor = .red
        tintView.layer.cornerRadius = 10.0
        self.addSubview(tintView)
        self.bringSubview(toFront: tintView)
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        //let rotateAnimation = AnimationType.rotate(angle: 3.14/2)
        tintView.animate(animations: [zoomAnimation], initialAlpha: 0.0, finalAlpha: 0.5, delay: 0.0, duration: 0.3, completion: { })
        self.bordering = true
    }
    
    func setupDelete() {
        let rect = CGRect(x: -10.0, y: -10.0, width: 25, height: 25)
        let button = UIButton(frame: rect)
        let stencil = UIImage(named: "X")!.withRenderingMode(.alwaysTemplate)
        button.setImage(stencil, for: .normal)
        button.tintColor = .red
        button.addTarget(self, action: #selector(deleteNode(_:)), for: .touchUpInside)
        self.addSubview(button)
        self.bringSubview(toFront: button)
        let zoomAnimation = AnimationType.zoom(scale: 0.5)
        button.animate(animations: [zoomAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { })
    }
    
    @objc
    func deleteNode(_ sender: Any) {
        self.delegate.delete(object: self)
    }
    
}
