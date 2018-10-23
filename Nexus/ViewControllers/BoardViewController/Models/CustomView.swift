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
import Theo

/* Enables all the interaction/implementation of the Nexus board. */
class CustomView: UIView, UITextFieldDelegate {

    var start = CGPoint()
    
    var end = CGPoint()
    
    var startObject: CustomImage!
    
    var endObject: CustomImage!
    
    let border = 15
    
    var theo: RestClient!
    
    var sub1: CustomImage!
    var sub2: CustomImage!
    
    var beginOffset = 0.0
    var finishOffset = 0.0
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

//    func loadneo4j() {
//        
//        let theo = RestClient(baseURL: "https://hobby-nalpfmhdkkbegbkehohghgbl.dbs.graphenedb.com:24780", user: "general", pass: "b.ViGagdahQiVM.Uq0mEcCiZCl4Bc5W")
//        
//        //var noded = Node()
//        
//        
//        ////////// RELATIONSHIP
//        
////        var tester1: Node!
////        var tester2: Node!
////
////        var relate = Relationship()
////
////        theo.fetchNode("41", completionBlock: {(node, error) in
////            print("fetch error: \(error)")
////            tester1 = node!
////        })
////
////        theo.fetchNode("24", completionBlock: {(node, error) in
////            print("fetch error: \(error)")
////            tester2 = node!
////        })
////
////        let when = DispatchTime.now() + 2
////        DispatchQueue.main.asyncAfter(deadline: when) {
////            relate.relate(tester1, toNode: tester2, type: "friends")
////
////            theo.createRelationship(relate, completionBlock: {(node, error) in
////               print("relate error: \(error)")
////            })
////        }
//        /////////// CREATE
//        //noded.addLabel("tester1")
////        noded.setProp("key1", propertyValue: "value1")
////
////        // error: "{ URL: https://hobby-nalpfmhdkkbegbkehohghgbl.dbs.graphenedb.com:24780/db/data/db/data/node }"
////        theo.createNode(noded, labels: ["friend1"], completionBlock: { (node, error) in
////            print("error: \(error)")
////        })
//        
//    }
    
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
        
