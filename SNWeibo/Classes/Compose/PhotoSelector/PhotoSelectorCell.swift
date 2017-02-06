//
//  PhotoSelectorCell.swift
//  PhotoUploader
//
//  Created by Yue Zhou on 2/5/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

@objc
protocol PhotoSelectorCellDelegate: NSObjectProtocol {
    @objc optional func photoDidSelect(cell: PhotoSelectorCell)
    @objc optional func photoDidRemove(cell: PhotoSelectorCell)
}

class PhotoSelectorCell: UICollectionViewCell {
    
    var photoCellDelegate: PhotoSelectorCellDelegate?
    
    var image: UIImage? {
        didSet {
            if image != nil {
                addButton.setBackgroundImage(image, for: UIControlState.normal)
                removeButton.isHidden = false
                addButton.isUserInteractionEnabled = false
            } else {
                removeButton.isHidden = true
                addButton.setBackgroundImage(UIImage(named: "compose_pic_add"), for: UIControlState.normal)
                addButton.isUserInteractionEnabled = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(addButton)
        contentView.addSubview(removeButton)
        
        
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        var cons = [NSLayoutConstraint]()
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[addButton]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["addButton": addButton])
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[addButton]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["addButton": addButton])
        
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:[removeButton]-2-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["removeButton": removeButton])
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[removeButton]", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["removeButton": removeButton])
        
        
        contentView.addConstraints(cons)
    }
    
    func removeBtnTap() {
        photoCellDelegate?.photoDidRemove!(cell: self)
    }
    
    func addBtnTap() {
        photoCellDelegate?.photoDidSelect!(cell: self)
    }
    
    // MARK: lazy init
    /// "Remove" cross-shaped btn
    private lazy var removeButton: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.setImage(UIImage(named: "compose_photo_close"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(removeBtnTap), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    /// "Add" plus-shaped button
    private lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        btn.setImage(UIImage(named: "compose_pic_add"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(addBtnTap), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
