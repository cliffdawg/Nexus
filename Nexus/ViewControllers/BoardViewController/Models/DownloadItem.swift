//
//  DownloadItem.swift
//  Nexus
//
//  Created by Clifford Yin on 5/31/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseStorageUI

class DownloadItem {

    var uniqueID: String!
    var imageRef: String!
    var note: String!
    var xCoord: Double!
    var yCoord: Double!
    var image: UIImage!
    var frame: CGRect!
    
    init() {
        
    }
    
    // This is redundant, we'll download image when loading
    func downloadImage(imageURL: String!) {
        let gsReference = Storage.storage().reference(forURL: imageURL)
        gsReference.getData(maxSize: 1 * 2048 * 2048) { data, error in
            if error != nil {
                print("error: \(error)")
            } else {
            print("downloadImage")
            let imaged = UIImage(data: data!)! // Convert image to data
                self.image = self.resizeImage(image: imaged, newWidth: CGFloat(ItemFrames.shared.imageDimension)) as! UIImage
                   
            }
        }
            //Download firebase image link
            self.imageRef = imageURL
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
    
}
