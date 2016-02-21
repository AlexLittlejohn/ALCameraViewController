//
//  ALConfirmViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

internal class ConfirmViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    let imageView = UIImageView()
    @IBOutlet weak var cropOverlay: CropOverlay!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var centeringView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var allowsCropping: Bool = false
    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    
    var onComplete: ALCameraViewCompletion?
    
    var asset: PHAsset!
    
    internal init(asset: PHAsset, allowsCropping: Bool) {
        self.allowsCropping = allowsCropping
        self.asset = asset
        super.init(nibName: "ConfirmViewController", bundle: CameraGlobals.shared.bundle)
        commonInit()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInit() {
        if UIScreen.mainScreen().bounds.width <= 320 {
            horizontalPadding = 15
        }
    }
    
    internal override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    internal override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.blackColor()
        
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1
        
        cropOverlay.hidden = true
        
        guard let asset = asset else {
            return
        }
        
        spinner.startAnimating()
        
        SingleImageFetcher()
            .setAsset(asset)
            .setTargetSize(largestPhotoSize())
            .onSuccess { image in
                self.configureWithImage(image)
                self.spinner.stopAnimating()
            }
            .onFailure { error in
                self.spinner.stopAnimating()
            }
            .fetch()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let scale = calculateMinimumScale(view.frame.size)
        let frame = allowsCropping ? cropOverlay.frame : view.bounds

        scrollView.contentInset = calculateScrollViewInsets(frame)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        centerScrollViewContents()
        centerImageViewOnRotate()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
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
        
        coordinator.animateAlongsideTransition({ context in
            self.scrollView.contentInset = self.calculateScrollViewInsets(frame)
            self.scrollView.minimumZoomScale = scale
            self.scrollView.zoomScale = scale
            self.centerScrollViewContents()
            self.centerImageViewOnRotate()
            }, completion: nil)
    }
    
    private func configureWithImage(image: UIImage) {
        if allowsCropping {
            cropOverlay.hidden = false
        } else {
            cropOverlay.hidden = true
        }
        
        buttonActions()
        
        imageView.image = image
        imageView.sizeToFit()
        view.setNeedsLayout()
    }
    
    private func calculateMinimumScale(size: CGSize) -> CGFloat {
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
    
    private func calculateScrollViewInsets(frame: CGRect) -> UIEdgeInsets {
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
        confirmButton.addTarget(self, action: "confirmPhoto", forControlEvents: UIControlEvents.TouchUpInside)
        cancelButton.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    internal func cancel() {
        onComplete?(nil)
    }
    
    internal func confirmPhoto() {
        
        imageView.hidden = true
        spinner.startAnimating()
        
        let fetcher = SingleImageFetcher()
            .onSuccess { image in
                self.onComplete?(image)
                self.spinner.stopAnimating()
           }
            .onFailure { error in            
                self.spinner.stopAnimating()
            }
            .setAsset(asset)
        
        if allowsCropping {
            
            var cropRect = cropOverlay.frame
            cropRect.origin.x += scrollView.contentOffset.x
            cropRect.origin.y += scrollView.contentOffset.y
            
            let normalizedX = cropRect.origin.x / imageView.frame.width
            let normalizedY = cropRect.origin.y / imageView.frame.height
            
            let normalizedWidth = cropRect.width / imageView.frame.width
            let normalizedHeight = cropRect.height / imageView.frame.height
            
            let rect = normalizedRect(CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight), orientation: imageView.image!.imageOrientation)
            
            fetcher.setCropRect(rect)
        }
        
        fetcher.fetch()
    }
    
    internal func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    internal func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}