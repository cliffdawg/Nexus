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

protocol DrawLineDelegate {
    func draw(start: CGPoint, end: CGPoint)
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
    
    var image: UIImage!
    
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
    
    func configureImage(setImage: UIImage) {
        self.type = "image"
        self.image = setImage
        //let image = UIImage(named: "Image Placeholder")!
        let imageView = UIImageView(image: setImage)
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.imageFrame = imageView
        self.addSubview(imageView)
    }
    
    // pressing on note doesn't allow touch to be detected
    func configureNote(setNote: String) {
        
        self.type = "note"
        
        //let framed = CGRect(x: 0, y: 0, width: 50, height: 50)
        var noteView = UITextView()
        noteView.text = setNote
        let heighted = 100
        let widthed = 100
        print("heighted: \(heighted)")
        print("widthed: \(widthed)")
        let framed = CGRect(x: 0, y: 0, width: widthed, height: heighted)
        noteView = CenteredTextView(frame: framed)
        self.note = setNote
        noteView.text = setNote
        noteView.textAlignment = .center
        noteView.layer.borderWidth = 5
        noteView.layer.borderColor = UIColor.green.cgColor
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
            let translation  = recognizer.translation(in: self.superview)
            self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
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
        }
    }
    
    // only for initial
    override func touchesBegan(_ touches: (Set<UITouch>!), with event: UIEvent!) {
        // Promote the touched view
        self.superview?.bringSubview(toFront: self)
        print("Touches begin")
        // Remember original location
        lastLocation = self.center
        
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
    
}
