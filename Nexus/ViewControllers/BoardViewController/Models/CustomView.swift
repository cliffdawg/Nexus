//
//  CustomView.swift
//  Nexus
//
//  Created by Clifford Yin on 3/11/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import ViewAnimator
import TinyConstraints

/* Enables all the interaction/implementation of the Nexus board. */
class CustomView: UIView {

    var start = CGPoint()
    
    var end = CGPoint()
    
    let border = 15
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    // Drawing the connection(s)
    override func draw(_ rect: CGRect) {
        
        print("drawing line: \(start), \(end)")
        
        let line = UIBezierPath()
        
        line.lineWidth = 5
        
        line.move(to: start)
        
        line.addLine(to: end)
        
        //Keep using the method addLineToPoint until you get to the one where about to close the path
        
        //line.close()
        
        //If you want to stroke it with a red color
        UIColor.red.setStroke()
        line.stroke()
        
        //If you want to fill it as well
        
    }
    
    // When connection is added, be able to name it
    @objc
    func labelConnect(_ sender: UIButton) {
        
        let animation = AnimationType.rotate(angle: 0.0)
        sender.animate(animations: [animation], initialAlpha: 1.0, finalAlpha: 0.5, delay: 0.0, duration: 0.1, completion: {
            
                let awayAnimation = AnimationType.rotate(angle: 0.0)
                let intoAnimation = AnimationType.zoom(scale: 0.5)
                sender.superview?.animate(animations: [awayAnimation], initialAlpha: 1.0, finalAlpha: 0.0, delay: 0.2, duration: 1.0, completion: {
                sender.superview?.removeFromSuperview()
            })
            let rect = sender.superview?.frame
            let xCoord = CGFloat(Int((rect?.midX)!) - 50)
            let yCoord = CGFloat(Int((rect?.midY)!) - 15)
            let label = UILabel(frame: CGRect(x: xCoord, y: yCoord, width: 100.0, height: 35.0))
            
            
            for view in (sender.superview?.subviews)! {
                let viewString = "\(view)"
                let start = viewString.index(viewString.startIndex, offsetBy: 8)
                let start2 = viewString[start...].index(of: ":")
                let resulting = viewString[start..<start2!]
                if (resulting == "ield") {
                    let textField = view as! UITextField
                    label.text = textField.text
                    
                }
            }
            
            //print("contentSize: \()")
            self.addSubview(label)
            label.animate(animations: [intoAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: {label.backgroundColor = .white}
            )
            
        })
    }
    
    // Dynamically draw the connections. Send highlights to back if necessary. Keeps images at front if present.
    func refresh(begin: CGPoint, stop: CGPoint) {
        
        let point = CGPoint(x: 0.0, y: 0.0)
        
        var objected = false
        
        for frame in ItemFrames.shared.frames {
            if ((frame.frame.contains(self.end))) {
                objected = true
            }
        }
        
        if ((begin == point) && (stop == point) && (objected == true)) {
            // save the connection
            
            var inObject = false
            
            for single in self.subviews {
                print(single.tag)
                if (single.tag == 999) {
                    single.removeFromSuperview()
                }
            }
            
            let newX = CGFloat((self.end.x + self.start.x)/2 - 30)
            let newY = CGFloat((self.end.y + self.start.y)/2 - 15)
            let labelRect = CGRect(x: newX, y: newY, width: 90, height: 60)
            let labelView = UIView(frame: labelRect)
            labelView.backgroundColor = .yellow
            labelView.tag = 999
            
            
            
            let labelText = UITextField()
            labelText.placeholder = "Enter..."
            labelText.borderStyle = .bezel
            labelText.isUserInteractionEnabled = true
            labelText.allowsEditingTextAttributes = true
            labelView.addSubview(labelText)
            labelText.edges(to: labelView, insets: UIEdgeInsets(top: 0, left: 0, bottom: -labelView.frame.height/2, right: 0))
            labelView.bringSubview(toFront: labelText)
            
            let button = UIButton()
            button.setTitleColor(.blue, for: .normal)
            button.setTitle("Connect", for: .normal)
            button.backgroundColor = .green
            button.isUserInteractionEnabled = true
            button.isEnabled = true
            button.addTarget(self, action: #selector(labelConnect(_:)), for: .touchUpInside)
            labelView.addSubview(button)
            button.edges(to: labelView, insets: UIEdgeInsets(top: labelView.frame.height/2, left: 0, bottom: 0, right: 0))
            labelView.bringSubview(toFront: button)
            //labelText.top(to: labelView)
            
            self.addSubview(labelView)
            
            let animation = AnimationType.from(direction: .right, offset: 50)
            labelView.animate(animations: [animation], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: nil)
            
                for frame in ItemFrames.shared.frames {
                    if ((frame.frame.contains(self.end))) {
                        
                        inObject = true
                        
                        for view in frame.subviews{
                            //print("view: \(view)")
                            let viewString = "\(view)"
                            print("viewLoop: \(viewString)")
                            let start = viewString.index(viewString.startIndex, offsetBy: 8)
                            let start2 = viewString[start...].index(of: ":")
                            let resulting = viewString[start..<start2!]
                            print("view: \(resulting)")
                            
                            if ((resulting == "View") || (resulting == "iew") || (resulting == "enteredTextView")) {
                                print("is image")
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
            if (inObject == false) {
                self.start = begin
                self.end = stop
                self.setNeedsDisplay()
            }
        } else {
            self.start = begin
            self.end = stop
            self.setNeedsDisplay()
            
        }
        for frame in ItemFrames.shared.frames {
            if ((frame.frame.contains(self.end))) {
            
                if (frame.bordering == false) {
                    frame.borderView()
                }
            } else if (frame.bordering == true) {
                for view in frame.subviews{
                    // This is for determining which type of view this is
                    let viewString = "\(view)"
                    print("viewLoop: \(viewString)")
                    let start = viewString.index(viewString.startIndex, offsetBy: 8)
                    let start2 = viewString[start...].index(of: ":")
                    let resulting = viewString[start..<start2!]
                    print("view: \(resulting)")
                    
                    if ((resulting == "View") || (resulting == "iew") || (resulting == "enteredTextView")) {
                        print("is image")
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
}
