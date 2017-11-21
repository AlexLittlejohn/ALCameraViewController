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
import CoreMotion
import Crashlytics

public typealias CameraViewCompletion = (UIImage?, PHAsset?) -> Void

public extension CameraViewController {
    /// Provides an image picker wrapped inside a UINavigationController instance
    public class func imagePickerViewController(croppingEnabled: Bool, completion: @escaping CameraViewCompletion) -> UINavigationController {
        let imagePicker = PhotoLibraryViewController()
        let navigationController = UINavigationController(rootViewController: imagePicker)
        
        navigationController.navigationBar.barTintColor = UIColor.white
        navigationController.navigationBar.tintColor = UIColor.black
        navigationController.navigationBar.barStyle = UIBarStyle.black
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        navigationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve

        imagePicker.onSelectionComplete = { [weak imagePicker] asset in
            if let asset = asset {
                let cropViewController = CropViewController(asset: asset, allowsCropping: croppingEnabled)
                cropViewController.onComplete = { [weak imagePicker] image, asset in
                    if let image = image, let asset = asset {
                        completion(image, asset)
                    } else {
                        imagePicker?.dismiss(animated: true, completion: nil)
                    }
                }
                
                imagePicker?.navigationController?.pushViewController(cropViewController, animated: true)
            } else {
                completion(nil, nil)
            }
        }
        
        return navigationController
    }
}

open class CameraViewController: UIViewController {
    
    var didUpdateViews = false
    var allowCropping = false
    var animationRunning = false
    
    var lastInterfaceOrientation : UIInterfaceOrientation? = UIApplication.shared.statusBarOrientation
    open var onCompletion: CameraViewCompletion?
    var volumeControl: VolumeControl?
    
    var animationDuration: TimeInterval = 0.5
    var animationSpring: CGFloat = 0.5
    var rotateAnimation: UIViewAnimationOptions = .curveLinear
    
    var cameraButtonEdgeConstraint: NSLayoutConstraint?
    var cameraButtonGravityConstraint: NSLayoutConstraint?
    
    var closeButtonEdgeConstraint: NSLayoutConstraint?
    var closeButtonGravityConstraint: NSLayoutConstraint?
    
    var containerButtonsEdgeOneConstraint: NSLayoutConstraint?
    var containerButtonsEdgeTwoConstraint: NSLayoutConstraint?
    var containerButtonsGravityConstraint: NSLayoutConstraint?
    
    var swapButtonEdgeOneConstraint: NSLayoutConstraint?
    var swapButtonEdgeTwoConstraint: NSLayoutConstraint?
    var swapButtonGravityConstraint: NSLayoutConstraint?
    
    var libraryButtonEdgeOneConstraint: NSLayoutConstraint?
    var libraryButtonEdgeTwoConstraint: NSLayoutConstraint?
    var libraryButtonGravityConstraint: NSLayoutConstraint?
    
    var flashButtonEdgeConstraint: NSLayoutConstraint?
    var flashButtonGravityConstraint: NSLayoutConstraint?
    
    var cameraOverlayEdgeOneConstraint: NSLayoutConstraint?
    var cameraOverlayEdgeTwoConstraint: NSLayoutConstraint?
    var cameraOverlayWidthConstraint: NSLayoutConstraint?
    var cameraOverlayCenterConstraint: NSLayoutConstraint?
    
    let motionManager : CMMotionManager = {
        let motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 0.2
        return motionManager
    }()
    
  @IBOutlet weak var cameraView: CameraView!
  
//    let cameraView : CameraView = {
//        let cameraView = CameraView()
//        cameraView.translatesAutoresizingMaskIntoConstraints = false
//        return cameraView
//    }()
  
    let cameraOverlay : CropOverlay = {
        let cameraOverlay = CropOverlay()
        cameraOverlay.translatesAutoresizingMaskIntoConstraints = false
        return cameraOverlay
    }()
  
