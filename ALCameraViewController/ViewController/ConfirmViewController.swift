//
//  ALConfirmViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public class ConfirmViewController: UIViewController, UIScrollViewDelegate {
    
    let imageView = UIImageView()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cropOverlay: CropOverlay!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var centeringView: UIView!
    
    var allowsCropping: Bool = false
    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    
    public var onComplete: CameraViewCompletion?
    
    var asset: PHAsset!
    
    public init(asset: PHAsset, allowsCropping: Bool) {
        self.allowsCropping = allowsCropping
        self.asset = asset
        super.init(nibName: "ConfirmViewController", bundle: CameraGlobals.shared.bundle)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1
        
        cropOverlay.isHidden = true
        
        guard let asset = asset else {
            return
        }
        
        let spinner = showSpinner()
        
        disable()

        _ = SingleImageFetcher()
            .setAsset(asset)
            .setTargetSize(largestPhotoSize())
            .onSuccess { image in
                self.configureWithImage(image)
                self.hideSpinner(spinner)
                self.enable()
            }
            .onFailure { error in
                self.hideSpinner(spinner)
            }
            .fetch()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let scale = calculateMinimumScale(view.frame.size)
        let frame = allowsCropping ? cropOverlay.frame : view.bounds

        scrollView.contentInset = calculateScrollViewInsets(frame)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        centerScrollViewContents()
        centerImageViewOnRotate()
    }
	
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let scale = calculateMinimumScale(size)
        var frame = view.bounds
        
        if allowsCropping {
            frame = cropOverlay.frame
            let centeringFrame = centeringView.frame
            var origin: CGPoint
            
            if size.width > size.height { // landscape
                let offset = (size.width - centeringFrame.height)
                let expectedX = (centeringFrame.height/2 - frame.height/2) + offset
                origin = CGPoint(x: expectedX, y: frame.origin.x)
            } else {
                let expectedY = (centeringFrame.width/2 - frame.width/2)
                origin = CGPoint(x: frame.origin.y, y: expectedY)
            }
            
            frame.origin = origin
        } else {
            frame.size = size
        }
        
        coordinator.animate(alongsideTransition: { context in
            self.scrollView.contentInset = self.calculateScrollViewInsets(frame)
            self.scrollView.minimumZoomScale = scale
            self.scrollView.zoomScale = scale
            self.centerScrollViewContents()
            self.centerImageViewOnRotate()
            }, completion: nil)
    }
    
    private func configureWithImage(_ image: UIImage) {
        if allowsCropping {
            cropOverlay.isHidden = false
        } else {
            cropOverlay.isHidden = true
        }
        
        buttonActions()
        
        imageView.image = image
        imageView.sizeToFit()
        view.setNeedsLayout()
    }
    
    private func calculateMinimumScale(_ size: CGSize) -> CGFloat {
        var _size = size
        
        if allowsCropping {
            _size = cropOverlay.frame.size
        }
        
        guard let image = imageView.image else {
            return 1
        }
        
        let scaleWidth = _size.width / image.size.width
        let scaleHeight = _size.height / image.size.height
        
        var scale: CGFloat
        
        if allowsCropping {
            scale = max(scaleWidth, scaleHeight)
        } else {
            scale = min(scaleWidth, scaleHeight)
        }
        
        return scale
    }
    
    private func calculateScrollViewInsets(_ frame: CGRect) -> UIEdgeInsets {
        let bottom = view.frame.height - (frame.origin.y + frame.height)
        let right = view.frame.width - (frame.origin.x + frame.width)
        let insets = UIEdgeInsets(top: frame.origin.y, left: frame.origin.x, bottom: bottom, right: right)
        return insets
    }
    
    private func centerImageViewOnRotate() {
        if allowsCropping {
            let size = allowsCropping ? cropOverlay.frame.size : scrollView.frame.size
            let scrollInsets = scrollView.contentInset
            let imageSize = imageView.frame.size
            var contentOffset = CGPoint(x: -scrollInsets.left, y: -scrollInsets.top)
            contentOffset.x -= (size.width - imageSize.width) / 2
            contentOffset.y -= (size.height - imageSize.height) / 2
            scrollView.contentOffset = contentOffset
        }
    }
    
    private func centerScrollViewContents() {
        let size = allowsCropping ? cropOverlay.frame.size : scrollView.frame.size
        let imageSize = imageView.frame.size
        var imageOrigin = CGPoint.zero
        
        if imageSize.width < size.width {
            imageOrigin.x = (size.width - imageSize.width) / 2
        }
        
        if imageSize.height < size.height {
            imageOrigin.y = (size.height - imageSize.height) / 2
        }
        
        imageView.frame.origin = imageOrigin
    }
    
    private func buttonActions() {
        confirmButton.action = { [weak self] in self?.confirmPhoto() }
        cancelButton.action = { [weak self] in self?.cancel() }
    }
    
    internal func cancel() {
        onComplete?(nil, nil)
    }
    
    internal func confirmPhoto() {
        
        disable()
		
		imageView.isHidden = true
		
		let spinner = showSpinner()
		
		var fetcher = SingleImageFetcher()
			.onSuccess { image in
				self.onComplete?(image, self.asset)
				self.hideSpinner(spinner)
				self.enable()
			}
			.onFailure { error in
				self.hideSpinner(spinner)
				self.showNoImageScreen(error)
			}
			.setAsset(asset)
		
		if allowsCropping {
			
			var cropRect = CGRect(x: cropOverlay.frame.origin.x + cropOverlay.outterGap, y: cropOverlay.frame.origin.y + cropOverlay.outterGap, width: cropOverlay.frame.size.width - cropOverlay.outterGap * 2, height: cropOverlay.frame.size.height - cropOverlay.outterGap * 2)
			cropRect.origin.x += scrollView.contentOffset.x
            cropRect.origin.y += scrollView.contentOffset.y
			
            let normalizedX = cropRect.origin.x / imageView.frame.width
            let normalizedY = cropRect.origin.y / imageView.frame.height
            
            let normalizedWidth = cropRect.width / imageView.frame.width
            let normalizedHeight = cropRect.height / imageView.frame.height
            
            let rect = normalizedRect(CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight), orientation: imageView.image!.imageOrientation)
            
            fetcher = fetcher.setCropRect(rect)
        }
        
        fetcher = fetcher.fetch()
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func showSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .white
        spinner.center = view.center
        spinner.startAnimating()
        
        view.addSubview(spinner)
        view.bringSubview(toFront: spinner)
        
        return spinner
    }
    
    func hideSpinner(_ spinner: UIActivityIndicatorView) {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    func disable() {
        confirmButton.isEnabled = false
    }
    
    func enable() {
        confirmButton.isEnabled = true
    }
    
    func showNoImageScreen(_ error: NSError) {
        let permissionsView = PermissionsView(frame: view.bounds)
        
        let desc = localizedString("error.cant-fetch-photo.description")
        
        permissionsView.configureInView(view, title: error.localizedDescription, descriptiom: desc, completion: cancel)
    }
    
}
