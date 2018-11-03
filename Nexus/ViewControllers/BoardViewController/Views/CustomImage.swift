//
//  Image.swift
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
    var lastLocation = CGPoint(x: 0, y: 0)
    
    var connecting = false
    let border = 15
    var bordering = false
    
    var id = UIDevice.current.identifierForVendor?.uuidString
    var uniqueID = ""
    
    var delegate: DrawLineDelegate!
    
    var type = ""
    
    var note = ""
    
    var specific = ""
    
    // For determining whether or not image has been uploaded
    var imageCache = ""
    
    var image: UIImage!
    var imageLink: String!
    
    var imageFrame: UIImageView!
    var noteFrame: UITextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(CustomImage.detectPan(_:)))
        let pressRecognizer = UILongPressGestureRecognizer(target:self, action:#selector(CustomImage.detectPress(_:)))
        self.gestureRecognizers = [panRecognizer, pressRecognizer]
        
        //randomize view color
        let blueValue = CGFloat(Int(arc4random() % 255)) / 255.0
        let greenValue = CGFloat(Int(arc4random() % 255)) / 255.0
        let redValue = CGFloat(Int(arc4random() % 255)) / 255.0
        
        self.backgroundColor = UIColor(red:redValue, green: greenValue, blue: blueValue, alpha: 1.0)
        self.specific = String(Date().timeIntervalSince1970)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.noteFrame != nil {
            noteFrame.centerVertically()
        }
    }
    
    func configureImage(setImage: UIImage) {
        self.type = "image"
        self.image = setImage
        //let image = UIImage(named: "Image Placeholder")!
        let imageView = UIImageView(image: setImage)
        imageView.frame = CGRect(x: 0, y: 0, width: ItemFrames.shared.imageDimension, height: ItemFrames.shared.imageDimension)
        self.imageFrame = imageView
        self.addSubview(imageView)
    }
    
    func loadImage() {
        let gsReference = Storage.storage().reference(forURL: imageLink)
        gsReference.getData(maxSize: 1 * 2048 * 2048) { data, error in
            if error != nil {
                print("error: \(error)")
            } else {
                print("downloadImage")
                var imaged = UIImage(data: data!)! // Convert image to data
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
    
    // pressing on note doesn't allow touch to be detected
    func configureNote(setNote: String) {
        
        self.type = "note"
        
        var noteView = UITextView()
        noteView.text = setNote
        let heighted = ItemFrames.shared.noteDimension
        let widthed = ItemFrames.shared.noteDimension
        print("heighted: \(heighted)")
        print("widthed: \(widthed)")
        let framed = CGRect(x: 0, y: 0, width: widthed, height: heighted)
        noteView = CenteredTextView(frame: framed)
        self.note = setNote
        noteView.text = setNote
        noteView.textAlignment = .center
        noteView.layer.borderWidth = 5
        noteView.layer.borderColor = UIColor.green.cgColor
        noteView.centerVertically()
        self.noteFrame = noteView
        self.addSubview(noteView)
        
        noteView.isUserInteractionEnabled = false
        
//        let overView = UIView()
//        self.addSubview(overView)
//        overView.edges(to: noteView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func detectPan(_ recognizer: UIPanGestureRecognizer) {
        
        if ((connecting == false) && (ItemFrames.shared.editing == false) && (ItemFrames.shared.positioning == true)) {
            let translation = recognizer.translation(in: self.superview)
            self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
            self.delegate.draw(start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: 0.0))
            
        } else if ((connecting == true) && (ItemFrames.shared.editing == false)) {
            
            let translation = recognizer.translation(in: self.superview)
            let start = CGPoint(x: lastLocation.x, y: lastLocation.y)
            let end = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
            self.delegate.draw(start: start, end: end)
        }
        
        // pan ended works
        // order matters
        if (recognizer.state == .ended) {
            print("pan ended")
            //////////////////////
            if ((connecting == false) && (ItemFrames.shared.editing == false) && (ItemFrames.shared.positioning == true)) {
                // For moving the label, we can either track it (might get complicated) or just refresh the one moved at the end of re-position
                self.delegate.placeLabel(object: self)
            }
            if (self.connecting == true) {
                let starting = CGPoint(x: 0.0, y: 0.0)
                let ending = CGPoint(x: 0.0, y: 0.0)
                self.delegate.draw(start: starting, end: ending)
            }
            self.connecting = false
        }
    }
    
    @objc
    func detectPress(_ recognizer: UILongPressGestureRecognizer) {
        
        if ((self.connecting == false) && (ItemFrames.shared.connectingState == true)) {
            let tintRect = CGRect(x: -(border/2), y: -(border/2), width: Int.init(self.frame.width) + border, height: Int.init(self.frame.height) + border)
            let tintView = UIView(frame: tintRect)
            tintView.backgroundColor = .red
            tintView.layer.cornerRadius = 10.0
            self.addSubview(tintView)
            self.bringSubview(toFront: tintView)
            let zoomAnimation = AnimationType.zoom(scale: 0.2)
            //let rotateAnimation = AnimationType.rotate(angle: 3.14/2)
            tintView.animate(animations: [zoomAnimation], initialAlpha: 0.0, finalAlpha: 0.5, delay: 0.0, duration: 0.3, completion: { })
            self.connecting = true
            self.bordering = true
            ItemFrames.shared.removeOtherHighlights(object: self)
        } else {
            print("connectingState is false")
            // notify not connecting
            if ItemFrames.shared.editing == true {
                if type == "image" {
                    if UserDefaults.standard.string(forKey: "changingImage") == nil {
                        print("changing image")
                        UserDefaults.standard.set("changing", forKey: "changingImage")
                        delegate.changeImage(custom: self)
                    }
                }
            }
        }
    }
    
    // only for initial
    override func touchesBegan(_ touches: (Set<UITouch>!), with event: UIEvent!) {
        UserDefaults.standard.set(nil, forKey: "changingImage")
        if (self.connecting == false) {
        // Promote the touched view
        self.superview?.bringSubview(toFront: self)
        print("Touches begin")
        // Remember original location
        lastLocation = self.center
        } else {
        let touch = touches.first!
        lastLocation = touch.location(in: self.superview)
        }
    }
    
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
        //self.connecting = true
        self.bordering = true
    }
    
    func setupDelete() {
        let rect = CGRect(x: -10.0, y: -10.0, width: 25, height: 25)
        let button = UIButton(frame: rect)
        button.setTitle("X", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(deleteNode(_:)), for: .touchUpInside)
        self.addSubview(button)
        self.bringSubview(toFront: button)
        let zoomAnimation = AnimationType.zoom(scale: 0.5)
        button.animate(animations: [zoomAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { })
        
    }
    
    @objc
    func deleteNode(_ sender: Any) {
        
        print("deleteNode")

        self.delegate.delete(object: self)
        
        if (self.uniqueID != "") {
            
        }
        
    }
    
}
