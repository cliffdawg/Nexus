//
//  CenteredTextView.swift
//  Nexus
//
//  Created by Clifford Yin on 4/22/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit

/* Made this so that textView text is centered. */
class CenteredTextView: UITextView {
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}
