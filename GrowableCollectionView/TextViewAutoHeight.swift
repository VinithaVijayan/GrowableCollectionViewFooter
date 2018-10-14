//
//  TextViewAutoHeight.swift
//  GrowableCollectionView
//
//  Created by Vinitha Vijayan on 2/7/18.
//  Copyright © 2018 Vinitha Vijayan. All rights reserved.
//

import Foundation

import UIKit

class TextViewAutoHeight: UITextView {
    
    var height: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isScrollEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(updateHeight), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    //MARK: - Notification Methods
    
    /**
     Update the textView height with the text content
     */
    
    @objc func updateHeight() {
        var newFrame = frame
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        if height != newFrame.height && newFrame.height > 90.0 {
            let name = NSNotification.Name(rawValue:"UpdateHeightNotification")
            NotificationCenter.default.post(name: name, object: nil)
            self.frame = newFrame
        }
    }
}
