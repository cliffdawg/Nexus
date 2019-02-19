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
class CustomView: UIView, UITextFieldDelegate {

    let border = 15
    var start = CGPoint()
    var end = CGPoint()
    var startObject: CustomImage!
    var endObject: CustomImage!
    var sub1: CustomImage!
    var sub2: CustomImage!
    
    // Offsets used to calculate center of notes/images
    var beginOffset = 0.0
    var finishOffset = 0.0
    
    // MARK: Graphics functions
    
    // Drawing the connection(s)
    override func draw(_ rect: CGRect) {
        
        let line = UIBezierPath()
        line.lineWidth = 5
        line.move(to: start)
        line.addLine(to: end)
        UIColor.white.setStroke()
        line.stroke()
        
        // Loops through all the connections
        for item in ItemFrames.shared.connections {
            for single in ItemFrames.shared.frames {
                if ((single.uniqueID != "") && (item.beginID != nil)){
                    if (item.beginID == single.uniqueID) {
                        sub1 = single
                    } else if (item.finishID == single.uniqueID) {
                        sub2 = single
                    }
                }
            }
            
            // Offsets for centering the end of the connection line
            var oneWidth = 0.0
            var twoWidth = 0.0
            var oneHeight = 0.0
            var twoHeight = 0.0
            
            // Collect offsets from starting object
            if item.initialBegin != nil {
                if item.initialBegin.type == "image" {
                    oneWidth = Double(item.initialBegin.imageFrame.frame.width)/2
                    oneHeight = Double(item.initialBegin.imageFrame.frame.height)/2
                } else if item.initialBegin.type == "note" {
                    oneWidth = Double(item.initialBegin.noteFrame.frame.width)/2
                    oneHeight = Double(item.initialBegin.noteFrame.frame.height)/2
                }
            }
            
            // Collect offsets from ending object
            if item.initialFinish != nil {
                if item.initialFinish.type == "image" {
                    twoWidth = Double(item.initialFinish.imageFrame.frame.width)/2
                    twoHeight = Double(item.initialFinish.imageFrame.frame.height)/2
                } else if item.initialFinish.type == "note" {
                    twoWidth = Double(item.initialFinish.noteFrame.frame.width)/2
                    twoHeight = Double(item.initialFinish.noteFrame.frame.height)/2
                }
            }
        
            if item.downloadBegin != nil {
                oneWidth = Double(item.downloadBegin.frame.width)/2
                oneHeight = Double(item.downloadBegin.frame.height)/2
            }
            
            if item.downloadFinish != nil {
                twoWidth = Double(item.downloadFinish.frame.width)/2
                twoHeight = Double(item.downloadFinish.frame.width)/2
                
            }
            
            let line = UIBezierPath()
            line.lineWidth = 5
            
            // Draws connections
            if item.initialBegin != nil && item.initialFinish != nil {
                line.move(to: CGPoint(x: Double(item.initialBegin.frame.minX) + oneWidth, y: Double(item.initialBegin.frame.minY) + oneHeight))
                line.addLine(to: CGPoint(x: Double(item.initialFinish.frame.minX) + twoWidth, y: Double(item.initialFinish.frame.minY) + twoHeight))
            } else if item.downloadBegin != nil && item.downloadFinish != nil {
                line.move(to: CGPoint(x: Double(item.downloadBegin.frame.minX) + oneWidth, y: Double(item.downloadBegin.frame.minY) + oneHeight))
                line.addLine(to: CGPoint(x: Double(item.downloadFinish.frame.minX) + twoWidth, y: Double(item.downloadFinish.frame.minY) + twoHeight))
            }
            
            UIColor.white.setStroke()
            line.stroke()
        }
    }
    
