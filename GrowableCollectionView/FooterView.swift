//
//  FooterView.swift
//  GrowableCollectionView
//
//  Created by Vinitha Vijayan on 2/13/18.
//  Copyright © 2018 Vinitha Vijayan. All rights reserved.
//

import UIKit

class FooterView: UICollectionReusableView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var textView: TextViewAutoHeight!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var button: UIButton!
    
    weak var delegate: ViewControllerDelegate?
    var mediaArray = [Media]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.delegate = self
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
    }

    //MARK: - UICollectionViewDataSource Methods

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = self.mediaArray[indexPath.row]
        let cell = self.imageCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellID", for: indexPath as IndexPath) as! ImageCell
        cell.delegate = self.delegate
        cell.media = media
        cell.setMediaView()
        return cell
    }
    
    //MARK: - IBAction Methods

    @IBAction func openCameraButton(sender: AnyObject) {
        self.delegate?.presentImagePicker()
    }
}
