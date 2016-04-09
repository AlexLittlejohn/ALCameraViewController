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

public extension CameraViewController {
    public class func imagePickerViewController(croppingEnabled: Bool, imagePickerDelegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>?, completion: CameraViewCompletion) -> UINavigationController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        //        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        imagePicker.allowsEditing = false
        imagePicker.delegate = imagePickerDelegate
        
        imagePicker.navigationBar.barTintColor = UIColor(red: 0/255, green: 42/255, blue: 79/255, alpha: 1.0)
        imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "Avenir", size: 18.0)!]
        imagePicker.navigationBar.tintColor = UIColor.whiteColor()
        imagePicker.navigationBar.barStyle = UIBarStyle.Default
        
        return imagePicker
        
//        let imagePicker = PhotoLibraryViewController()
//        let navigationController = UINavigationController(rootViewController: imagePicker)
//        
//        navigationController.navigationBar.barTintColor = UIColor.blackColor()
//        navigationController.navigationBar.barStyle = UIBarStyle.Black
//        navigationController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
//        
//        imagePicker.onSelectionComplete = { asset in
//            if let asset = asset {
//                let confirmController = ConfirmViewController(asset: asset, allowsCropping: croppingEnabled)
//                confirmController.onComplete = { image, asset in
//                    if let image = image, asset = asset {
//                        completion(image, asset)
//                    } else {
//                        imagePicker.dismissViewControllerAnimated(true, completion: nil)
//                    }
//                }
//                confirmController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
//                imagePicker.presentViewController(confirmController, animated: true, completion: nil)
//            } else {
//                completion(nil, nil)
//            }
//        }
//        
//        return navigationController
    }
}

