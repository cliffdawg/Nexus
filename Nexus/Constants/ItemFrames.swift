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
    var connectingState = false
    var editing = false
    var positioning = false
    var deleting = false
    var connections = [Connection]()
    var downloadedConnections = [Connection]()
    var imageDimension = 50.0
    var noteDimension = 100.0
    
    var orientation = ""
    
    var rotatingTypeMenu: AddType!
    
    private init() {
        
    }
    
    // When editing is triggered
    func bringNotesToFront() {
        
        ItemFrames.shared.editing = true
        for frame in frames {
            
            for subframe in frame.subviews {
                let viewString = "\(subframe)"
                let start = viewString.index(viewString.startIndex, offsetBy: 8)
                let start2 = viewString[start...].index(of: ":")
                let resulting = viewString[start..<start2!]
                print("view: \(resulting)")
                if (resulting == "enteredTextView") {
                    //frame.bringSubview(toFront: subframe)
                    subframe.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    // When editing is finished
    func sendNotesToBack() {
        
        ItemFrames.shared.editing = false
        for frame in frames {
            
            for subframe in frame.subviews {
                let viewString = "\(subframe)"
                let start = viewString.index(viewString.startIndex, offsetBy: 8)
                let start2 = viewString[start...].index(of: ":")
                let resulting = viewString[start..<start2!]
                
                if (resulting == "enteredTextView") {
                    //frame.sendSubview(toBack: subframe)
                    subframe.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    func removeOtherHighlights (object: CustomImage) {
        for frame in frames {
            if ((frame != object) && (frame.bordering == true)) {
                print("target done")
                frame.connecting = false
                for view in frame.subviews{
                    //print("view: \(view)")
                    let viewString = "\(view)"
                    
                    let start = viewString.index(viewString.startIndex, offsetBy: 8)
                    let start2 = viewString[start...].index(of: ":")
                    let resulting = viewString[start..<start2!]
                    
                    
                    if ((resulting == "View") || (resulting == "iew") || (resulting == "enteredTextView")) {
                       
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
                print("view: \(viewString)")
                let start = viewString.index(viewString.startIndex, offsetBy: 8)
                let start2 = viewString[start...].index(of: ":")
                let resulting = viewString[start..<start2!]
                print("resulting: \(resulting)")
                if (resulting == "n") {
                    let fadeAnimation = AnimationType.rotate(angle: 0)
                    subframe.animate(animations: [fadeAnimation], initialAlpha: 0.5, finalAlpha: 0.0, delay: 0.0, duration: 0.5, completion: {
                            subframe.removeFromSuperview()
                    })
                }
            }
//        let zoomAnimation = AnimationType.zoom(scale: 0.5)
//        button.animate(animations: [zoomAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { })
        }
    }
    
    // Sets up initial orientation of views before any rotations occur with them
    func initialOrientation(direction: String, view: UIView) {
        if ItemFrames.shared.orientation == "right" {
           view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        }
        if ItemFrames.shared.orientation == "left" {
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        }
    }
    
    func rotate(toOrientation: String) {
        
        ///*
        print("rotate frames")
        
        if toOrientation == "toRight" && ItemFrames.shared.orientation != "right" {
            //
            print("toRight")
            for item in frames {
                item.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                item.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {

                })
                
            }
            for connect in connections {
                connect.label.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                connect.label.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {
                    
                })
            }
            if rotatingTypeMenu != nil {
                rotatingTypeMenu.view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                rotatingTypeMenu.view.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {
                    
                })
            }
            ItemFrames.shared.orientation = "right"
        }
        if toOrientation == "toLeft" && ItemFrames.shared.orientation != "left" {
            //
            print("toLeft")
            for item in frames {
                item.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                item.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {

                })
            
            }
            for connect in connections {
                connect.label.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                connect.label.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {
                    
                })
            }
            if rotatingTypeMenu != nil {
                rotatingTypeMenu.view.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                rotatingTypeMenu.view.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {
                    
                })
            }
            ItemFrames.shared.orientation = "left"
        }
        if toOrientation == "backFromRight" && ItemFrames.shared.orientation != "" {
            //
            print("backFromRight")
            for item in frames {
                item.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                item.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {

                })
            
            }
            for connect in connections {
                connect.label.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                connect.label.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {
                    
                })
            }
            if rotatingTypeMenu != nil {
                rotatingTypeMenu.view.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: -CGFloat.pi/2)
                rotatingTypeMenu.view.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {
                    
                })
            }
            ItemFrames.shared.orientation = ""
        }
        if toOrientation == "backFromLeft"  && ItemFrames.shared.orientation != "" {
            //
            print("backFromLeft")
            for item in frames {
                item.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                item.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {

                })
                
            }
            for connect in connections {
                connect.label.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                connect.label.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {
                    
                })
            }
            if rotatingTypeMenu != nil {
                rotatingTypeMenu.view.transform = CGAffineTransform(rotationAngle: 0)
                let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/2)
                rotatingTypeMenu.view.animate(animations: [rotateAnimation], initialAlpha: 1.0, finalAlpha: 1.0, delay: 0.0, duration: 0.25, completion: {
                    
                })
            }
            ItemFrames.shared.orientation = ""
        }
    }
    
    func makeImagesEditable() {
        
    }
    
}
