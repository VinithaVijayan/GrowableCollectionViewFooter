//
//  ImageCell.swift
//  GrowableCollectionView
//
//  Created by Vinitha Vijayan on 2/13/18.
//  Copyright © 2018 Vinitha Vijayan. All rights reserved.
//

import Foundation
import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var videoIcon: UIImageView!
    
    var media = Media()
    weak var delegate: ViewControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /**
     Set thumbnail image and show video icon if it is video thumbnail.
     */
    
    func setMediaView() {
        self.imageView.image = media.thumbImage
        self.videoIcon.isHidden = media.type == .image ? true : false
    }
    
    //MARK: - IBAction Methods
    
    @IBAction func buttonTapped(_ sender: Any) {
        self.delegate?.removeMedia(media: media)
    }
}