  @IBOutlet weak var cameraButton: UIButton!
  
    
//    let cameraButton : UIButton = {
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.isEnabled = false
//        button.setImage(UIImage(named: "cameraButton",
//                                in: CameraGlobals.shared.bundle,
//                                compatibleWith: nil),
//                        for: .normal)
//        button.setImage(UIImage(named: "cameraButtonHighlighted",
//                                in: CameraGlobals.shared.bundle,
//                                compatibleWith: nil),
//                        for: .highlighted)
//        return button
//    }()
  
  @IBOutlet weak var closeButton: UIButton!
//    let closeButton : UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(named: "closeButton",
//                                in: CameraGlobals.shared.bundle,
//                                compatibleWith: nil),
//                        for: .normal)
//        return button
//    }()
  
  @IBOutlet weak var swapButton: UIButton!
//    let swapButton : UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(named: "swapButton",
//                                in: CameraGlobals.shared.bundle,
//                                compatibleWith: nil),
//                        for: .normal)
//        return button
//    }()
  
  @IBOutlet weak var libraryButton: UIButton!
//    let libraryButton : UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(named: "libraryButton",
//                                in: CameraGlobals.shared.bundle,
//                                compatibleWith: nil),
//                        for: .normal)
//        return button
//    }()
  
  @IBOutlet weak var flashButton: UIButton!
//    let flashButton : UIButton = {
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(named: "flashAutoIcon",
//                                in: CameraGlobals.shared.bundle,
//                                compatibleWith: nil),
//                        for: .normal)
//        return button
//    }()
//    
//    let containerSwapLibraryButton : UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
	
	private let allowsLibraryAccess: Bool
    private var allowsSwapCamera: Bool = true
  
	public init(croppingEnabled: Bool, allowsLibraryAccess: Bool = true, allowsSwapCameraOrientation: Bool = true, completion: @escaping CameraViewCompletion) {
		self.allowsLibraryAccess = allowsLibraryAccess
        super.init(nibName: "CameraViewController", bundle: CameraGlobals.shared.bundle)
        onCompletion = completion
        allowCropping = croppingEnabled
        allowsSwapCamera = allowsSwapCameraOrientation
    }
	
    required public init?(coder aDecoder: NSCoder) {
        allowsLibraryAccess = true
        super.init(coder: aDecoder)
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraOverlay.isHidden = !allowCropping
        libraryButton.isEnabled = allowsLibraryAccess
        libraryButton.isHidden = !allowsLibraryAccess
        swapButton.isEnabled = allowsSwapCamera
        swapButton.isHidden = !allowsSwapCamera
        
        setupActions()
        checkPermissions()
        cameraView.configureFocus()
    }

    /**
     * Start the session of the camera.
     */
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        cameraView.startSession()
        addCameraObserver()
        addRotateObserver()
        setupVolumeControl()
    }
    
