//
//  ALCameraViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Photos

public typealias ALCameraViewCompletion = (UIImage?) -> Void

public extension ALCameraViewController {
    public class func imagePickerViewController(croppingEnabled: Bool, completion: ALCameraViewCompletion) -> UINavigationController {
        let imagePicker = PhotoLibraryViewController()
        let navigationController = UINavigationController(rootViewController: imagePicker)
        
        navigationController.navigationBar.barTintColor = UIColor.blackColor()
        navigationController.navigationBar.barStyle = UIBarStyle.Black
        
        imagePicker.onSelectionComplete = { asset in
            if asset != nil {
                let confirmController = ConfirmViewController(asset: asset!, allowsCropping: croppingEnabled)
                confirmController.onComplete = { image in
                    if let i = image {
                        completion(i)
                    } else {
                        imagePicker.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                confirmController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                imagePicker.presentViewController(confirmController, animated: true, completion: nil)
            } else {
                completion(nil)
            }
        }
        
        imagePicker.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "libraryCancel", inBundle: CameraGlobals.shared.bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: imagePicker, action: "dismiss")
        
        return navigationController
    }
}

public class ALCameraViewController: UIViewController {
    
    let cameraView = CameraView()
    let cameraOverlay = CropOverlay()
    let cameraButton = UIButton()
    
    let closeButton = UIButton()
    let swapButton = UIButton()
    let libraryButton = UIButton()
    let flashButton = UIButton()
    
    var onCompletion: ALCameraViewCompletion?
    var allowCropping = false
    
    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    
    lazy var volumeView: MPVolumeView = { [unowned self] in
        let view = MPVolumeView()
        view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        view.alpha = 0.01
        return view
    }()
    
    let volume = AVAudioSession.sharedInstance().outputVolume
    
    public init(croppingEnabled: Bool, allowsLibraryAccess: Bool = true, completion: ALCameraViewCompletion) {
        super.init(nibName: nil, bundle: nil)
        onCompletion = completion
        allowCropping = croppingEnabled
        libraryButton.enabled = allowsLibraryAccess
        libraryButton.hidden = !allowsLibraryAccess
        commonInit()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        try! AVAudioSession.sharedInstance().setActive(false)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        view.addSubview(volumeView)
        view.sendSubviewToBack(volumeView)
        view.addSubview(cameraView)
        
        try! AVAudioSession.sharedInstance().setActive(true)
        
        cameraView.frame = view.bounds
        
        rotate()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "volumeChanged", name: "AVSystemController_SystemVolumeDidChangeNotification", object: nil)
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkPermissions()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        cameraView.frame = view.bounds
        layoutCamera()
    }
    
    internal func rotate() {
        let rotation = currentRotation()
        let rads = CGFloat(radians(rotation))
        
        UIView.animateWithDuration(0.3) {
            self.cameraButton.transform = CGAffineTransformMakeRotation(rads)
            self.closeButton.transform = CGAffineTransformMakeRotation(rads)
            self.swapButton.transform = CGAffineTransformMakeRotation(rads)
            self.libraryButton.transform = CGAffineTransformMakeRotation(rads)
        }
    }
    
    func volumeChanged() {
        guard let slider = volumeView.subviews.filter({ $0 is UISlider }).first as? UISlider else { return }
        slider.setValue(volume, animated: false)
        capturePhoto()
    }
    
    private func commonInit() {
        if UIScreen.mainScreen().bounds.size.width <= 320 {
            verticalPadding = 15
            horizontalPadding = 15
        }
    }

