//
//  PhotoBrowserController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/30/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

private let photoBrowserCellReuseIdentifier = "photoCell"

class PhotoBrowserController: UIViewController {
    
    var currentIndex: Int = 0
    var pictureURLs: [URL]?
    
    init(index: Int, urls: [URL]) {
        currentIndex = index
        pictureURLs = urls
        
        // super.init should follow the above two assignments. The current class should initialize at first
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white    // viewController's view at default is clear-colored
        setupUI()
        
    }
    
    private func setupUI() {
        // add subviews
        view.addSubview(collectionView)
        view.addSubview(closeBtn)
        view.addSubview(saveBtn)
        
        // lay out subviews
        _ = collectionView.frame = UIScreen.main.bounds
        _ = closeBtn.xmg_AlignInner(type: XMG_AlignType.bottomLeft, referView: view, size: CGSize(width: 100, height: 35), offset: CGPoint(x: 10, y: -10))
        _ = saveBtn.xmg_AlignInner(type: XMG_AlignType.bottomRight, referView: view, size: CGSize(width: 100, height: 35), offset: CGPoint(x: -10, y: -10))
        
        // dataSource and cell registration
        collectionView.dataSource = self
        collectionView.register(PhotoBrowserCell.self, forCellWithReuseIdentifier: photoBrowserCellReuseIdentifier)
    }
    
    // MARK: buttons' callbacks
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func save() {
        print(#function)
    }

    // MARK: lazy init
    private lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Close", for: UIControlState.normal)
        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
        btn.backgroundColor = UIColor.darkGray
        btn.addTarget(self, action: #selector(close), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    private lazy var saveBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Save", for: UIControlState.normal)
        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
        btn.backgroundColor = UIColor.darkGray
        btn.addTarget(self, action: #selector(save), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserLayout())
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UICollectionViewDataSource
extension PhotoBrowserController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureURLs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoBrowserCellReuseIdentifier, for: indexPath) as! PhotoBrowserCell
        cell.backgroundColor = UIColor.randomColor()
        cell.imageURL = pictureURLs![indexPath.item]
        
        return cell
    }
}

class PhotoBrowserLayout: UICollectionViewFlowLayout {
    override func prepare() {
        itemSize = UIScreen.main.bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
    }
}
