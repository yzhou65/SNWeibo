//
//  PhotoBrowserCell.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/30/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import SDWebImage

protocol PhotoBrowserCellDelegate: NSObjectProtocol {
    func photoBrowserCellDidClose(cell: PhotoBrowserCell)
}

class PhotoBrowserCell: UICollectionViewCell {
    
    weak var photoBrowserCellDelegate: PhotoBrowserCellDelegate?
    
    var imageURL: URL? {
        didSet {
            reset()
            
            iconView.sd_setImage(with: imageURL) { (image, _, _, _) in
                // display the image at proper position
                self.setImagePosition()
            }
        }
    }
    
    /**
     * reset scrollView and imageView's properties
     */
    private func reset() {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset =  CGPoint.zero
        scrollView.contentSize = CGSize.zero
        
        iconView.transform = CGAffineTransform.identity
    }
    
    /**
     * Adjusts image's displaying position
     */
    private func setImagePosition() {
        let size = self.displaySize(image: iconView.image!)
        
        // for a short image
        if size.height < UIScreen.main.bounds.height {
            iconView.frame = CGRect(origin: CGPoint.zero, size: size)
            
            // centerally align the image
            let y = (UIScreen.main.bounds.height - size.height) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: y, right: 0)
        }
        else {  // for a long image
            iconView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView.contentSize = size
        }
    }
    
    /**
     * Displays an image based on proper width/height ratio
     */
    private func displaySize(image: UIImage) -> CGSize {
        let ratio = image.size.height / image.size.width
        let width = UIScreen.main.bounds.width
        let height = width * ratio
        return CGSize(width: width, height: height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(iconView)
        
        scrollView.frame = UIScreen.main.bounds
        
        // zoom
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 0.5
        
        // set tap gesture to the iconView so that tapping the image can dismiss the controller
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        iconView.addGestureRecognizer(tap)
        iconView.isUserInteractionEnabled = true
    }
    
    /**
     * Close the photo browser controller
     */
    func close() {
        photoBrowserCellDelegate?.photoBrowserCellDidClose(cell: self)
    }
    
    // MARK: lazy init
    private lazy var scrollView: UIScrollView = UIScrollView()
    
    lazy var iconView: UIImageView = UIImageView()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension PhotoBrowserCell: UIScrollViewDelegate {
    /**
     * Returns the view that needs zooming
     */
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return iconView
    }
    
    /**
     * Called when done with zooming
     * view: the view being zoomed
     */
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print(#function)
        
        var offsetX = (UIScreen.main.bounds.width - view!.frame.width) * 0.5
        var offsetY = (UIScreen.main.bounds.height - view!.frame.height) * 0.5
//        print("offsetX = \(offsetX), offsetY = \(offsetY)")
        
        offsetX = offsetX < 0 ? 0 : offsetX
        offsetY = offsetY < 0 ? 0 : offsetY
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
