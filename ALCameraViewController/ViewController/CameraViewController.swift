//
//  CameraViewController.swift
//  CameraViewController
//
//  Created by Alex Littlejohn.
//  Copyright (c) 2016 zero. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

public typealias CameraViewCompletion = (UIImage?, PHAsset?) -> Void

public extension CameraViewController {
    public class func imagePickerViewController(croppingEnabled: Bool, completion: CameraViewCompletion) -> UINavigationController {
        let imagePicker = PhotoLibraryViewController()
        let navigationController = UINavigationController(rootViewController: imagePicker)
        
        navigationController.navigationBar.barTintColor = UIColor.blackColor()
        navigationController.navigationBar.barStyle = UIBarStyle.Black
        navigationController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
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

public class CameraViewController: UIViewController {
    
    var didUpdateViews = false
    var allowCropping = false
    var onCompletion: CameraViewCompletion?
    var volumeControl: VolumeControl?
    
    var cameraButtonEdgeConstraint: NSLayoutConstraint?
    var cameraButtonGravityConstraint: NSLayoutConstraint?
    
    var closeButtonGravityConstraint: NSLayoutConstraint?
    
    var swapButtonEdgeConstraint: NSLayoutConstraint?
    var swapButtonGravityConstraint: NSLayoutConstraint?
    
    var libraryButtonEdgeConstraint: NSLayoutConstraint?
    var libraryButtonGravityConstraint: NSLayoutConstraint?
    
    var flashButtonEdgeConstraint: NSLayoutConstraint?
    var flashButtonGravityConstraint: NSLayoutConstraint?
    
    var cameraOverlayEdgeOneConstraint: NSLayoutConstraint?
    var cameraOverlayEdgeTwoConstraint: NSLayoutConstraint?
    var cameraOverlayWidthConstraint: NSLayoutConstraint?
    var cameraOverlayCenterConstraint: NSLayoutConstraint?
    
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
        button.enabled = false
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
    
    /**
     * Configure the background of the superview to black
     * and add the views on this superview. Then, request
     * the update of constraints for this superview.
     */
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
    
    /**
     * Setup the constraints when the app is starting or rotating
     * the screen.
     * To avoid the override/conflict of stable constraint, these
     * stable constraint are one time configurable.
     * Any other dynamic constraint are configurable when the
     * device is rotating, based on the device orientation.
     */
    override public func updateViewConstraints() {
        
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        if !didUpdateViews {
            configCameraViewConstraints()
            configCloseButtonConstraint()
            didUpdateViews = true
        }
        let portrait = UIDevice.currentDevice().orientation.isPortrait
        configCameraButtonEdgeConstraint(portrait)
        configCameraButtonGravityConstraint(portrait)
        configCloseButtonGravityConstraint(portrait)
        
        removeSwapButtonConstraints()
        configSwapButtonEdgeConstraint(portrait)
        configSwapButtonGravityConstraint(portrait)
        
        removeLibraryButtonConstraints()
        configLibraryEdgeButtonConstraint(portrait)
        configLibraryGravityButtonConstraint(portrait)
        
        configFlashEdgeButtonConstraint(portrait)
        configFlashGravityButtonConstraint(portrait)
        
        let padding : CGFloat = portrait ? 15.0 : -15.0
        removeCameraOverlayEdgesConstraints()
        configCameraOverlayEdgeOneContraint(portrait, padding: padding)
        configCameraOverlayEdgeTwoConstraint(portrait, padding: padding)
        configCameraOverlayWidthConstraint(portrait)
        configCameraOverlayCenterConstraint(portrait)
        
        super.updateViewConstraints()
    }
    
    /**
     * To attach the view to the edges of the superview, it needs 
     to be pinned on the sides of the self.view, based on the 
     edges of this superview.
     * This configure the cameraView to show, in real time, the
     * camera.
     */
    func configCameraViewConstraints() {
        [.Left, .Right, .Top, .Bottom].forEach({
            view.addConstraint(NSLayoutConstraint(
                item: cameraView,
                attribute: $0,
                relatedBy: .Equal,
                toItem: view,
                attribute: $0,
                multiplier: 1.0, constant: 0))
        })
    }
    