    // Dynamically draw the connections. Send highlights to back if necessary. Keeps images at front if present.
    func refresh(begin: CGPoint, stop: CGPoint) {
        
        let point = CGPoint(x: 0.0, y: 0.0)
        
        var objected = false
        
        // If the current line ends in a frame
        for frame in ItemFrames.shared.frames {
            if frame.frame.contains(self.end) {
                objected = true
            }
        }
        
        // If the connecting just ended (begin and end == (0.0, 0.0)) and current line ends in frame, present a view to add a connection
        if begin == point && stop == point && objected == true {
            
            // Initially false, if frame contains end of line, will be set to true
            var inObject = false
            
            // If already existing input view for naming connection, remove it
            for single in self.subviews {
                if single.tag == 999 {
                    single.removeFromSuperview()
                }
            }
            
            // Created initial input field for connection name
            let newX = CGFloat((self.end.x + self.start.x)/2)
            let newY = CGFloat((self.end.y + self.start.y)/2)
            let labelRect = CGRect(x: newX - 65, y: newY - 30, width: 130, height: 60)
            let labelView = UIView(frame: labelRect)
            labelView.backgroundColor = UIColor(rgb: 0xADEAFF)
            labelView.tag = 999
            let labelText = UITextField()
            labelText.placeholder = "Enter..."
            labelText.textAlignment = .center
            labelText.font = UIFont(name: "Futura-Medium", size: 17.0)
            labelText.textColor = .darkGray
            labelText.borderStyle = .bezel
            labelText.isUserInteractionEnabled = true
            labelText.allowsEditingTextAttributes = true
            labelText.adjustsFontSizeToFitWidth = true
            labelText.autocorrectionType = UITextAutocorrectionType.no
            labelText.autocapitalizationType = UITextAutocapitalizationType.none
            labelText.delegate = self as! UITextFieldDelegate
            
            labelView.addSubview(labelText)
            labelText.edges(to: labelView, insets: UIEdgeInsets(top: 0, left: 0, bottom: -labelView.frame.height/2, right: 0))
            labelView.bringSubview(toFront: labelText)
            
            // Generate button to create connection
            let button = UIButton()
            button.setTitleColor(UIColor(rgb: 0x34E5FF), for: .normal)
            button.setTitle("Connect", for: .normal)
            button.backgroundColor = UIColor(rgb: 0xB74F6F)
            button.titleLabel!.font = UIFont(name: "Futura-Medium", size: 17.0)
            button.isUserInteractionEnabled = true
            button.isEnabled = true
            button.addTarget(self, action: #selector(labelConnect(_:)), for: .touchUpInside)
            
            labelView.addSubview(button)
            button.edges(to: labelView, insets: UIEdgeInsets(top: labelView.frame.height/2, left: 0, bottom: 0, right: 0))
            labelView.bringSubview(toFront: button)
            ItemFrames.shared.controllerViews.append(labelView)
            self.addSubview(labelView)
            
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: labelView)
            }
            
            let animation = AnimationType.from(direction: .right, offset: 50)
            labelView.animate(animations: [animation], initialAlpha: 0.5, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: nil)
            
            // If connection ends inside frame, fade away highlights
            for frame in ItemFrames.shared.frames {
                if frame.frame.contains(self.start) {
                    self.startObject = frame
                }
                if frame.frame.contains(self.end) {
                    inObject = true
                    self.endObject = frame
                    
                    for view in frame.subviews {
                        let viewString = "\(view)"
                        let start = viewString.index(viewString.startIndex, offsetBy: 8)
                        let start2 = viewString[start...].index(of: ":")
                        let resulting = viewString[start..<start2!]
                        if resulting == "View" || resulting == "iew" || resulting == "enteredTextView" {
                            // This is an image, don't fade it
                        } else {
                            // This is an overlay, fade it
                            let fadeAnimation = AnimationType.rotate(angle: 0)
                            view.animate(animations: [fadeAnimation], initialAlpha: 0.5, finalAlpha: 0.0, delay: 0.0, duration: 0.5, completion: {
                                frame.sendSubview(toBack: view)
                                frame.bordering = false
                            })
                        }
                    }
                }
            }
            // If end and isn't in any object, remove lines
            if inObject == false {
                self.start = begin
                self.end = stop
                self.setNeedsDisplay()
            }
            
        } else {
            self.start = begin
            self.end = stop
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
        
        for frame in ItemFrames.shared.frames {
            if frame.frame.contains(self.end) {
                if frame.bordering == false {
                    frame.borderView()
                }
            } else if frame.bordering == true {
                // If this is not the end but still has a border, then remove it
                for view in frame.subviews {
                    // This is for determining which type of view this is
                    let viewString = "\(view)"
                    let start = viewString.index(viewString.startIndex, offsetBy: 8)
                    let start2 = viewString[start...].index(of: ":")
                    let resulting = viewString[start..<start2!]
                    if resulting == "View" || resulting == "iew" || resulting == "enteredTextView" {
                        // This is an image, don't fade it
                    } else {
                        // This is overlay, fade it
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
    
    // MARK: Initialization functions
    
    // Add Neo4j objects
    func loadFrames(sender: DetailViewController) {
        
        // Load notes
        for obj in ItemFrames.shared.frames {
            // Rotate based on orientation
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: obj)
            }
            
            // Add notes to view
            if (obj.imageLink == nil) {
                ItemFrames.shared.updateTextFont(oneTextView: obj.noteFrame, fontSize: Int(obj.noteFrame.font!.pointSize))
                self.addSubview(obj)
                obj.delegate = sender
            }
            
            obj.alpha = 1.0
            let intoAnimation = AnimationType.zoom(scale: 0.5)
            obj.animate(animations: [intoAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { })
        }
        
        for item in ItemFrames.shared.connections {
            // Collects offsets for displaying the labels
            if item.begin.note == nil {
                beginOffset = ItemFrames.shared.imageDimension/2
            } else {
                beginOffset = ItemFrames.shared.noteDimension/2
            }
            
            if (item.finish.note == nil) {
                finishOffset = ItemFrames.shared.imageDimension/2
            } else {
                finishOffset = ItemFrames.shared.noteDimension/2
            }
            
            let newX = CGFloat((item.finish.xCoord + finishOffset + item.begin.xCoord + beginOffset)/2)
            let newY = CGFloat((item.finish.yCoord + finishOffset + item.begin.yCoord + beginOffset)/2)
            
            let label = UILabel(frame: CGRect(x: newX - 50, y: newY - 17.5, width: 100.0, height: 35.0))
            label.text = item.connection
            label.backgroundColor = .blue
            label.textColor = .white
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 3.0
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            // Adjust label size based on word count
            if (label.text?.count)! < 14 {
                label.sizeToFit()
                label.frame = CGRect(x: newX - label.frame.width/2, y: newY - label.frame.height/2, width: label.frame.width, height: label.frame.height)
                let insets = UIEdgeInsets(top: -2, left: -4, bottom: -2, right: -4)
                label.frame = UIEdgeInsetsInsetRect(label.frame, insets)
            } else {
                let insets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: -2)
                label.frame = UIEdgeInsetsInsetRect(CGRect(x: newX - 60.0, y: newY - 15.0, width: 120.0, height: 30.0), insets)
            }
            
            label.dropShadow()
            label.font = UIFont(name: "Futura", size: 15)
            
            item.label = label
            self.addSubview(label)
            
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: label)
            }
            
            let intoAnimation = AnimationType.zoom(scale: 0.5)
            label.animate(animations: [intoAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { label.backgroundColor = .blue })
        }
    }
    
    // Add the images to the board
    func loadImages(sender: DetailViewController) {
        for obj in ItemFrames.shared.frames {
            if (obj.imageLink != nil) {
                obj.alpha = 0.0
                self.addSubview(obj)
                obj.delegate = sender
                obj.loadImage()
            }
        }
    }
    
    // MARK: Label functionalities
    
    // Implementation of the textField entry view used to add a connection
    @objc
    func labelConnect(_ sender: UIButton) {
        
        var textField: UITextField!
        var text = ""
        
        let animation = AnimationType.rotate(angle: 0.0)
        
        // Remove the entry field and its parent view
        sender.animate(animations: [animation], initialAlpha: 1.0, finalAlpha: 0.5, delay: 0.0, duration: 0.1, completion: {
            
            // Removes this input view from ItemFrames' tracked views to rotate
            for (index, element) in ItemFrames.shared.controllerViews.enumerated() {
                if element.tag == 999 {
                    ItemFrames.shared.controllerViews.remove(at: index)
                }
            }
            
            let awayAnimation = AnimationType.rotate(angle: 0.0)
            let intoAnimation = AnimationType.zoom(scale: 0.5)
            sender.superview?.animate(animations: [awayAnimation], initialAlpha: 1.0, finalAlpha: 0.0, delay: 0.2, duration: 1.0, completion: {
                    sender.superview?.removeFromSuperview()
            })
            
            // Set up the label
            let xCoord = (self.startObject.center.x + self.endObject.center.x)/2
            let yCoord = (self.startObject.center.y + self.endObject.center.y)/2
            let label = UILabel(frame: CGRect(x: xCoord - 50, y: yCoord - 17.5, width: 100.0, height: 35.0))
            label.backgroundColor = .blue
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 3.0
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            // Assigns the label the input textField's text
            for view in (sender.superview?.subviews)! {
                let viewString = "\(view)"
                let start = viewString.index(viewString.startIndex, offsetBy: 8)
                let start2 = viewString[start...].index(of: ":")
                let resulting = viewString[start..<start2!]
                if (resulting == "ield") {
                    textField = view as! UITextField
                    label.text = textField.text
                    if (label.text?.count)! < 14 {
                        label.sizeToFit()
                        let insets = UIEdgeInsets(top: -2, left: -4, bottom: -2, right: -4)
                        label.frame = UIEdgeInsetsInsetRect(label.frame, insets)
                        label.frame = CGRect(x: xCoord - label.frame.width/2, y: yCoord - label.frame.height/2, width: label.frame.width, height: label.frame.height)
                    } else {
                        let insets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: -2)
                        label.frame = UIEdgeInsetsInsetRect(CGRect(x: xCoord - 60.0, y: yCoord - 15.0, width: 120.0, height: 30.0), insets)
                    }
                    label.textColor = .white
                    text = textField.text!
                }
            }
            
            label.dropShadow()
            label.font = UIFont(name: "Futura", size: 15)
                
            // If text is blank, skip across all actual label creation
            if textField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
                self.start = CGPoint(x: 0.0, y: 0.0)
                self.end = CGPoint(x: 0.0, y: 0.0)
                self.setNeedsDisplay()
                return
            }
                
            // Add/animate the label to the board's view
            self.addSubview(label)
            
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: label)
            }
            
            label.animate(animations: [intoAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { label.backgroundColor = .blue })
            let connect = Connection()
            connect.label = label
            connect.set(origin: self.startObject, final: self.endObject, connect: text)
            connect.initialBegin = self.startObject
            connect.initialFinish = self.endObject
            ItemFrames.shared.connections.append(connect)
            self.start = CGPoint(x: 0.0, y: 0.0)
            self.end = CGPoint(x: 0.0, y: 0.0)
            self.setNeedsDisplay()
        })
    }
    
    // Re-position label after element is re-positioned
    func loadLabelAfterRedraw(connections: [Connection]) {
        var startOffset = 0.0
        var endOffset = 0.0
        
        for item in connections {
            // Two cases for either created or downloaded connections
            
            // Get midpoints of two objects
            if item.downloadBegin != nil {
                if item.downloadBegin.note == "" {
                    startOffset = ItemFrames.shared.imageDimension/2
                } else {
                    startOffset = ItemFrames.shared.noteDimension/2
                }
                if item.downloadFinish.note == "" {
                    endOffset = ItemFrames.shared.imageDimension/2
                } else {
                    endOffset = ItemFrames.shared.noteDimension/2
                }
            }
            if item.initialBegin != nil {
                if item.initialBegin.note == "" {
                    startOffset = ItemFrames.shared.imageDimension/2
                } else {
                    startOffset = ItemFrames.shared.noteDimension/2
                }
                if item.initialFinish.note == "" {
                    endOffset = ItemFrames.shared.imageDimension/2
                } else {
                    endOffset = ItemFrames.shared.noteDimension/2
                }
            }
            
            var newX = 0.0
            var newY = 0.0
            
            // Two cases for either created or downloaded connections' coordinates
            if item.downloadBegin != nil {
                newX = (Double(item.downloadFinish.frame.minX) + endOffset + Double(item.downloadBegin.frame.minX) + startOffset)/2
                newY = (Double(item.downloadFinish.frame.minY) + endOffset + Double(item.downloadBegin.frame.minY) + startOffset)/2
            }
            if item.initialBegin != nil {
                newX = (Double(item.initialFinish.frame.minX) + endOffset + Double(item.initialBegin.frame.minX) + startOffset)/2
                newY = (Double(item.initialFinish.frame.minY) + endOffset + Double(item.initialBegin.frame.minY) + startOffset)/2
            }
            
            let label = item.label!
            label.frame = CGRect(x: newX - 50, y: newY - 17.5, width: 100.0, height: 35.0)
            
            // Adjust label size based on word count
            if (label.text?.count)! < 14 {
                label.sizeToFit()
                label.frame = CGRect(x: newX - Double(label.frame.width/2), y: newY - Double(label.frame.height/2), width: Double(label.frame.width), height: Double(label.frame.height))
                let insets = UIEdgeInsets(top: -2, left: -4, bottom: -2, right: -4)
                label.frame = UIEdgeInsetsInsetRect(label.frame, insets)
            } else {
                let insets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: -2)
                label.frame = UIEdgeInsetsInsetRect(CGRect(x: newX - 60.0, y: newY - 15.0, width: 120.0, height: 30.0), insets)
            }
            
            label.text = item.connection
            label.backgroundColor = .blue
            label.textColor = .white
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 3.0
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.dropShadow()
            label.font = UIFont(name: "Futura", size: 15)
            
            item.label = label
            
            let intoAnimation = AnimationType.zoom(scale: 0.5)
            label.animate(animations: [intoAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { label.backgroundColor = .blue })
        }
    }
    
    // MARK: TextField delegate functions
    
    // Limit the connections entry textField character count to 25
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= 25
    }
    
}
