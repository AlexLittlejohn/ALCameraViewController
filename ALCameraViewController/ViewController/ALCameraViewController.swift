//
//  ALCameraViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

public typealias CameraViewCompletion = (UIImage?, PHAsset?) -> Void

public extension ALCameraViewController {
    public class func imagePickerViewController(croppingEnabled: Bool, completion: CameraViewCompletion) -> UINavigationController {
        let imagePicker = PhotoLibraryViewController()
        let navigationController = UINavigationController(rootViewController: imagePicker)
        
        navigationController.navigationBar.barTintColor = UIColor.blackColor()
        navigationController.navigationBar.barStyle = UIBarStyle.Black
        
        imagePicker.onSelectionComplete = { asset in
            if let asset = asset {
                let confirmController = ConfirmViewController(asset: asset, allowsCropping: croppingEnabled)
                confirmController.onComplete = { image, asset in
                    if let image = image, asset = asset {
                        completion(image, asset)
                    } else {
                        imagePicker.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                confirmController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                imagePicker.presentViewController(confirmController, animated: true, completion: nil)
            } else {
                completion(nil, nil)
            }
        }
        
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
    
    var onCompletion: CameraViewCompletion?
    var allowCropping = false
    
    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    
    var volumeControl: VolumeControl?
    
    
    public init(croppingEnabled: Bool, allowsLibraryAccess: Bool = true, completion: CameraViewCompletion) {
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cameraReady), name: AVCaptureSessionDidStartRunningNotification, object: nil)
        
        view.backgroundColor = UIColor.blackColor()
        view.addSubview(cameraView)

        cameraButton.enabled = false
        
        volumeControl = VolumeControl(view: view) { _ in
            self.capturePhoto()
        }
        
        checkPermissions()
        rotate()
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraView.startSession()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        cameraView.frame = view.bounds
        layoutCamera()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if cameraView.session?.running == true {
            cameraReady()
        }
    }
    
    internal func cameraReady() {
        cameraButton.enabled = true
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
    
    private func showNoPermissionsView(library: Bool = false) {
        let permissionsView = PermissionsView(frame: view.bounds)
        
        let title: String
        let desc: String
        
        if library {
            title = localizedString("permissions.library.title")
            desc = localizedString("permissions.library.description")
        } else {
            title = localizedString("permissions.title")
            desc = localizedString("permissions.description")
        }
        
        permissionsView.configureInView(view, title: title, descriptiom: desc, completion: close)
    }
    
    private func startCamera() {
        view.addSubview(cameraButton)
        view.addSubview(libraryButton)
        view.addSubview(closeButton)
        view.addSubview(swapButton)
        view.addSubview(flashButton)
        
        cameraButton.addTarget(self, action: #selector(ALCameraViewController.capturePhoto), forControlEvents: .TouchUpInside)
        swapButton.addTarget(self, action: #selector(ALCameraViewController.swapCamera), forControlEvents: .TouchUpInside)
        libraryButton.addTarget(self, action: #selector(ALCameraViewController.showLibrary), forControlEvents: .TouchUpInside)
        closeButton.addTarget(self, action: #selector(ALCameraViewController.close), forControlEvents: .TouchUpInside)
        flashButton.addTarget(self, action: #selector(ALCameraViewController.toggleFlash), forControlEvents: .TouchUpInside)
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
        let minDimension = min(size.width, size.height)
        let maxDimension = max(size.width, size.height)
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
            closeButton.enabled = false
            swapButton.enabled = false
            
            cameraView.capturePhoto { image in
                
                guard let image = image else {
                    self.cameraButton.enabled = true
                    self.closeButton.enabled = true
                    self.swapButton.enabled = true
                    return
                }
                
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
                self.cameraButton.enabled = true
                self.closeButton.enabled = true
                self.swapButton.enabled = true
                self.showNoPermissionsView(true)
            }
            .save()
    }
    
    internal func close() {
        onCompletion?(nil, nil)
    }
    
    internal func showLibrary() {
        let imagePicker = ALCameraViewController.imagePickerViewController(allowCropping) { image, asset in
            self.dismissViewControllerAnimated(true, completion: nil)
            
            guard let image = image, asset = asset else {
                return
            }
            
            self.onCompletion?(image, asset)
        }
        
        imagePicker.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

        presentViewController(imagePicker, animated: true) {
            self.cameraView.stopSession()
        }
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
        
        confirmViewController.onComplete = { image, asset in
            if let image = image, asset = asset {
                self.onCompletion?(image, asset)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        confirmViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        presentViewController(confirmViewController, animated: true, completion: nil)

        cameraButton.enabled = true
        closeButton.enabled = true
        swapButton.enabled = true
    }
}