    /**
     * Add the constraints based on the device orientation,
     * this pin the button on the bottom part of the screen 
     * when the device is portrait, when landscape, pin
     * the button on the right part of the screen.
     */
    func configCameraButtonEdgeConstraint(portrait: Bool) {
        view.autoRemoveConstraint(cameraButtonEdgeConstraint)
        let attribute : NSLayoutAttribute = portrait ? .Bottom : .Right
        cameraButtonEdgeConstraint = NSLayoutConstraint(
            item: cameraButton,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0,
            constant:-8)
        view.addConstraint(cameraButtonEdgeConstraint!)
    }
    
    /**
     * Add the constraints based on the device orientation, 
     * centerX the button based on the width of screen.
     * When the device is landscape orientation, centerY
     * the button based on the height of screen.
     */
    func configCameraButtonGravityConstraint(portrait: Bool) {
        view.autoRemoveConstraint(cameraButtonGravityConstraint)
        let attribute : NSLayoutAttribute = portrait ? .CenterX : .CenterY
        cameraButtonGravityConstraint = NSLayoutConstraint(
            item: cameraButton,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0, constant: 0)
        view.addConstraint(cameraButtonGravityConstraint!)
    }
    
    /**
     * Remove the SwapButton constraints to be updated when 
     * the device was rotated.
     */
    func removeSwapButtonConstraints() {
        view.autoRemoveConstraint(swapButtonEdgeConstraint)
        view.autoRemoveConstraint(swapButtonGravityConstraint)
    }
    
    /**
     * If the device is portrait, pin the SwapButton on the
     * right side of the CameraButton.
     * If landscape, pin the SwapButton on the top of the
     * CameraButton.
     */
    func configSwapButtonEdgeConstraint(portrait: Bool) {
        swapButtonEdgeConstraint = portrait ?
            
            NSLayoutConstraint(
                item: swapButton,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: cameraButton,
                attribute: .Right,
                multiplier: 1.0, constant: 8) :
            
            NSLayoutConstraint(
                item: swapButton,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: cameraButton,
                attribute: .Top,
                multiplier: 1.0, constant: -8)
        
        view.addConstraint(swapButtonEdgeConstraint!)
    }
    
    /**
     * Configure the center of SwapButton, based on the
     * axis center of CameraButton.
     */
    func configSwapButtonGravityConstraint(portrait: Bool) {
        let attribute : NSLayoutAttribute = portrait ? .CenterY : .CenterX
        swapButtonGravityConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: cameraButton,
            attribute: attribute,
            multiplier: 1.0, constant: 0)
        view.addConstraint(swapButtonGravityConstraint!)
    }
    
    /**
     * Pin the close button to the left of the superview.
     */
    func configCloseButtonConstraint() {
        view.addConstraint(NSLayoutConstraint(
            item: closeButton,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0, constant: 16))
    }
    
    /**
     * Add the constraint for the CloseButton, based on
     * the device orientation.
     * If portrait, it pin the CloseButton on the CenterY
     * of the CameraButton.
     * Else if landscape, pin this button on the Bottom
     * of superview.
     */
    func configCloseButtonGravityConstraint(portrait: Bool) {
        view.autoRemoveConstraint(closeButtonGravityConstraint)
        closeButtonGravityConstraint = portrait ?
            
            NSLayoutConstraint(
                item: closeButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: cameraButton,
                attribute: .CenterY,
                multiplier: 1.0, constant: 0) :
            
            NSLayoutConstraint(
                item: closeButton,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: view,
                attribute: .Bottom,
                multiplier: 1.0, constant: -16)
            
        view.addConstraint(closeButtonGravityConstraint!)
    }
    
    /**
     * Remove the LibraryButton constraints to be updated when
     * the device was rotated.
     */
    func removeLibraryButtonConstraints() {
        view.autoRemoveConstraint(libraryButtonEdgeConstraint)
        view.autoRemoveConstraint(libraryButtonGravityConstraint)
    }
    
    /**
     * Add the constraint of the LibraryButton, if the device
     * orientation is portrait, pin the right side of SwapButton
     * to the left side of LibraryButton.
     * If landscape, pin the bottom side of CameraButton on the
     * top side of LibraryButton.
     */
    func configLibraryEdgeButtonConstraint(portrait: Bool) {
        libraryButtonEdgeConstraint = portrait ?
            
            NSLayoutConstraint(
                item: libraryButton,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: swapButton,
                attribute: .Right,
                multiplier: 1.0, constant: 8) :
            
            NSLayoutConstraint(
                item: libraryButton,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: cameraButton,
                attribute: .Bottom,
                multiplier: 1.0, constant: 8)
        
        view.addConstraint(libraryButtonEdgeConstraint!)
    }
    