    /**
     * Enable the button to take the picture when the
     * camera is ready.
     */
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cameraView.session?.isRunning == true {
            notifyCameraReady()
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self)
        volumeControl = nil
    }

    /**
     * This method will disable the rotation of the
     */
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        lastInterfaceOrientation = UIApplication.shared.statusBarOrientation
        if animationRunning {
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        coordinator.animate(alongsideTransition: { [weak self] animation in
            self?.view.setNeedsUpdateConstraints()
            }, completion: { _ in
                CATransaction.commit()
        })
    }
    
    /**
     * Observer the camera status, when it is ready,
     * it calls the method cameraReady to enable the
     * button to take the picture.
     */
    private func addCameraObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifyCameraReady),
            name: NSNotification.Name.AVCaptureSessionDidStartRunning,
            object: nil)
    }
    
    /**
     * Observer the device orientation to update the
     * orientation of CameraView.
     */
    private func addRotateObserver() {
        if motionManager.isDeviceMotionAvailable {
            let queue = OperationQueue()
            motionManager.startDeviceMotionUpdates(to: queue) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
                if let gravity = data?.gravity {
                    if let orientation = self?.calcOrientation(gravity) {
                        OperationQueue.main.addOperation {
                            // update UI here
                            self?.rotate(actualInterfaceOrientation: orientation)
                        }
                    }
                }
            }
        }

    }
    
    func calcOrientation(_ acceleration: CMAcceleration) -> UIInterfaceOrientation? {
        var orientationNew:UIInterfaceOrientation?;
        
        if (acceleration.x >= 0.75) {
            orientationNew = .landscapeLeft
        }
        else if (acceleration.x <= -0.75) {
            orientationNew = .landscapeRight
        }
        else if (acceleration.y <= -0.75) {
            orientationNew = .portrait;
        }
        else if (acceleration.y >= 0.75) {
            orientationNew = .portraitUpsideDown;
        }
        
        guard let _ = orientationNew else {
            return nil
        }
        
        if (orientationNew == lastInterfaceOrientation) {
            return nil
        }
        
        lastInterfaceOrientation = orientationNew
        return orientationNew
    }
    
    internal func notifyCameraReady() {
        cameraButton.isEnabled = true
    }
    
    /**
     * Attach the take of picture for any volume button.
     */
    private func setupVolumeControl() {
        volumeControl = VolumeControl(view: view) { [weak self] _ in
            guard let enabled = self?.cameraButton.isEnabled, enabled else {
                return
            }
            self?.capturePhoto()
        }
    }
    
    /**
     * Configure the action for every button on this
     * layout.
     */
    private func setupActions() {
        cameraButton.action = { [weak self] in self?.capturePhoto() }
        swapButton.action = { [weak self] in self?.swapCamera() }
        libraryButton.action = { [weak self] in self?.showLibrary() }
        closeButton.action = { [weak self] in self?.close() }
        flashButton.action = { [weak self] in self?.toggleFlash() }
    }
    
    /**
     * Toggle the buttons status, based on the actual
     * state of the camera.
     */
    private func toggleButtons(enabled: Bool) {
        [cameraButton,
            closeButton,
            swapButton,
            libraryButton].forEach({ $0.isEnabled = enabled })
    }
    
    func rotateCameraView(_ orientation:UIInterfaceOrientation) {
        cameraView.rotatePreview(orientation)
    }
    
    /**
     * This method will rotate the buttons based on
     * the last and actual orientation of the device.
     */
    internal func rotate(actualInterfaceOrientation: UIInterfaceOrientation) {
        let transform = CGAffineTransform(rotationAngle: radians(currentRotation(
            .portrait, newOrientation: actualInterfaceOrientation)))
        animationRunning = true
        
        /**
         * Dispatch delay to avoid any conflict between the CATransaction of rotation of the screen
         * and CATransaction of animation of buttons.
         */

        let duration = animationDuration
        let spring = animationSpring
        let options = rotateAnimation

        CATransaction.begin()
        CATransaction.setDisableActions(false)
        CATransaction.commit()
        
        UIView.animate(
            withDuration: duration,
            delay: 0.1,
            usingSpringWithDamping: spring,
            initialSpringVelocity: 0,
            options: options,
            animations: { [weak self] in
                self?.setTransform(transform: transform)
            }, completion: { [weak self] _ in
                self?.animationRunning = false
        })
    }
    
    func setTransform(transform: CGAffineTransform) {
        closeButton.transform = transform
        swapButton.transform = transform
        libraryButton.transform = transform
        flashButton.transform = transform
    }
    
    /**
     * Validate the permissions of the camera and
     * library, if the user do not accept these
     * permissions, it shows an view that notifies
     * the user that it not allow the permissions.
     */
    private func checkPermissions() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) != .authorized {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                DispatchQueue.main.async() { [weak self] in
                    if !granted {
                        self?.showNoPermissionsView()
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
        
        permissionsView.configureInView(view, title: title, description: desc, completion: { [weak self] in self?.close() })
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
            let connection = output.connection(withMediaType: AVMediaTypeVideo) else {
            return
        }
        
        if connection.isEnabled {
            toggleButtons(enabled: false)
            Answers.logCustomEvent(withName: "ALCamera.Camera.CapturePhoto", customAttributes: nil)
            cameraView.capturePhoto(lastInterfaceOrientation!, { [weak self] (image) in
                guard let image = image else {
                    self?.toggleButtons(enabled: true)
                    return
                }
                self?.saveImage(image: image)
            })
        }
    }
    
    internal func saveImage(image: UIImage) {
        let spinner = showSpinner()
        cameraView.preview.isHidden = true

		if allowsLibraryAccess {
        _ = SingleImageSaver()
            .setImage(image)
            .onSuccess { [weak self] asset in
                self?.layoutCameraResult(asset: asset)
                self?.hideSpinner(spinner)
            }
            .onFailure { [weak self] error in
                self?.toggleButtons(enabled: true)
                self?.showNoPermissionsView(library: true)
                self?.cameraView.preview.isHidden = false
                self?.hideSpinner(spinner)
            }
            .save()
		} else {
			layoutCameraResult(uiImage: image)
			hideSpinner(spinner)
		}
    }
	
    internal func close() {
        onCompletion?(nil, nil)
        onCompletion = nil
    }
    
    internal func showLibrary() {
        Answers.logCustomEvent(withName: "ALCamera.Camera.OpenLibrary", customAttributes: nil)
        let imagePicker = CameraViewController.imagePickerViewController(croppingEnabled: allowCropping) { [weak self] image, asset in
            defer {
                self?.dismiss(animated: true, completion: nil)
            }

            guard let image = image, let asset = asset else {
                return
            }

            self?.onCompletion?(image, asset)
        }
        
        present(imagePicker, animated: true) { [weak self] in
            self?.cameraView.stopSession()
        }
    }
    
    internal func toggleFlash() {
        cameraView.cycleFlash()
        
        guard let device = cameraView.device else {
            return
        }
  
        Answers.logCustomEvent(withName: "ALCamera.Camera.ToggleFlash", customAttributes: nil)
        let image = UIImage(named: flashImage(device.flashMode),
                            in: CameraGlobals.shared.bundle,
                            compatibleWith: nil)
        
        flashButton.setImage(image, for: .normal)
    }
    
    internal func swapCamera() {
        Answers.logCustomEvent(withName: "ALCamera.Camera.Swap", customAttributes: nil)
        cameraView.swapCameraInput()
        flashButton.isHidden = cameraView.currentPosition == AVCaptureDevicePosition.front
    }
	
	internal func layoutCameraResult(uiImage: UIImage) {
		cameraView.stopSession()
		startCropController(uiImage: uiImage)
		toggleButtons(enabled: true)
	}
	
    internal func layoutCameraResult(asset: PHAsset) {
        cameraView.stopSession()
        startCropController(asset: asset)
        toggleButtons(enabled: true)
    }
	
	private func startCropController(uiImage: UIImage) {
        
		let cropViewController = CropViewController(image: uiImage, allowsCropping: allowCropping)
		cropViewController.onComplete = { [weak self] image, asset in
			defer {
				self?.dismiss(animated: true, completion: nil)
			}
			
			guard let image = image else {
				return
			}
			
			self?.onCompletion?(image, asset)
			self?.onCompletion = nil
		}
        
        let navigationController = UINavigationController(rootViewController: cropViewController)
        
        navigationController.navigationBar.barTintColor = UIColor.white
        navigationController.navigationBar.tintColor = UIColor.black
        navigationController.navigationBar.barStyle = UIBarStyle.black
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]

        navigationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
		present(navigationController, animated: true, completion: nil)
	}
	
    private func startCropController(asset: PHAsset) {
        let cropViewController = CropViewController(asset: asset, allowsCropping: allowCropping)
        cropViewController.onComplete = { [weak self] image, asset in
            defer {
                self?.dismiss(animated: true, completion: nil)
            }

            guard let image = image, let asset = asset else {
                return
            }

            self?.onCompletion?(image, asset)
            self?.onCompletion = nil
        }
        
        let navigationController = UINavigationController(rootViewController: cropViewController)
        
        navigationController.navigationBar.barTintColor = UIColor.white
        navigationController.navigationBar.tintColor = UIColor.black
        navigationController.navigationBar.barStyle = UIBarStyle.black
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        
        navigationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve

        present(navigationController, animated: true, completion: nil)
    }

    private func showSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .white
        spinner.center = view.center
        spinner.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        spinner.startAnimating()
        
        view.addSubview(spinner)
        view.bringSubview(toFront: spinner)
        
        return spinner
    }
    
    private func hideSpinner(_ spinner: UIActivityIndicatorView) {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
}
