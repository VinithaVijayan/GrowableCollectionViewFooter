//
//  ViewController.swift
//  GrowableCollectionView
//
//  Created by Vinitha Vijayan on 2/6/18.
//  Copyright © 2018 Vinitha Vijayan. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

protocol ViewControllerDelegate: class {
    func presentImagePicker()
    func removeMedia(media: Media)
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomConstarint: NSLayoutConstraint!
    
    var footerView: FooterView?
    var mediaArray = [Media]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let name = NSNotification.Name(rawValue:"UpdateHeightNotification")
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(reloadFooterView),
                                       name: name,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillAppear(_:)),
                                       name: NSNotification.Name.UIKeyboardWillShow,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillDisappear(_:)),
                                       name: NSNotification.Name.UIKeyboardWillHide,
                                       object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath)
        cell.backgroundColor = UIColor.lightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case "UICollectionElementKindSectionFooter" :
            if let _ = footerView {
                return footerView!
            } else {
                footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterViewID", for: indexPath) as? FooterView
                footerView?.delegate = self
                return footerView!
            }
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        var textHeight: CGFloat = 0.0
        
        if let view = footerView {
            textHeight = view.textView.frame.size.height
            textHeight += mediaArray.count > 0 ? 125 : 50
        }
        
        return CGSize(width: collectionView.frame.size.width, height: textHeight > 200 ? textHeight : 200)
    }
    
    /**
     Remove the deleted picture/video from media Array and reload footerview
     - parameter media: Picture/Video to be removed
     */
    
    func removeMedia(media: Media) {
        self.mediaArray = mediaArray.filter { $0.data != media.data }
        self.reloadFooterView()
    }
    
    /**
     Present the image picker
     */
    
    func presentImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: {})
        }
    }
    
    /**
     Create thumbnail image from the Video url
     - parameter url: URL of the video
     - returns UIImage: An optional thumbnail image created from video url
     */
    
    private func thumbnailForVideoAtURL(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("error")
            return nil
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let type = info[UIImagePickerControllerMediaType] as? String {
            if type == "public.image" {
                guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                    return
                }
                
                let data = UIImagePNGRepresentation(image)
                let media = Media(type: .image, thumbImage: image, data: data!)
                self.mediaArray.append(media)
                
            } else if type == "public.movie" {
                guard let url = info[UIImagePickerControllerMediaURL] as? URL else {
                    return
                }
                
                if let image = self.thumbnailForVideoAtURL(url: url) {
                    let data = try? Data(contentsOf: url)
                    let media = Media(type: .video, thumbImage: image, data: data!)
                    self.mediaArray.append(media)
                }
            }
        }
        
        self.reloadFooterView()
        self.dismiss(animated: true, completion: {})
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    }
    
    //MARK: - Notification Methods
    
    /**
     Reload the collectionView footerView
     */
    
    @objc func reloadFooterView() {
        footerView?.mediaArray = self.mediaArray
        footerView?.imageCollectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.scrollRectToVisible((footerView?.button.frame)!, animated: true)
    }
    
    /**
     Reduce the ColletionView height
     */
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        let rawFrame = value.cgRectValue
        let keyboardFrame = view.convert(rawFrame!, from: nil)
        let heightDifference = self.view.frame.size.height - keyboardFrame.origin.y
        self.bottomConstarint.constant = heightDifference + 20
        self.collectionView.scrollRectToVisible((footerView?.button.frame)!, animated: true)
    }
    
    /**
     Increase the ColletionView height
     */
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        self.bottomConstarint.constant = 35
    }
}

class Cell: UICollectionViewCell {
    
}
