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

public typealias CameraViewCompletion = (Data?, UIImage?, PHAsset?, String?, String?) -> Void

public extension CameraViewController {
    /// Provides an image picker wrapped inside a UINavigationController instance
    public class func imagePickerViewController(croppingEnabled: Bool, completion: @escaping CameraViewCompletion) -> UINavigationController {
        let imagePicker = PhotoLibraryViewController()
        let navigationController = UINavigationController(rootViewController: imagePicker)

        navigationController.navigationBar.barTintColor = UIColor.black
        navigationController.navigationBar.barStyle = UIBarStyle.black
        navigationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve

        imagePicker.onSelectionComplete = { [weak imagePicker] asset in
            if let asset = asset {
                let confirmController = ConfirmViewController(asset: asset, allowsCropping: croppingEnabled)
                confirmController.onComplete = { [weak imagePicker] imageData, image, asset, errorData, exifData in
                    if let image = image, let asset = asset {
                        completion(imageData, image, asset, errorData, exifData)
                    } else {
                        imagePicker?.dismiss(animated: true, completion: nil)
                    }
                }
                confirmController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                imagePicker?.present(confirmController, animated: true, completion: nil)
            } else {
                completion(nil, nil, nil, nil, nil)
            }
        }

        return navigationController
    }
}

open class CameraViewController: UIViewController {

    var didUpdateViews = false
    var allowCropping = false
    var allowAudio = false
    var animationRunning = false

    var lastInterfaceOrientation: UIInterfaceOrientation?
    open var onCompletion: CameraViewCompletion?
    var volumeControl: VolumeControl?

    var outputScale: CGFloat = 1.0

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

    let cameraView: CameraView = {
        let cameraView = CameraView()
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        return cameraView
    }()

    let cameraOverlay: CropOverlay = {
        let cameraOverlay = CropOverlay()
        cameraOverlay.translatesAutoresizingMaskIntoConstraints = false
        return cameraOverlay
    }()

    let cameraButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.setImage(UIImage(named: "cameraButton",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .normal)
        button.setImage(UIImage(named: "cameraButtonHighlighted",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .highlighted)
        return button
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "closeButton",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .normal)
        return button
    }()

