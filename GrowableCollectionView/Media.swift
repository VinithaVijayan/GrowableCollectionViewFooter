//
//  Media.swift
//  GrowableCollectionView
//
//  Created by Vinitha Vijayan on 2/13/18.
//  Copyright © 2018 Vinitha Vijayan. All rights reserved.
//

import Foundation
import UIKit

enum MediaType {
    case video
    case image
}

class Media {
    var type: MediaType = .image
    var thumbImage = UIImage()
    var data = Data()
    
    init() {}
    
    init(type: MediaType, thumbImage: UIImage, data: Data) {
        self.type = type
        self.thumbImage = thumbImage
        self.data = data
    }
}
