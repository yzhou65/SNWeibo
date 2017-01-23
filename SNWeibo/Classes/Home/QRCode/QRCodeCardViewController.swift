//
//  QRCodeCardViewController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/23/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class QRCodeCardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.green
        
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.text = "My QR Code"
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        view.addSubview(iconView)
        
        iconView.xmg_AlignInner(type: XMG_AlignType.center, referView: view, size: CGSize(width: 200, height: 200))
        iconView.backgroundColor = UIColor.red
        
        let qrcodeImage = createQRCodeImage()
        iconView.image = qrcodeImage
    }
    
    /**
     * Create a QR code image
     */
    private func createQRCodeImage() -> UIImage? {
        // create filter
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        filter?.setValue("Barney8812".data(using: String.Encoding.utf8), forKey: "inputMessage")
        
        // get the image from filter
        let ciImage = filter?.outputImage
//        return UIImage(ciImage: ciImage!) // this only creates a opaque image
        let bgImage = createNonInterpolatedUIImageFromCIImage(image: ciImage!, size: 300)
        
        // create a profile image
        let icon = UIImage(named: "nange.jpg")
        
        // synthesize an image with QRCode
        let newImage = synthesizeImage(bgImage: bgImage, iconImage: icon!)
        return newImage
    }
    
    // MARK: inner control methods
    private func synthesizeImage(bgImage: UIImage, iconImage: UIImage) -> UIImage {
        // begin context
        UIGraphicsBeginImageContext(bgImage.size)
        bgImage.draw(in: CGRect(origin: CGPoint.zero, size: bgImage.size))
        
        // draw the profile image
        let width: CGFloat = 50
        let height = width
        let x = (bgImage.size.width - width) * 0.5
        let y = (bgImage.size.height - height) * 0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        
        // upon drawing, get new image
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private func createNonInterpolatedUIImageFromCIImage(image: CIImage, size: CGFloat) -> UIImage {
        let extent: CGRect = image.extent.integral
        // Before Swift 3.0: CGRectGetWidth(extent), CGRectGetHeight(extent)
        let scale: CGFloat = min(size/extent.width, size/extent.height)
        
        // create a bitmap
        let width = extent.width * scale
        let height = extent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext.init(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: extent)!
        bitmapRef!.interpolationQuality = CGInterpolationQuality.none
        bitmapRef!.scaleBy(x: scale, y: scale)
        bitmapRef!.draw(bitmapImage, in: extent)
        
        // save bitmap to image
        let scaledImage: CGImage = bitmapRef!.makeImage()!
        
        return UIImage(cgImage: scaledImage)
    }

    // MARK: lazy init
    private lazy var iconView: UIImageView = UIImageView()
}