    private func checkPermissions() {
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == AVAuthorizationStatus.Authorized {
            startCamera()
        } else {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted == true {
                        self.startCamera()
                    } else {
                        self.showNoPermissionsView()
                    }
                }
            }
        }
    }
    
    private func showNoPermissionsView() {
        let permissionsView = PermissionsView(frame: view.bounds)
        view.addSubview(permissionsView)
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.setImage(UIImage(named: "retakeButton", inBundle: CameraGlobals.shared.bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        closeButton.sizeToFit()
        
        let size = view.frame.size
        let closeSize = closeButton.frame.size
        let closeX = horizontalPadding
        let closeY = size.height - (closeSize.height + verticalPadding)
        
        closeButton.frame.origin = CGPoint(x: closeX, y: closeY)
    }
    
    private func startCamera() {
        cameraView.startSession()
        
        view.addSubview(cameraButton)
        view.addSubview(libraryButton)
        view.addSubview(closeButton)
        view.addSubview(swapButton)
        view.addSubview(flashButton)
        
        cameraButton.addTarget(self, action: "capturePhoto", forControlEvents: .TouchUpInside)
        swapButton.addTarget(self, action: "swapCamera", forControlEvents: .TouchUpInside)
        libraryButton.addTarget(self, action: "showLibrary", forControlEvents: .TouchUpInside)
        closeButton.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
        flashButton.addTarget(self, action: "toggleFlash", forControlEvents: .TouchUpInside)
        layoutCamera()
    }
    
    private func layoutCamera() {
        
        cameraButton.setImage(UIImage(named: "cameraButton", inBundle: CameraGlobals.shared.bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        cameraButton.setImage(UIImage(named: "cameraButtonHighlighted", inBundle: CameraGlobals.shared.bundle, compatibleWithTraitCollection: nil), forState: .Highlighted)

        closeButton.setImage(UIImage(named: "closeButton", inBundle: CameraGlobals.shared.bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        swapButton.setImage(UIImage(named: "swapButton", inBundle: CameraGlobals.shared.bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        libraryButton.setImage(UIImage(named: "libraryButton", inBundle: CameraGlobals.shared.bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        flashButton.setImage(UIImage(named: "flashAutoIcon", inBundle: CameraGlobals.shared.bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        
        cameraButton.sizeToFit()
        closeButton.sizeToFit()
        swapButton.sizeToFit()
        libraryButton.sizeToFit()
        flashButton.sizeToFit()
        
        if allowCropping {
            layoutCropView()
        } else {
            cameraView.configureFocus()
        }
        
        cameraButton.enabled = true

        let size = view.frame.size
        
        let cameraSize = cameraButton.frame.size
        let cameraX = size.width/2 - cameraSize.width/2
        let cameraY = size.height - (cameraSize.height + verticalPadding)
        
        cameraButton.frame.origin = CGPoint(x: cameraX, y: cameraY)
        cameraButton.alpha = 1
        
        let closeSize = closeButton.frame.size
        let closeX = horizontalPadding
        let closeY = cameraY + (cameraSize.height - closeSize.height)/2
        
        closeButton.frame.origin = CGPoint(x: closeX, y: closeY)
        closeButton.alpha = 1
        
        let librarySize = libraryButton.frame.size
        let libraryX = size.width - (librarySize.width + horizontalPadding)
        let libraryY = closeY
        
        libraryButton.frame.origin = CGPoint(x: libraryX, y: libraryY)
        libraryButton.alpha = 1
        
        let swapSize = swapButton.frame.size
        let swapSpace = libraryX - (cameraX + cameraSize.width)
        var swapX = (cameraX + cameraSize.width) + (swapSpace/2 - swapSize.width/2)
        let swapY = closeY
        
        if libraryButton.hidden {
            swapX = libraryX
        }
        
        swapButton.frame.origin = CGPoint(x: swapX, y: swapY)
        swapButton.alpha = 1
        
        let flashX = libraryX
        let flashY = verticalPadding
        
        flashButton.frame.origin = CGPoint(x: flashX, y: flashY)
    }
    
    private func layoutCropView() {
        
        let size = view.frame.size
        let minDimension = size.width < size.height ? size.width : size.height
        let maxDimension = size.width > size.height ? size.width : size.height
        let width = minDimension - horizontalPadding
        let height = width
        let x = horizontalPadding/2
        
        let cameraButtonY = maxDimension - (verticalPadding + 80)
        let y = cameraButtonY/2 - height/2
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        view.addSubview(cameraOverlay)
        cameraOverlay.frame = frame
    }
    
    internal func capturePhoto() {
        
        guard let output = cameraView.imageOutput, connection = output.connectionWithMediaType(AVMediaTypeVideo) else {
            return
        }
        
        if connection.enabled {
            cameraButton.enabled = false
            cameraView.capturePhoto { image in
                self.saveImage(image)
            }
        }
    }
    
    internal func saveImage(image: UIImage) {
        
        SingleImageSaver()
            .setImage(image)
            .onSuccess { asset in
                self.layoutCameraResult(asset)
            }
            .onFailure { error in
                print(error)
            }
            .save()
    }
    
    internal func close() {
        onCompletion?(nil)
    }
    
    internal func showLibrary() {
        let imagePicker = ALCameraViewController.imagePickerViewController(allowCropping) { image in
            self.dismissViewControllerAnimated(true, completion: nil)
            if image != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.onCompletion?(image!)
                }
            }
        }
        
        imagePicker.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

        presentViewController(imagePicker, animated: true) {
            self.cameraView.stopSession()
        }
    }
    
    internal func onConfirmComplete(image: UIImage?) {
        dismissViewControllerAnimated(true, completion: nil)
        onCompletion?(image)
    }
    
    internal func toggleFlash() {
        if let device = cameraView.device where device.hasFlash {
            do {
                try device.lockForConfiguration()
                if device.flashMode == .On {
                    device.flashMode = .Off
                    toggleFlashButton(.Off)
                } else if device.flashMode == .Off {
                    device.flashMode = .Auto
                    toggleFlashButton(.Auto)
                } else {
                    device.flashMode = .On
                    toggleFlashButton(.On)
                }
                device.unlockForConfiguration()
            } catch _ { }
        }
    }
    
    internal func toggleFlashButton(mode: AVCaptureFlashMode) {
        
        let image: String
        switch mode {
        case .Auto:
            image = "flashAutoIcon"
        case .On:
            image = "flashOnIcon"
        case .Off:
            image = "flashOffIcon"
        }
        
        flashButton.setImage(UIImage(named: image, inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: .Normal)
    }
    
    internal func swapCamera() {
        cameraView.swapCameraInput()
        flashButton.hidden = cameraView.currentPosition == AVCaptureDevicePosition.Front
    }
    
    internal func layoutCameraResult(asset: PHAsset) {
        cameraView.stopSession()
        
        let confirmViewController = ConfirmViewController(asset: asset, allowsCropping: allowCropping)
        
        confirmViewController.onComplete = { image in
            if image == nil {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.onCompletion?(image)
            }
        }
        confirmViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        presentViewController(confirmViewController, animated: true, completion: nil)
    }
}
