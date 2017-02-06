//
//  PhotoSelectorViewController.swift
//  PhotoUploader
//
//  Created by Yue Zhou on 2/5/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

private let YZPhotoSelectorCellReuseIdentifier = "YZPhotoSelectorCellReuseIdentifier"

class PhotoSelectorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        // lay out subviews
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var cons = [NSLayoutConstraint]()
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["collectionView": collectionView])
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["collectionView": collectionView])
        view.addConstraints(cons)
    }

    // MARK: lazy init
    fileprivate lazy var collectionView: UICollectionView = {
        let clv = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoSelectorViewLayout())
        clv.dataSource = self
        clv.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: YZPhotoSelectorCellReuseIdentifier)
        return clv
    }()
    
    lazy var photoImages = [UIImage]()
}


extension PhotoSelectorViewController: UICollectionViewDataSource, PhotoSelectorCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // the "plus" shaped selector's count always = photoImages' count + 1
        return photoImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YZPhotoSelectorCellReuseIdentifier, for: indexPath) as! PhotoSelectorCell
        cell.backgroundColor = UIColor.green
        cell.photoCellDelegate = self
        
        cell.image = (photoImages.count == indexPath.item) ? nil : photoImages[indexPath.item]
        
        return cell
    }
    
    // MARK: PhotoSelectorCellDelegate
    func photoDidSelect(cell: PhotoSelectorCell) {
        /**
         * case photoLibrary: cannot be deleted
            case savedPhotosAlbum: customized album that can be deleted
            case camera
         */
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            print("Error. Failed to open the photo album")
            return
        }
        
        let vc = UIImagePickerController()
        vc.delegate = self
        
        // allow user to edit the photo
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    func photoDidRemove(cell: PhotoSelectorCell) {
        let indexPath = collectionView.indexPath(for: cell)!
        
        photoImages.remove(at: indexPath.item)
        collectionView.reloadData()
    }
    
    // MARK: UIImagePickerControllerDelegate
    /**
     * Called when finishing picking a still photo or a video
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            let newImage = image.imageWithScale(width: 300)
//            photoImages.append(newImage)
//            collectionView.reloadData()
//        } else {
//            print("Error occurred")
//        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Error. Failed to select an image.")
            return
        }
        let newImage = image.imageWithScale(width: 300)
        photoImages.append(newImage)
        collectionView.reloadData()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}


class PhotoSelectorViewLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        itemSize = CGSize(width: 80, height: 80)
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
