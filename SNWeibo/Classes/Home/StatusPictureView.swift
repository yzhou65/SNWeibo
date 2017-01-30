//
//  StatusPictureView.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/28/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import SDWebImage

class StatusPictureView: UICollectionView {
    /// Status object
    var status: Status? {
        didSet {
            // refresh the table
            reloadData()
        }
    }
    
    
    /// pictures' layout
    private var pictureLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    init() {
        super.init(frame: CGRect.zero, collectionViewLayout: pictureLayout)
        
        // register a cell
        register(PictureViewCell.self, forCellWithReuseIdentifier: YZPictureViewCellReuseIdentifier)
        
        // set cell margin
        pictureLayout.minimumInteritemSpacing = 10
        pictureLayout.minimumLineSpacing = 10
        
        // set background color
        backgroundColor = UIColor.darkGray
        
        // set dataSource and delegate
        dataSource = self
        delegate = self
    }
    
    /**
     * Computes a status's image(s) dimension
     */
    func calculateImageSize() -> CGSize {
        let count = status?.storedPicURLs?.count
        if count == 0 || count == nil {
            return (CGSize.zero)
        }
        
        // only one image, then return its original size
        if count == 1 {
            let key = status?.storedPicURLs?.first?.absoluteString
            let image = SDWebImageManager.shared().imageCache.imageFromDiskCache(forKey: key!)!
            pictureLayout.itemSize = image.size
            return (image.size)
        }
        
        // if there are 4 images
        let width = 90
        let margin = 10
        pictureLayout.itemSize = CGSize(width: width, height: width)
        if count == 4 {
            let viewWH = width * 2 + margin
            return (CGSize(width: viewWH, height: viewWH))
        }
        
        // if there are > 4 images
        let colNumber = 3
        let rowNumber = (count! - 1) / colNumber + 1
        let viewWidth = colNumber * width + (colNumber - 1) * margin
        let viewHeight = rowNumber * width + (rowNumber - 1) * margin
        return (CGSize(width: viewWidth, height: viewHeight))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate class PictureViewCell: UICollectionViewCell {
        
        /// image's url
        var imageURL: URL? {
            didSet {
                iconImageView.sd_setImage(with: imageURL)
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            // init UI
            setupUI()
        }
        
        private func setupUI() {
            contentView.addSubview(iconImageView)
            _ = iconImageView.xmg_Fill(contentView)
        }
        
        // MARK: lazy init
        private lazy var iconImageView: UIImageView = UIImageView()
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate

/// the notification of a picture being selected
let YZStatusPictureViewSelected = "YZStatusPictureViewSelected"
/// the currently selected picture's index key
let YZStatusPictureViewIndexKey = "YZStatusPictureViewIndexKey"
/// the currently selected picture's url key
let YZStatusPictureViewURLsKey = "YZStatusPictureViewURLsKey"

extension StatusPictureView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return status?.storedPicURLs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YZPictureViewCellReuseIdentifier, for: indexPath) as! PictureViewCell
        
        cell.imageURL = status?.storedPicURLs![indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(status?.storedLargePicURLs![indexPath.item])
        let infoDict = [YZStatusPictureViewIndexKey: indexPath, YZStatusPictureViewURLsKey: (status?.storedLargePicURLs)!] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(YZStatusPictureViewSelected), object: self, userInfo: infoDict)
    }
}