public class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didUpdateViews = false
    var allowCropping = false
    var onCompletion: CameraViewCompletion?
    var volumeControl: VolumeControl?
    
    let cameraView : CameraView = {
        let cameraView = CameraView()
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        return cameraView
    }()
    
    let cameraOverlay : CropOverlay = {
        let cameraOverlay = CropOverlay()
        cameraOverlay.translatesAutoresizingMaskIntoConstraints = false
        return cameraOverlay
    }()
    
    let cameraButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "cameraButton",
            inBundle: CameraGlobals.shared.bundle,
            compatibleWithTraitCollection: nil),
                        forState: .Normal)
        button.setImage(UIImage(named: "cameraButtonHighlighted",
            inBundle: CameraGlobals.shared.bundle,
            compatibleWithTraitCollection: nil),
                        forState: .Highlighted)
        return button
    }()
    
    let closeButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "closeButton",
            inBundle: CameraGlobals.shared.bundle,
            compatibleWithTraitCollection: nil),
                        forState: .Normal)
        return button
    }()
    
    let swapButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "swapButton",
            inBundle: CameraGlobals.shared.bundle,
            compatibleWithTraitCollection: nil),
                        forState: .Normal)
        return button
    }()
    
    let libraryButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "libraryButton",
            inBundle: CameraGlobals.shared.bundle,
            compatibleWithTraitCollection: nil),
                        forState: .Normal)
        return button
    }()
    
    let flashButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "flashAutoIcon",
            inBundle: CameraGlobals.shared.bundle,
            compatibleWithTraitCollection: nil),
                        forState: .Normal)
        return button
    }()
  
    public init(croppingEnabled: Bool, allowsLibraryAccess: Bool = true, completion: CameraViewCompletion) {
        super.init(nibName: nil, bundle: nil)
        onCompletion = completion
        allowCropping = croppingEnabled
        cameraOverlay.hidden = !allowCropping
        libraryButton.enabled = allowsLibraryAccess
        libraryButton.hidden = !allowsLibraryAccess
    }
  
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    public override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.blackColor()
        [cameraView,
            cameraOverlay,
            cameraButton,
            libraryButton,
            closeButton,
            swapButton,
            flashButton].forEach({ self.view.addSubview($0) })
        view.setNeedsUpdateConstraints()
    }
    
    override public func updateViewConstraints() {
        
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        if !didUpdateViews {
            configCameraViewConstraints()
            configCameraButtonConstraints()
            configSwapButtonConstraints()
            configCloseButtonConstraints()
            configLibraryButtonConstraints()
            configFlashButtonConstraints()
            configCameraOverlayConstraints()
            didUpdateViews = true
        }
        super.updateViewConstraints()
    }
    
    func configCameraViewConstraints() {
        view.addConstraint(NSLayoutConstraint(item: cameraView,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cameraView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Right,
            multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cameraView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Top,
            multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cameraView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Bottom,
            multiplier: 1.0, constant: 0))
    }
    
    func configCameraButtonConstraints() {
        view.addConstraint(NSLayoutConstraint(item: cameraButton,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cameraButton,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: view,
            attribute: .BottomMargin,
            multiplier: 1.0, constant: -view.layoutMargins.bottom))
    }
    
    func configSwapButtonConstraints() {
        view.addConstraint(NSLayoutConstraint(item: swapButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: cameraButton,
            attribute: .CenterY,
            multiplier: 1.0, constant: 0))
    }
    
    func configCloseButtonConstraints() {
        view.addConstraint(NSLayoutConstraint(item: closeButton,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .LeftMargin,
            multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: closeButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: cameraButton,
            attribute: .CenterY,
            multiplier: 1.0, constant: 0))
    }
    
    func configLibraryButtonConstraints() {
        view.addConstraint(NSLayoutConstraint(item: libraryButton,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: view,
            attribute: .RightMargin,
            multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: libraryButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: cameraButton,
            attribute: .CenterY,
            multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: libraryButton,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: swapButton,
            attribute: .Right,
            multiplier: 1.0, constant: view.layoutMargins.right))
    }
    
    func configFlashButtonConstraints() {
        view.addConstraint(NSLayoutConstraint(item: flashButton,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .TopMargin,
            multiplier: 1.0, constant: view.layoutMargins.top))
        view.addConstraint(NSLayoutConstraint(item: flashButton,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: view,
            attribute: .RightMargin,
            multiplier: 1.0, constant: 0))
    }
    
    func configCameraOverlayConstraints() {
        view.addConstraint(NSLayoutConstraint(item: cameraOverlay,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .LeftMargin,
            multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cameraOverlay,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: view,
            attribute: .RightMargin,
            multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cameraOverlay,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: cameraOverlay,
            attribute: .Height,
            multiplier: 1.0, constant: 0))
        
        let centerYOffset = abs((flashButton.frame.height + view.layoutMargins.top) - (cameraButton.frame.height + view.layoutMargins.bottom))
        
        view.addConstraint(NSLayoutConstraint(item: cameraOverlay,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterY,
            multiplier: 1.0, constant: -centerYOffset))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cameraReady), name: AVCaptureSessionDidStartRunningNotification, object: nil)

        cameraButton.enabled = false
        
        volumeControl = VolumeControl(view: view) { [weak self] _ in
            self?.capturePhoto()
        }
        
        cameraButton.action = capturePhoto
        swapButton.action = swapCamera
        libraryButton.action = showLibrary
        closeButton.action = close
        flashButton.action = toggleFlash
        
        checkPermissions()
        rotate()
        
        cameraView.configureFocus()
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraView.startSession()
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
        let transform = CGAffineTransformMakeRotation(rads)
        UIView.animateWithDuration(0.3) {
            self.cameraButton.transform = transform
            self.closeButton.transform = transform
            self.swapButton.transform = transform
            self.libraryButton.transform = transform
            self.flashButton.transform = transform
        }
    }
    
    private func checkPermissions() {
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) != .Authorized {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                dispatch_async(dispatch_get_main_queue()) {
                    if !granted {
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
    
    
    internal func capturePhoto() {
        guard let output = cameraView.imageOutput, connection = output.connectionWithMediaType(AVMediaTypeVideo) else {
            return
        }
        
        if connection.enabled {
            cameraButton.enabled = false
            closeButton.enabled = false
            swapButton.enabled = false
            libraryButton.enabled = false
            cameraView.capturePhoto { image in
                guard let image = image else {
                    self.cameraButton.enabled = true
                    self.closeButton.enabled = true
                    self.swapButton.enabled = true
                    self.libraryButton.enabled = true
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
                self.libraryButton.enabled = true
                self.showNoPermissionsView(true)
            }
            .save()
    }
    
    internal func close() {
        onCompletion?(nil, nil)
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var asset: PHAsset
        if (info["UIImagePickerControllerMediaType"] as? String == "public.movie") {
            // Video
            //            asset = PHAsset.fetchAssetsWithALAssetURLs([info["UIImagePickerControllerReferenceURL"]], options: nil).lastObject()
        }
        else if (info["UIImagePickerControllerMediaType"] as? String == "public.image") {
            // Photo
            let url = info[UIImagePickerControllerReferenceURL] as! NSURL
            var result: PHFetchResult = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil)
            asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).lastObject as! PHAsset
            
            let confirmController = ConfirmViewController(asset: asset, allowsCropping: allowCropping)
            confirmController.onComplete = { image, creationDate in
                if let i = image {
                    self.onCompletion!(i, creationDate)
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            confirmController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            picker.presentViewController(confirmController, animated: true, completion: nil)
        }
    }
    
    internal func showLibrary() {
        let imagePicker = CameraViewController.imagePickerViewController(allowCropping, imagePickerDelegate: self) { image, asset in
            self.dismissViewControllerAnimated(true, completion: nil)
            
            guard let image = image, asset = asset else {
                return
            }
            
            self.onCompletion?(image, asset)
        }
        
        presentViewController(imagePicker, animated: true) {
            self.cameraView.stopSession()
        }
    }
    
    internal func toggleFlash() {
        cameraView.cycleFlash()
        
        guard let device = cameraView.device else {
            return
        }
        
        let mode = device.flashMode
        let imageName = flashImage(mode)
        let image = UIImage(named: imageName, inBundle: NSBundle(forClass: CameraViewController.self), compatibleWithTraitCollection: nil)
        
        flashButton.setImage(image, forState: .Normal)
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
        confirmViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        presentViewController(confirmViewController, animated: true, completion: nil)

        cameraButton.enabled = true
        closeButton.enabled = true
        swapButton.enabled = true
        libraryButton.enabled = true
    }
}
