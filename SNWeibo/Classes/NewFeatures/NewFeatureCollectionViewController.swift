//
//  NewFeatureCollectionViewController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/25/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class NewFeatureCollectionViewController: UICollectionViewController {
    /// layout
    private var layout: NewFeatureLayout = NewFeatureLayout()
    
    /// new feature has 4 pages
    private let pageCount = 4
    
    /**
     * No need to indicate override because the default init() has layout as its argument
     */
    init() {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(NewFeatureCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: UICollectionViewDataSource

    /**
     * Indicates the number of cells
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NewFeatureCell
    
        // Configure the cell
        cell.imageIndex = indexPath.item
        return cell
    }
    
    /**
     * Called after completely displaying a cell
     */
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // get current cell's indexPath
        let indexPath = collectionView.indexPathsForVisibleItems.last!
        
        if indexPath.item == (pageCount - 1) {
            let cell = collectionView.cellForItem(at: indexPath) as! NewFeatureCell
            
            // run the animation
            cell.startBtnAnimation()
        }
    }
}

private class NewFeatureCell: UICollectionViewCell {
    /// defines a variable for the index of a new feature image
    fileprivate var imageIndex: Int? {
        didSet {
            iconView.image = UIImage(named: "new_feature_\(imageIndex! + 1)")
            
        }
    }
    
    /**
     * The animation of appearance of the startBtn
     */
    func startBtnAnimation() {
        startButton.isHidden = false
        
        // startButton's animation
        startButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        startButton.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 3.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.startButton.transform = CGAffineTransform.identity
        }, completion: { (_) in
            self.startButton.isUserInteractionEnabled = true
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // init UI
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startBtnClick() {
//        print(#function)
        // turn to home page. The notification bring along the object "true"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YZSwitchRootViewControllerKey), object: true)
    }
    
    private func setupUI() {
        // add subviews
        contentView.addSubview(iconView)
        contentView.addSubview(startButton)
        
        // set the layout
        iconView.xmg_Fill(contentView)
        startButton.xmg_AlignInner(type: XMG_AlignType.bottomCenter, referView: contentView, size: nil, offset: CGPoint(x: 0, y: -150))
    }
    
    // MARK: lazy init
    private lazy var iconView = UIImageView()
    private lazy var startButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named: "new_feature_button"), for: UIControlState.normal)
        btn.setBackgroundImage(UIImage(named: "new_feature_button_highlighted"), for: UIControlState.highlighted)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(startBtnClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
}

private class NewFeatureLayout: UICollectionViewFlowLayout {
    /**
     * Called after "numberOfItemsInSection" method.
     */
    fileprivate override func prepare() {
        itemSize = UIScreen.main.bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
        collectionView?.isPagingEnabled = true
    }
}