        // Draws all the connections' lines
        for item in ItemFrames.shared.connections {
            print("\(item.connection)")

            // We changed it to this but then it stopeed working sometimes
//            for single in ItemFrames.shared.frames {
//                if single.uniqueID != "" && item.downloadBegin != nil {
//                    if item.downloadBegin.uniqueID == single.uniqueID {
//                        print("single: \(single)")
//                        sub1 = single
//                    } else if item.downloadFinish.uniqueID == single.uniqueID {
//                        sub2 = single
//                        print("single: \(single)")
//                    }
//                }
//            }
            
            for single in ItemFrames.shared.frames {
                print("\(item.beginID), \(single.uniqueID)")
                if ((single.uniqueID != "") && (item.beginID != nil)){
                    if (item.beginID == single.uniqueID) {
                        print("single: \(single)")
                        sub1 = single
                    } else if (item.finishID == single.uniqueID) {
                        sub2 = single
                        print("single: \(single)")
                    }
                }
            }
            
            // Offsets for centering the end of the connection line
            var oneWidth = 0.0
            var twoWidth = 0.0
            var oneHeight = 0.0
            var twoHeight = 0.0
            
            if item.initialBegin != nil {
                if item.initialBegin.type == "image" {
                    print("initialbegin: \(Double(item.initialBegin.frame.minX) + oneWidth)/\(Double(item.initialBegin.frame.minY) + oneHeight)")
                    oneWidth = Double(item.initialBegin.imageFrame.frame.width)/2
                    oneHeight = Double(item.initialBegin.imageFrame.frame.height)/2
                
                } else if item.initialBegin.type == "note" {
                    print("item.initialBegin.type == note")
                    oneWidth = Double(item.initialBegin.noteFrame.frame.width)/2
                    oneHeight = Double(item.initialBegin.noteFrame.frame.height)/2
                } else {
                    print("no initialBegin")
                
                }
            }
            
            if item.initialFinish != nil {
                if item.initialFinish.type == "image" {
                    print("initialfinish: \(Double(item.initialFinish.frame.minX) + twoWidth)/\(Double(item.initialFinish.frame.minY) + twoHeight)")
                    twoWidth = Double(item.initialFinish.imageFrame.frame.width)/2
                    twoHeight = Double(item.initialFinish.imageFrame.frame.height)/2
                } else if item.initialFinish.type == "note" {
                    print("item.initialFinish.type == note")
                    twoWidth = Double(item.initialFinish.noteFrame.frame.width)/2
                    twoHeight = Double(item.initialFinish.noteFrame.frame.height)/2
                } else {
                    print("no item.initialfinish")
                }
            }
        
            if item.downloadBegin != nil {
                print("downloadBegin!")
                oneWidth = Double(item.downloadBegin.frame.width)/2
                oneHeight = Double(item.downloadBegin.frame.height)/2
                
            } else {
                print("no itembegin")
            }
            
            if item.downloadFinish != nil {
                print("downloadFinish!")
                twoWidth = Double(item.downloadFinish.frame.width)/2
                twoHeight = Double(item.downloadFinish.frame.width)/2
                
            } else {
                print("no item.finish")
            }
            
            let line = UIBezierPath()
            
            line.lineWidth = 5
            
            if item.initialBegin != nil && item.initialFinish != nil {
                print("draw initial begin")
                line.move(to: CGPoint(x: Double(item.initialBegin.frame.minX) + oneWidth, y: Double(item.initialBegin.frame.minY) + oneHeight))
                
                line.addLine(to: CGPoint(x: Double(item.initialFinish.frame.minX) + twoWidth, y: Double(item.initialFinish.frame.minY) + twoHeight))
                
            } else if item.downloadBegin != nil && item.downloadFinish != nil {
                print("new onewidth and oneheight")
                
                line.move(to: CGPoint(x: Double(item.downloadBegin.frame.minX) + oneWidth, y: Double(item.downloadBegin.frame.minY) + oneHeight))
                
                line.addLine(to: CGPoint(x: Double(item.downloadFinish.frame.minX) + twoWidth, y: Double(item.downloadFinish.frame.minY) + twoHeight))
            }
            
            UIColor.red.setStroke()
            line.stroke()
            //////// Still have the issue where note is being pushed back
            
//            let pointCheck = CGPoint(x: xCheck - 50.0, y: yCheck - 17.5)
//            if item.label.frame.minX != xCheck - 50.0 || item.label.frame.minY != yCheck - 17.5 {
//                item.label.center = pointCheck
//            }
            
        }
        
    }
    
    // Add Neo4j objects and connections
    func loadFrames(sender: DetailViewController) {
        for obj in ItemFrames.shared.frames {
            
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: obj)
            }
            
            if (obj.imageLink == nil) {
                //obj.loadImage()
                self.addSubview(obj)
                obj.delegate = sender
            }
            obj.alpha = 1.0
            let intoAnimation = AnimationType.zoom(scale: 0.5)
            obj.animate(animations: [intoAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { })
            
        }
        
        for item in ItemFrames.shared.connections {
            ////////////////////
            // begin and finish need to be kept here.
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
            label.layer.cornerRadius = 5.0
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            item.label = label
            self.addSubview(label)
            
            if ItemFrames.shared.orientation != "" {
                ItemFrames.shared.initialOrientation(direction: ItemFrames.shared.orientation, view: label)
            }
            
            let intoAnimation = AnimationType.zoom(scale: 0.5)
            label.animate(animations: [intoAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { label.backgroundColor = .blue })
        }
    }
    
    // Limit the connections textField character count
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        return newLength <= 20
    }
    
    func loadLabelAfterRedraw(connections: [Connection]) {
        print("loadlabelafterredraw: \(connections)")
        ////////////////////
        // Get midpoint of downloadBegin and downloadFinish
        var startOffset = 0.0
        var endOffset = 0.0
        for item in connections {
            print("connectname: \(item.connection)")
            
//            if item.begin != nil && item.finish != nil {
//                if item.begin.note == nil {
//                    startOffset = ItemFrames.shared.imageDimension/2
//                } else {
//                    startOffset = ItemFrames.shared.noteDimension/2
//                }
//                if item.finish.note == nil {
//                    endOffset = ItemFrames.shared.imageDimension/2
//                } else {
//                    endOffset = ItemFrames.shared.noteDimension/2
//                }
//            } else {
//                if item.initialBegin.note == "" {
//                    startOffset = ItemFrames.shared.imageDimension/2
//                } else {
//                    startOffset = ItemFrames.shared.noteDimension/2
//                }
//                if item.initialFinish.note == "" {
//                    endOffset = ItemFrames.shared.imageDimension/2
//                } else {
//                    endOffset = ItemFrames.shared.noteDimension/2
//                }
//            }
//
            ////
            if item.downloadBegin != nil {
                print("item.begin: \(item.downloadBegin)")
                print("item.finish: \(item.downloadFinish)")
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
                print("item.initialBegin: \(item.initialBegin)")
                print("item.initialFinish: \(item.initialFinish)")
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
            
            ////

            var newX = 0.0
            var newY = 0.0
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

            label.text = item.connection
            label.backgroundColor = .blue
            label.textColor = .white
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 5.0
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            item.label = label
            //self.addSubview(label)

            let intoAnimation = AnimationType.zoom(scale: 0.5)
            label.animate(animations: [intoAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { label.backgroundColor = .blue })
        }
    }
    
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
    
    // When connection is added, be able to name it
    @objc
    func labelConnect(_ sender: UIButton) {
        
        var text = ""
        let animation = AnimationType.rotate(angle: 0.0)
        
        // Remove text field
        sender.animate(animations: [animation], initialAlpha: 1.0, finalAlpha: 0.5, delay: 0.0, duration: 0.1, completion: {
            
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
            label.layer.cornerRadius = 5.0
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
        
            print("create connection objects: \(self.startObject), \(self.endObject)")
            // Assigns the label the input textField's text
            for view in (sender.superview?.subviews)! {
                let viewString = "\(view)"
                let start = viewString.index(viewString.startIndex, offsetBy: 8)
                let start2 = viewString[start...].index(of: ":")
                let resulting = viewString[start..<start2!]
                if (resulting == "ield") {
                    let textField = view as! UITextField
                    label.text = textField.text
                    if (label.text?.count)! < 14 {
                        label.sizeToFit()
                        let insets = UIEdgeInsets(top: -2, left: -4, bottom: -2, right: -4)
                        //label.drawText(in: UIEdgeInsetsInsetRect(label.frame, insets))
                        label.frame = UIEdgeInsetsInsetRect(label.frame, insets)
                    } else {
                        label.frame = CGRect(x: xCoord - 60, y: yCoord - 15.0, width: 120.0, height: 30.0)
                    }
                    
                    label.textColor = .white
                    text = textField.text!
                }
            }
            
            self.addSubview(label)
            label.animate(animations: [intoAnimation], initialAlpha: 0.0, finalAlpha: 1.0, delay: 0.0, duration: 0.5, completion: { label.backgroundColor = .blue })
            
            let connect = Connection()
            connect.label = label
            print("origin: \(self.startObject.specific), end: \(self.endObject.specific)")
            connect.set(origin: self.startObject, final: self.endObject, connect: text)
//            startSub.xCoord = Double(self.startObject.frame.minX)
//            startSub.yCoord = Double(self.startObject.frame.minY)
//            endSub.xCoord = Double(self.endObject.frame.minX)
//            endSub.yCoord = Double(self.endObject.frame.minY)
            connect.initialBegin = self.startObject
            connect.initialFinish = self.endObject
            //connect.initialOrigin = self.startObject.specific
           // connect.initialEnd = self.endObject.specific
            ItemFrames.shared.connections.append(connect)
            print("connect: \(connect.connection), \(connect.origin), \(connect.end), \(connect.beginID), \(connect.finishID)")
            self.start = CGPoint(x: 0.0, y: 0.0)
            self.end = CGPoint(x: 0.0, y: 0.0)
            self.setNeedsDisplay()
        })
        
        /////
        for obj in ItemFrames.shared.frames {
            print("objID: \(obj.uniqueID)")
        }
        
    }
    
    // Dynamically draw the connections. Send highlights to back if necessary. Keeps images at front if present.
    func refresh(begin: CGPoint, stop: CGPoint) {
        
        let point = CGPoint(x: 0.0, y: 0.0)
        
        var objected = false
        
        // If the current line ends in a frame
        for frame in ItemFrames.shared.frames {
            if ((frame.frame.contains(self.end))) {
                objected = true
            }
        }
        
        // If the connecting just ended (begin and end == (0.0, 0.0)) and current line ends in frame
        if ((begin == point) && (stop == point) && (objected == true)) {
            
            // Initially false, if frame contains end of line, will be set to true
            var inObject = false
            
            // If already existing connect label, remove
            for single in self.subviews {
                print(single.tag)
                if (single.tag == 999) {
                    single.removeFromSuperview()
                }
            }
            
            // Created initial input field for connection name
            let newX = CGFloat((self.end.x + self.start.x)/2)
            let newY = CGFloat((self.end.y + self.start.y)/2)
            let labelRect = CGRect(x: newX - 65, y: newY - 30, width: 130, height: 60)
            let labelView = UIView(frame: labelRect)
            labelView.backgroundColor = .yellow
            labelView.tag = 999
            let labelText = UITextField()
            labelText.placeholder = "Enter..."
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
            
            // If frame ends with connect inside, fade away highlights
            for frame in ItemFrames.shared.frames {
                ///////////
                if ((frame.frame.contains(self.start))) {
                    self.startObject = frame
                }
                if ((frame.frame.contains(self.end))) {
                        
                    inObject = true
                    ////////////
                    self.endObject = frame
                    
                    
                    
                        for view in frame.subviews {
                            
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
            // If end and isn't in any object, remove lines
            if (inObject == false) {
                self.start = begin
                self.end = stop
                self.setNeedsDisplay()
            }
            // } match with is (begin) &&
            // If isn't in end, then just set up normally
        } else {
            self.start = begin
            self.end = stop
            ///*
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
            
            
        }
        for frame in ItemFrames.shared.frames {
            if ((frame.frame.contains(self.end))) {
            
                if (frame.bordering == false) {
                    frame.borderView()
                }
            // if this is not the end but still has a border then remove it
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
