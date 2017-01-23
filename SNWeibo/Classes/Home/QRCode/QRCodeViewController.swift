//
//  QRCodeViewController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/22/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, UITabBarDelegate {
    
    /// scan line's top constraint
    @IBOutlet weak var scanLineCons: NSLayoutConstraint!
    
    /// scansuperView's constrainted height
    @IBOutlet weak var containerHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var scanLineView: UIImageView!
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /// bottom tabBar
    @IBOutlet weak var customTabBar: UITabBar!
    
    /// result label upon scanning
    @IBOutlet weak var resultLabel: UILabel!
    
    /// My QR Code button's click callback
    @IBAction func myQRCodeClick(_ sender: Any) {
        let vc = QRCodeCardViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    // MARK: methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. QRCode item on the tabbar is selected at default
        customTabBar.selectedItem = customTabBar.items![0]
        customTabBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // start the scanline animation
        startAnimation()
        
        // start scanning
        startScanning()
    }
    
    // MARK: - UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // adjust containerView's height
        if item.tag == 1 {
            self.containerHeightCons.constant = 200
        } else {
            self.containerHeightCons.constant = 100
        }
        
        // Because containerHeightCons is different on QRCode and BarCode mode, previous animation should be stopped so that scanLine starts from top of containerView every time
        self.scanLineView.layer.removeAllAnimations()
        
        // restart animation
        startAnimation()
    }
    
    // MARK: inner control methods
    /**
     * start the scan line animation
     */
    private func startAnimation() {
        self.scanLineCons.constant = -self.containerHeightCons.constant
        self.scanLineView.layoutIfNeeded()
        
        // animate
        UIView.animate(withDuration: 2.0, animations: {
            self.scanLineCons.constant = 0
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.scanLineView.layoutIfNeeded()
        })
    }
    
    private func startScanning() {
        // check whether it is possible to add deviceInput into session
        if !session.canAddInput(deviceInput) {
            return
        }
        
        // check whether it is possible to add output into session
        if !session.canAddOutput(output) {
            return
        }
        
        // add deviceInput and output into session
        session.addInput(deviceInput)
        session.addOutput(output)
        
        // output parsable data. This must follow session.addOutput() and must not be ahead of session.addOuput()
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // set delegate
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // if multiple QRCodes/BarCodes is in the font and only wants to scan one of them, the system's code scanning cannnot achieve. It can only achieve that scan the code when it is at a specific area by using rectOfInterest
//        output.rectOfInterest = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        // insert preview layer and stack drawCorner layer on preview layer
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.addSublayer(drawLayer)
        
        // tell session to scan
        session.startRunning()
    }
    
    // MARK: lazy init
    // QRCode and BarCode session
    private lazy var session: AVCaptureSession = AVCaptureSession()
    
    // input
    private lazy var deviceInput: AVCaptureDeviceInput? = {
        // get the camera
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        } catch {
            print(error)
            return nil  // deviceInput should be :AVCaptureDeviceInput?, otherwise cannot be assigned nil
        }
    }()
    
    // output
    private lazy var output: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    // preview layer
    fileprivate lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        // note: in closure, member variable can only be visited by using self.xxx
        let layer = AVCaptureVideoPreviewLayer(session: self.session)!
        layer.frame = UIScreen.main.bounds
        return layer
    }()
    
    // the layer for drawing the corners of a QRCode/BarCode scanned
    fileprivate lazy var drawLayer: CALayer = {
        let layer = CALayer()
        layer.frame = UIScreen.main.bounds
        return layer
    }()
}

extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    /**
     * Called when successfully parsing scanned QRCode/BarCode
     */
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Clear previously drawn corners of scanned QRCode/BarCode
        clearPreviousCorners()
        
        // get data upon scanning
        resultLabel.text = metadataObjects.last as? String
        resultLabel.sizeToFit()
        
        // get QRCode/BarCode's location
        for object in metadataObjects {
            if object is AVMetadataMachineReadableCodeObject {
                // converted into iOS view's coordinate
                let codeObject = previewLayer.transformedMetadataObject(for: object as! AVMetadataObject) as! AVMetadataMachineReadableCodeObject
//                print(codeObject)
                
                // draw QRCode/BarCode frame corners once it is read
                drawCorners(codeObject)
            }
        }
    }
    
    /**
     * draw QRCode/BarCode frame corners once it is read
     */
    private func drawCorners(_ codeObject: AVMetadataMachineReadableCodeObject) {
        // if no QRCode/BarCode is found, return
        if codeObject.corners.isEmpty {
            return
        }
        
        // init layer
        let layer = CAShapeLayer()
        layer.lineWidth = 4
        layer.strokeColor = UIColor.green.cgColor
        layer.fillColor = UIColor.clear.cgColor
        
//        layer.path = UIBezierPath(rect: CGRect(x: 100, y: 100, width: 200, height: 200)).cgPath
        
        let path = UIBezierPath()
        var point = CGPoint.zero
        var index: Int = 0
        // move to the first point
        point = CGPoint(dictionaryRepresentation: (codeObject.corners[index] as! CFDictionary))!
        index += 1
        path.move(to: point)
        
        // move to other points
        while index < codeObject.corners.count {
            point = CGPoint(dictionaryRepresentation: (codeObject.corners[index] as! CFDictionary))!
            index += 1
            path.addLine(to: point)
        }
        
        // close the path
        path.close()
        
        // draw the path
        layer.path = path.cgPath
        
        // add layer
        drawLayer.addSublayer(layer)
    }
    
    /**
     * Clear previously drawn corners upon the success read of a QRCode/BarCode
     */
    private func clearPreviousCorners() {
        if drawLayer.sublayers == nil || drawLayer.sublayers?.count == 0 {
            return
        }
        
        for sublayer in drawLayer.sublayers! {
            sublayer.removeFromSuperlayer()
        }
    }
}