    /**
     * Set the center gravity of the LibraryButton based
     * on the position of CameraButton.
     */
    func configLibraryGravityButtonConstraint(portrait: Bool) {
        let attribute : NSLayoutAttribute = portrait ? .CenterY : .CenterX
        libraryButtonGravityConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: cameraButton,
            attribute: attribute,
            multiplier: 1.0, constant: 0)
        view.addConstraint(libraryButtonGravityConstraint!)
    }
    
    /**
     * If the device orientation is portrait, pin the top of
     * FlashButton to the top side of superview.
     * Else if, pin the FlashButton bottom side on the top side
     * of SwapButton.
     */
    func configFlashEdgeButtonConstraint(portrait: Bool) {
        view.autoRemoveConstraint(flashButtonEdgeConstraint)
        flashButtonEdgeConstraint = portrait ?
            
            NSLayoutConstraint(
                item: flashButton,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: view,
                attribute: .Top,
                multiplier: 1.0, constant: 8) :
            
            NSLayoutConstraint(
                item: flashButton,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: swapButton,
                attribute: .Top,
                multiplier: 1.0, constant: -8)
        
        view.addConstraint(flashButtonEdgeConstraint!)
    }
    
    /**
     * If the device orientation is portrait, pin the 
     right side of FlashButton to the right side of 
     * superview.
     * Else if, centerX the FlashButton on the CenterX
     * of CameraButton.
     */
    func configFlashGravityButtonConstraint(portrait: Bool) {
        view.autoRemoveConstraint(flashButtonGravityConstraint)
        flashButtonGravityConstraint = portrait ?
            
            NSLayoutConstraint(
                item: flashButton,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: view,
                attribute: .Right,
                multiplier: 1.0, constant: -8) :
            
            NSLayoutConstraint(
                item: flashButton,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: cameraButton,
                attribute: .CenterX,
                multiplier: 1.0, constant: 0)
        
        view.addConstraint(flashButtonGravityConstraint!)
    }
    
