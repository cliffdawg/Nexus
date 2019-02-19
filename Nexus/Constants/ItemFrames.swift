//
//  ItemFrames.swift
//  Nexus
//
//  Created by Clifford Yin on 4/7/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import ViewAnimator

/* Static class that stores all the active items in a detail controller. */
class ItemFrames {
    
    static let shared = ItemFrames()
    
    var frames = [CustomImage]()
    var controllerViews = [UIView]()
    var connectingState = false
    var editing = false
    var positioning = false
    var deleting = false
    var connections = [Connection]()
    var downloadedConnections = [Connection]()
    var imageDimension = 80.0
    var noteDimension = 100.0
    var orientation = ""
    var rotatingTypeMenu: AddType!
    
    private init() {
        
    }
    
    // MARK: Note actions
    
    // When editing is triggered, bring textViews to front
    func bringNotesToFront() {
        ItemFrames.shared.editing = true
        for frame in frames {
            frame.layer.borderWidth = 3.0
            frame.layer.cornerRadius = 5.0
            for subframe in frame.subviews {
                let viewString = "\(subframe)"
                let start = viewString.index(viewString.startIndex, offsetBy: 8)
                let start2 = viewString[start...].index(of: ":")
                let resulting = viewString[start..<start2!]
                if (resulting == "enteredTextView") {
                    subframe.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    // When editing is finished, send textViews to back
    func sendNotesToBack() {
        ItemFrames.shared.editing = false
        for frame in frames {
            frame.layer.borderWidth = 0.0
            for subframe in frame.subviews {
                let viewString = "\(subframe)"
                let start = viewString.index(viewString.startIndex, offsetBy: 8)
                let start2 = viewString[start...].index(of: ":")
                let resulting = viewString[start..<start2!]
                if (resulting == "enteredTextView") {
                    subframe.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    func recenterNoteviews() {
        for item in frames {
            if item.noteFrame != nil {
                item.noteFrame.centerVertically()
            }
        }
    }
    
    // MARK: Highlights actions
    
    // Removes all highlights
    func removeAllHighlights() {
        for frame in frames {
            frame.connecting = false
            for view in frame.subviews{
                let viewString = "\(view)"
                let start = viewString.index(viewString.startIndex, offsetBy: 8)
                let start2 = viewString[start...].index(of: ":")
                let resulting = viewString[start..<start2!]
                if resulting == "View" || resulting == "iew" || resulting == "enteredTextView" {
                    // Is not highlight overlay
                } else {
                    let fadeAnimation = AnimationType.rotate(angle: 0)
                    view.animate(animations: [fadeAnimation], initialAlpha: 0.5, finalAlpha: 0.0, delay: 0.0, duration: 0.5, completion: {
                        frame.sendSubview(toBack: view)
                        frame.bordering = false
                    })
                }
            }
        }
    }
    
    // Remove other highlights after moving into another frame
    func removeOtherHighlights(object: CustomImage) {
        for frame in frames {
            // If this highlight isn't the currently active one
            if frame != object && frame.bordering == true {
                frame.connecting = false
                for view in frame.subviews{
                    let viewString = "\(view)"
                    let start = viewString.index(viewString.startIndex, offsetBy: 8)
                    let start2 = viewString[start...].index(of: ":")
                    let resulting = viewString[start..<start2!]
                    if resulting == "View" || resulting == "iew" || resulting == "enteredTextView" {
                       // Is not a highlight overlay
                    } else {
                        let fadeAnimation = AnimationType.rotate(angle: 0)
                        view.animate(animations: [fadeAnimation], initialAlpha: 0.5, finalAlpha: 0.0, delay: 0.0, duration: 0.5, completion: {
                            frame.sendSubview(toBack: view)
                            frame.bordering = false
                        })
                    }
                }
            }
        }
    }
    
    // MARK: Delete actions
    
    func setupDeleteMode() {
        for frame in frames {
            frame.setupDelete()
        }
    }
    
    func exitDeleteMode() {
        ItemFrames.shared.deleting = false
        for frame in frames {
            for subframe in frame.subviews {
                let viewString = "\(subframe)"
                let start = viewString.index(viewString.startIndex, offsetBy: 8)
                let start2 = viewString[start...].index(of: ":")
                let resulting = viewString[start..<start2!]
                // Removes the delete X's
                if resulting == "n" {
                    let fadeAnimation = AnimationType.rotate(angle: 0)
                    subframe.animate(animations: [fadeAnimation], initialAlpha: 0.5, finalAlpha: 0.0, delay: 0.0, duration: 0.5, completion: {
                            subframe.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    // MARK: Orientation actions
    
    // Sets up initial orientation of views before any rotations occur with them
    func initialOrientation(direction: String, view: UIView) {
        if ItemFrames.shared.orientation == "right" {
           view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        }
        if ItemFrames.shared.orientation == "left" {
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        }
    }
    
    // Rotates items in accordance with phone
    func rotate(toOrientation: String, sender: Any) {
        
        if toOrientation == "toRight" && ItemFrames.shared.orientation != "right" {
            for item in frames {
                item.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                item.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            for connect in connections {
                connect.label.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                connect.label.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            for view in controllerViews {
                view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                view.animate(animations: [rotateAnimation], initialAlpha: view.alpha, finalAlpha: view.alpha, delay: 0.0, duration: 0.25, completion: {})
            }
            if rotatingTypeMenu != nil {
                rotatingTypeMenu.view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                rotatingTypeMenu.view.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            
            ItemFrames.shared.orientation = "right"
        }
        if toOrientation == "toLeft" && ItemFrames.shared.orientation != "left" {
            for item in frames {
                item.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                item.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            for connect in connections {
                connect.label.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                connect.label.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            for view in controllerViews {
                view.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                view.animate(animations: [rotateAnimation], initialAlpha: view.alpha, finalAlpha: view.alpha, delay: 0.0, duration: 0.25, completion: {})
            }
            if rotatingTypeMenu != nil {
                rotatingTypeMenu.view.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                rotatingTypeMenu.view.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            
            ItemFrames.shared.orientation = "left"
        }
        if toOrientation == "backFromRight" && ItemFrames.shared.orientation != "" {
            for item in frames {
                item.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                item.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            for connect in connections {
                connect.label.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                connect.label.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            for view in controllerViews {
                view.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                view.animate(animations: [rotateAnimation], initialAlpha: view.alpha, finalAlpha: view.alpha, delay: 0.0, duration: 0.25, completion: {})
            }
            if rotatingTypeMenu != nil {
                rotatingTypeMenu.view.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                rotatingTypeMenu.view.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            
            ItemFrames.shared.orientation = ""
        }
        if toOrientation == "backFromLeft"  && ItemFrames.shared.orientation != "" {
            for item in frames {
                item.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                item.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            for connect in connections {
                connect.label.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                connect.label.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
            for view in controllerViews {
                view.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                view.animate(animations: [rotateAnimation], initialAlpha: view.alpha, finalAlpha: view.alpha, delay: 0.0, duration: 0.25, completion: {})
            }
            if rotatingTypeMenu != nil {
                rotatingTypeMenu.view.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                rotatingTypeMenu.view.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {})
            }
                
            ItemFrames.shared.orientation = ""
        }
        
    }
    
    // MARK: TextView actions
    
    // Scale textView font to fit inside it
    func updateTextFont(oneTextView: UITextView, fontSize: Int) {
        if (oneTextView.text.isEmpty || oneTextView.bounds.size.equalTo(CGSize.zero)) {
            return
        }
        
        let textViewSize = oneTextView.frame.size
        let fixedWidth = textViewSize.width
        let expectSize = oneTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        
        var expectFont = oneTextView.font
        // Decreases until it fits in textView
        if (expectSize.height > textViewSize.height) {
            while (oneTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > textViewSize.height) {
                expectFont = oneTextView.font!.withSize(oneTextView.font!.pointSize - 1)
                oneTextView.font = expectFont
            }
        } else {
            // Increases until it reaches the default font size
            while (oneTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < textViewSize.height && Int((oneTextView.font?.pointSize)!) < fontSize) {
                expectFont = oneTextView.font
                oneTextView.font = oneTextView.font!.withSize(oneTextView.font!.pointSize + 1)
            }
            oneTextView.font = expectFont
        }
    }
    
}