    let swapButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "swapButton",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .normal)
        return button
    }()

    let libraryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "libraryButton",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .normal)
        return button
    }()

    let flashButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "flashAutoIcon",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .normal)
        return button
    }()

    let containerSwapLibraryButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let allowsLibraryAccess: Bool

    public init(scale: CGFloat = 1.0, croppingEnabled: Bool, allowsLibraryAccess: Bool = true, allowsSwapCameraOrientation: Bool = true, allowsAudio: Bool = true, completion: @escaping CameraViewCompletion) {
        self.allowsLibraryAccess = allowsLibraryAccess
        super.init(nibName: nil, bundle: nil)
        outputScale = scale
        onCompletion = completion
        allowCropping = croppingEnabled
        allowAudio = allowsAudio
        cameraOverlay.isHidden = !allowCropping
        libraryButton.isEnabled = allowsLibraryAccess
        libraryButton.isHidden = !allowsLibraryAccess
        swapButton.isEnabled = allowsSwapCameraOrientation
        swapButton.isHidden = !allowsSwapCameraOrientation
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }

    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    /**
     * Configure the background of the superview to black
     * and add the views on this superview. Then, request
     * the update of constraints for this superview.
     */
    open override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.black
        [
            cameraView,
            cameraOverlay,
            cameraButton,
            closeButton,
            flashButton,
            containerSwapLibraryButton,
        ].forEach({ view.addSubview($0) })
        [swapButton, libraryButton].forEach({ containerSwapLibraryButton.addSubview($0) })
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
    open override func updateViewConstraints() {

        if !didUpdateViews {
            configCameraViewConstraints()
            didUpdateViews = true
        }

        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        let portrait = statusBarOrientation.isPortrait

        configCameraButtonEdgeConstraint(statusBarOrientation)
        configCameraButtonGravityConstraint(portrait)

        removeCloseButtonConstraints()
        configCloseButtonEdgeConstraint(statusBarOrientation)
        configCloseButtonGravityConstraint(statusBarOrientation)

        removeContainerConstraints()
        configContainerEdgeConstraint(statusBarOrientation)
        configContainerGravityConstraint(statusBarOrientation)

        removeSwapButtonConstraints()
        configSwapButtonEdgeConstraint(statusBarOrientation)
        configSwapButtonGravityConstraint(portrait)

        removeLibraryButtonConstraints()
        configLibraryEdgeButtonConstraint(statusBarOrientation)
        configLibraryGravityButtonConstraint(portrait)

        configFlashEdgeButtonConstraint(statusBarOrientation)
        configFlashGravityButtonConstraint(statusBarOrientation)

        let padding: CGFloat = portrait ? 16.0 : -16.0
        removeCameraOverlayEdgesConstraints()
        configCameraOverlayEdgeOneContraint(portrait, padding: padding)
        configCameraOverlayEdgeTwoConstraint(portrait, padding: padding)
        configCameraOverlayWidthConstraint(portrait)
        configCameraOverlayCenterConstraint(portrait)

        rotate(actualInterfaceOrientation: statusBarOrientation)

        super.updateViewConstraints()
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
        setupActions()
        checkPermissions()
        cameraView.configureFocus()
    }

    /**
     * Start the session of the camera.
     */
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraView.startSession()
        addCameraObserver()
        addRotateObserver()
        if allowAudio {
            setupVolumeControl()
        }
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
        NotificationCenter.default.removeObserver(self)
        volumeControl = nil
    }

    /**
     * This method will disable the rotation of the
     */
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        lastInterfaceOrientation = UIApplication.shared.statusBarOrientation
        if animationRunning {
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        coordinator.animate(alongsideTransition: { [weak self] _ in
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
            name: .AVCaptureSessionDidStartRunning,
            object: nil)
    }

    /**
     * Observer the device orientation to update the
     * orientation of CameraView.
     */
    private func addRotateObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rotateCameraView),
            name: .UIDeviceOrientationDidChange,
            object: nil)
    }

    internal func notifyCameraReady() {
        cameraButton.isEnabled = true
    }

    /**
     * Attach the take of picture for any volume button.
     */
    private func setupVolumeControl() {
        volumeControl = VolumeControl(view: view, enableAudio: allowAudio) { [weak self] _ in
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
        [
            cameraButton,
            closeButton,
            swapButton,
            libraryButton,
        ].forEach({ $0.isEnabled = enabled })
    }

    func rotateCameraView() {
        cameraView.rotatePreview()
    }

    /**
     * This method will rotate the buttons based on
     * the last and actual orientation of the device.
     */
    internal func rotate(actualInterfaceOrientation: UIInterfaceOrientation) {

        if lastInterfaceOrientation != nil {
            let lastTransform = CGAffineTransform(rotationAngle: radians(currentRotation(
                lastInterfaceOrientation!, newOrientation: actualInterfaceOrientation)))
            setTransform(transform: lastTransform)
        }

        let transform = CGAffineTransform(rotationAngle: 0)
        animationRunning = true

        /**
         * Dispatch delay to avoid any conflict between the CATransaction of rotation of the screen
         * and CATransaction of animation of buttons.
         */

        let duration = animationDuration
        let spring = animationSpring
        let options = rotateAnimation

        let time: DispatchTime = DispatchTime.now() + Double(1 * UInt64(NSEC_PER_SEC) / 10)
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in

            guard let _ = self else {
                return
            }

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
            cameraView.capturePhoto(scale: outputScale, completion: { [weak self] imageData, image, errorData, exifData in
                guard let image = image, let imageData = imageData else {
                    self?.toggleButtons(enabled: true)
                    return
                }
                self?.saveImage(imageData: imageData, image: image, errorData: errorData, exifData: exifData)
            })
        }
    }

    internal func saveImage(imageData: Data, image: UIImage, errorData: String?, exifData: String?) {
        let spinner = showSpinner()
        cameraView.preview.isHidden = true

        if allowsLibraryAccess {
            _ = SingleImageSaver()
                .setImage(image)
                .onSuccess { [weak self] asset in
                    self?.layoutCameraResult(asset: asset)
                    self?.hideSpinner(spinner)
                }
                .onFailure { [weak self] _ in
                    self?.toggleButtons(enabled: true)
                    self?.showNoPermissionsView(library: true)
                    self?.cameraView.preview.isHidden = false
                    self?.hideSpinner(spinner)
                }
                .save()
        } else {
            layoutCameraResult(imageData: imageData, uiImage: image, errorData: errorData, exifData: exifData)
            hideSpinner(spinner)
        }
    }

    internal func close() {
        onCompletion?(nil, nil, nil, nil, nil)
        onCompletion = nil
    }

    internal func showLibrary() {
        let imagePicker = CameraViewController.imagePickerViewController(croppingEnabled: allowCropping) { [weak self] imageData, image, asset, errorData, exifData in
            defer {
                self?.dismiss(animated: true, completion: nil)
            }

            guard let image = image, let asset = asset else {
                return
            }

            self?.onCompletion?(imageData, image, asset, errorData, exifData)
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

        let image = UIImage(named: flashImage(device.flashMode),
                            in: CameraGlobals.shared.bundle,
                            compatibleWith: nil)

        flashButton.setImage(image, for: .normal)
    }

    internal func swapCamera() {
        cameraView.swapCameraInput()
        flashButton.isHidden = cameraView.currentPosition == AVCaptureDevicePosition.front
    }

    internal func layoutCameraResult(imageData: Data, uiImage: UIImage, errorData: String?, exifData: String?) {
        cameraView.stopSession()
        startConfirmController(imageData: imageData, uiImage: uiImage, errorData: errorData, exifData: exifData)
        toggleButtons(enabled: true)
    }

    internal func layoutCameraResult(asset: PHAsset) {
        cameraView.stopSession()
        startConfirmController(asset: asset)
        toggleButtons(enabled: true)
    }

    private func startConfirmController(imageData: Data, uiImage: UIImage, errorData: String?, exifData: String?) {
        let confirmViewController = ConfirmViewController(imageData: imageData, image: uiImage, errorData: errorData, exifData: exifData, allowsCropping: allowCropping)
        confirmViewController.onComplete = { [weak self] imageData, image, asset, errorData, exifData in
            defer {
                confirmViewController.modalTransitionStyle = .crossDissolve
                self?.dismiss(animated: true, completion: nil)
            }

            guard let image = image, let imageData = imageData else {
                return
            }

            self?.onCompletion?(imageData, image, asset, errorData, exifData)
            self?.onCompletion = nil
        }
        confirmViewController.modalTransitionStyle = .crossDissolve
        present(confirmViewController, animated: true, completion: nil)
    }

    private func startConfirmController(asset: PHAsset) {
        let confirmViewController = ConfirmViewController(asset: asset, allowsCropping: allowCropping)
        confirmViewController.onComplete = { [weak self] imageData, image, asset, errorData, exifData in
            defer {
                self?.modalTransitionStyle = .partialCurl
                self?.dismiss(animated: true, completion: nil)
            }

            guard let image = image, let asset = asset, let imageData = imageData else {
                return
            }

            self?.onCompletion?(imageData, image, asset, errorData, exifData)
            self?.onCompletion = nil
        }
        confirmViewController.modalTransitionStyle = .crossDissolve
        present(confirmViewController, animated: true, completion: nil)
    }

    private func showSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .white
        spinner.center = view.center
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