    /**
     * Used to create a perfect square for CameraOverlay.
     * This method will determinate the size of CameraOverlay,
     * if portrait, it will use the width of superview to
     * determinate the height of the view. Else if landscape,
     * it uses the height of the superview to create the width
     * of the CameraOverlay.
     */
    func configCameraOverlayWidthConstraint(portrait: Bool) {
        view.autoRemoveConstraint(cameraOverlayWidthConstraint)
        cameraOverlayWidthConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: portrait ? .Height : .Width,
            relatedBy: .Equal,
            toItem: cameraOverlay,
            attribute: portrait ? .Width : .Height,
            multiplier: 1.0, constant: 0)
        view.addConstraint(cameraOverlayWidthConstraint!)
    }
    
    /**
     * This method will center the relative position of
     * CameraOverlay, based on the biggest size of the
     * superview.
     */
    func configCameraOverlayCenterConstraint(portrait: Bool) {
        view.autoRemoveConstraint(cameraOverlayCenterConstraint)
        let attribute : NSLayoutAttribute = portrait ? .CenterY : .CenterX
        cameraOverlayCenterConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0, constant: 0)
        view.addConstraint(cameraOverlayCenterConstraint!)
    }
    
    /**
     * Remove the CameraOverlay constraints to be updated when
     * the device was rotated.
     */
    func removeCameraOverlayEdgesConstraints() {
        view.autoRemoveConstraint(cameraOverlayEdgeOneConstraint)
        view.autoRemoveConstraint(cameraOverlayEdgeTwoConstraint)
    }
    
    /**
     * It needs to get a determined smallest size of the screen
     to create the smallest size to be used on CameraOverlay.
     It uses the orientation of the screen to determinate where
     the view will be pinned.
     */
    func configCameraOverlayEdgeOneContraint(portrait: Bool, padding: CGFloat) {
        let attribute : NSLayoutAttribute = portrait ? .Left : .Bottom
        cameraOverlayEdgeOneConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: view,
            attribute: attribute,
            multiplier: 1.0, constant: padding)
        view.addConstraint(cameraOverlayEdgeOneConstraint!)
    }
    
    /**
     * It needs to get a determined smallest size of the screen
     to create the smallest size to be used on CameraOverlay.
     It uses the orientation of the screen to determinate where
     the view will be pinned.
     */
    func configCameraOverlayEdgeTwoConstraint(portrait: Bool, padding: CGFloat) {
        let attributeTwo : NSLayoutAttribute = portrait ? .Right : .Top
        cameraOverlayEdgeTwoConstraint = NSLayoutConstraint(
            item: cameraOverlay,
            attribute: attributeTwo,
            relatedBy: .Equal,
            toItem: view,
            attribute: attributeTwo,
            multiplier: 1.0, constant: -padding)
        view.addConstraint(cameraOverlayEdgeTwoConstraint!)
    }
    
    /**
     * Add observer to check when the camera has started,
     * enable the volume buttons to take the picture,
     * configure the actions of the buttons on the screen,
     * check the permissions of access of the camera and
     * the photo library.
     * Configure the camera focus when the application
     * start, to avoid any bluried image.
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
        addCameraObserver()
        setupVolumeControl()
        setupActions()
        checkPermissions()
        cameraView.configureFocus()
    }

    /**
     * Start the session of the camera.
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraView.startSession()
    }
    
    /**
     * Enable the button to take the picture when the
     * camera is ready.
     */
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if cameraView.session?.running == true {
            notifyCameraReady()
        }
    }
    
    /**
     * Observer the camera status, when it is ready,
     * it calls the method cameraReady to enable the
     * button to take the picture.
     */
    private func addCameraObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notifyCameraReady), name: AVCaptureSessionDidStartRunningNotification, object: nil)
    }
    
    internal func notifyCameraReady() {
        cameraButton.enabled = true
    }
    
    /**
     * Attach the take of picture for any volume button.
     */
    private func setupVolumeControl() {
        volumeControl = VolumeControl(view: view) { [weak self] _ in
            if self?.cameraButton.enabled == true {
              self?.capturePhoto()
            }
        }
    }
    
    /**
     * Configure the action for every button on this
     * layout.
     */
    private func setupActions() {
        cameraButton.action = capturePhoto
        swapButton.action = swapCamera
        libraryButton.action = showLibrary
        closeButton.action = close
        flashButton.action = toggleFlash
    }
    
    /**
     * Toggle the buttons status, based on the actual
     * state of the camera.
     */
    private func toggleButtons(enabled: Bool) {
        [cameraButton,
            closeButton,
            swapButton,
            libraryButton].forEach({ $0.enabled = enabled })
    }
    
    /**
     * Validate the permissions of the camera and
     * library, if the user do not accept these
     * permissions, it shows an view that notifies
     * the user that it not allow the permissions.
     */
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
    
    /**
     * Generate the view of no permission.
     */
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
    
    /**
     * This method will be called when the user
     * try to take the picture.
     * It will lock any button while the shot is
     * taken, then, realease the buttons and save
     * the picture on the device.
     */
    internal func capturePhoto() {
        guard let output = cameraView.imageOutput,
            connection = output.connectionWithMediaType(AVMediaTypeVideo) else {
            return
        }
        
        if connection.enabled {
            toggleButtons(true)
            cameraView.capturePhoto { image in
                guard let image = image else {
                    self.toggleButtons(true)
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
                self.toggleButtons(true)
                self.showNoPermissionsView(true)
            }
            .save()
    }
    
    internal func close() {
        onCompletion?(nil, nil)
    }
    
    internal func showLibrary() {
        let imagePicker = CameraViewController.imagePickerViewController(allowCropping) { image, asset in
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
  
        let image = UIImage(named: flashImage(device.flashMode),
                            inBundle: NSBundle(forClass: CameraViewController.self),
                            compatibleWithTraitCollection: nil)
        
        flashButton.setImage(image, forState: .Normal)
    }
    
    internal func swapCamera() {
        cameraView.swapCameraInput()
        flashButton.hidden = cameraView.currentPosition == AVCaptureDevicePosition.Front
    }
    
    internal func layoutCameraResult(asset: PHAsset) {
        cameraView.stopSession()
        startConfirmController(asset)
        toggleButtons(true)
    }
    
    private func startConfirmController(asset: PHAsset) {
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
    }
    
}
