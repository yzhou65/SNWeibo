//
//  EmoticonViewController.swift
//  Emoticon_keyboard
//
//  Created by Yue Zhou on 2/3/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//


import UIKit

private let YZEmoticonCellReuseIdentifier = "YZEmoticonCellReuseIdentifier"


class EmoticonViewController: UIViewController {
    
    /// the closure is used to pass the selected emoticon
    var emoticonDidSelected: (_ emoticon: Emoticon)->()
    
    init(callBack: @escaping (_ emoticon: Emoticon)->()) {
        self.emoticonDidSelected = callBack
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.red
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(toolbar)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        var cons = [NSLayoutConstraint]()
        let dict = ["collectionView": collectionView, "toolbar": toolbar] as [String : Any]   // indicates what the "collectionView" and "toolbar" represents in the VFL syntax
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolbar]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-[toolbar(44)]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
    }
    
    func itemTap(_ item: UIBarButtonItem) {
//        print(item.tag)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: item.tag), at: UICollectionViewScrollPosition.left, animated: true)
        
    }
    
    // MARK: lazy init
    private lazy var collectionView: UICollectionView = {
        let clv = UICollectionView(frame: CGRect.zero, collectionViewLayout: EmoticonLayout())
        clv.dataSource = self
        clv.delegate = self
        clv.register(EmoticonCell.self, forCellWithReuseIdentifier: YZEmoticonCellReuseIdentifier)
        return clv
    }()
    
    private lazy var toolbar: UIToolbar = {
        let bar = UIToolbar()
        bar.tintColor = UIColor.darkGray
        var items = [UIBarButtonItem]()
        
        var index = 0
        for title in ["Recent", "Default", "Emoji", "浪小花"] {
            let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(itemTap(_:)))
            item.tag = index
            index += 1
            items.append(item)
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        bar.items = items
        return bar
    }()
    
    ///
    fileprivate lazy var packages: [EmoticonPackage] = EmoticonPackage.packageList
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension EmoticonViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YZEmoticonCellReuseIdentifier, for: indexPath) as! EmoticonCell
        cell.backgroundColor = (indexPath.item % 2 == 0) ? UIColor.red : UIColor.green
        
        // set data
        let package = packages[indexPath.section]
        let emoticon = package.emoticons![indexPath.item]
        cell.emoticon = emoticon
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // add the lately used emoticons to "Recent"
        let emoticon = packages[indexPath.section].emoticons![indexPath.item]
        emoticon.freq += 1
        packages[0].appendEmoticons(emoticon: emoticon)
//        collectionView.reloadSections(IndexSet.init(integer: 0))
        
        emoticonDidSelected(emoticon)
//        print(emoticon.chs ?? "---")
    }
}


/// Customized emoticon view cell
class EmoticonCell: UICollectionViewCell {
    
    var emoticon: Emoticon? {
        didSet {
            if emoticon!.chs != nil {
                iconButton.setImage(UIImage(contentsOfFile: emoticon!.imagePath!), for: UIControlState.normal)
            } else {
                // avoid re-use
                iconButton.setImage(nil, for: UIControlState.normal)
            }
            
            // set emoji. To avoid re-use, add  ?? ""
            iconButton.setTitle(emoticon!.emojiStr ?? "", for: UIControlState.normal)
            
            // whether it is a "remove" button
            if emoticon!.isRemoveButton {
                iconButton.setImage(UIImage(named: "compose_emotion_delete"), for: UIControlState.normal)
                iconButton.setImage(UIImage(named: "compose_emotion_delete_highlighted"), for: UIControlState.highlighted)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /**
     * initializes UI
     */
    private func setupUI() {
        contentView.addSubview(iconButton)
        iconButton.backgroundColor = UIColor.white
        iconButton.frame = contentView.bounds.insetBy(dx: 4, dy: 4)
        iconButton.isUserInteractionEnabled = false
    }
    
    // MARK: lazy init
    private lazy var iconButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        return btn
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/// Customized emoticon view layout
class EmoticonLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        let width = collectionView!.bounds.width / 7
        itemSize = CGSize(width: width, height: width)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
        
        // let the two inner edges be at the upper and lower bounds
        // note if * 0.5, there is no effect on iphone 4/4s
        let y = (collectionView!.bounds.height - 3 * width) * 0.48
        collectionView?.contentInset = UIEdgeInsetsMake(y, 0, y, 0)
    }
}
