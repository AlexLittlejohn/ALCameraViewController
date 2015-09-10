//
//  ALConfirmViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal class ALConfirmViewController: UIViewController, UIScrollViewDelegate {
    
    let imageView = UIImageView()
    let scrollView = UIScrollView()
    let cropView = ALCropOverlay()
    
    let cropPreview = UIImageView()
    
    let confirmButton = UIButton()
    let cancelButton = UIButton()
    
    let allowsCropping: Bool
    let image: UIImage
    
    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    
    var onComplete: ALCameraViewCompletion?
    
    internal init(image: UIImage, allowsCropping: Bool) {
        self.allowsCropping = allowsCropping
        self.image = image
        super.init(nibName: nil, bundle: nil)
        
        if UIScreen.mainScreen().bounds.size.width <= 320 {
            verticalPadding = 15
            horizontalPadding = 15
        }
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    internal override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        
        imageView.image = image
        imageView.sizeToFit()
        
        scrollView.frame = view.bounds
        scrollView.addSubview(imageView)
        scrollView.contentSize = imageView.frame.size
        scrollView.delegate = self
        
        if allowsCropping {
            view.addSubview(cropView)
        }
        
        let scale = calculateMinimumScale()
        
        scrollView.minimumZoomScale = scale
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = scale
        
        layoutButtons()
        confirmationBeginState()
        centerScrollViewContents()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func rotate() {
        
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
    }
    
    internal override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        SpringAnimation {
            self.confirmationEndState()
        }
    }
    
    internal override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        SpringAnimation {
            self.confirmationBeginState()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        SpringAnimation {
            self.confirmationEndState()
        }
        
        centerScrollViewContents()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        centerScrollViewContents()
        
        let scale = calculateMinimumScale()
        
        print("scale: \(scale)")
        
        scrollView.minimumZoomScale = scale
        scrollView.setZoomScale(scale, animated: true)
    }

    private func calculateMinimumScale() -> CGFloat {
        var minScale: CGFloat
        
        if allowsCropping {
            
            let width = view.frame.size.width - horizontalPadding
            let height = width
            let x = horizontalPadding/2
            let cameraButtonY = view.frame.size.height - (verticalPadding + 80)
            let y = cameraButtonY/2 - height/2
            let yy = view.frame.size.height - (y + height)
            let frame = CGRectMake(x, y, width, height)
            let scaleWidth = frame.size.width / scrollView.contentSize.width
            let scaleHeight = frame.size.height / scrollView.contentSize.height
            minScale = fmax(scaleWidth, scaleHeight)
            
            cropView.frame = frame
            scrollView.contentInset = UIEdgeInsetsMake(cropView.frame.origin.y, cropView.frame.origin.x, yy, cropView.frame.origin.x)
        } else {
            let frame = view.frame
            let scaleWidth = frame.size.width / scrollView.contentSize.width
            let scaleHeight = frame.size.height / scrollView.contentSize.height
            minScale = fmin(scaleWidth, scaleHeight)
        }
        
        return minScale
    }
    
    private func centerScrollViewContents() {
        var size: CGSize
        
        if allowsCropping {
            size = cropView.frame.size
        } else {
            size = scrollView.frame.size
        }
        
        var contentFrame = imageView.frame
        
        if contentFrame.size.width < size.width {
            contentFrame.origin.x = (size.width - contentFrame.size.width) / 2
        } else {
            contentFrame.origin.x = 0
        }
        
        if contentFrame.size.height < size.height {
            contentFrame.origin.y = (size.height - contentFrame.size.height) / 2
        } else {
            contentFrame.origin.y = 0
        }
        
        imageView.frame = contentFrame
    }
    
    private func layoutButtons() {
        confirmButton.setImage(UIImage(named: "confirmButton", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        confirmButton.addTarget(self, action: "confirmPhoto", forControlEvents: UIControlEvents.TouchUpInside)
        cancelButton.setImage(UIImage(named: "retakeButton", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)
        
        confirmButton.sizeToFit()
        cancelButton.sizeToFit()
        
        view.addSubview(confirmButton)
        view.addSubview(cancelButton)
    }
    
    private func confirmationBeginState() {
        let size = view.frame.size
        
        let confirmSize = confirmButton.frame.size
        let initialX = size.width/2 - confirmSize.width/2
        let initialY = size.height + verticalPadding
        
        confirmButton.frame.origin = CGPointMake(initialX, initialY)
        confirmButton.alpha = 0
        cancelButton.frame.origin = CGPointMake(initialX, initialY)
        cancelButton.alpha = 0
    }
    
    private func confirmationEndState() {
        let size = view.frame.size
        
        let confirmSize = confirmButton.frame.size
        
        let confirmX = size.width/2 + horizontalPadding
        let confirmY = size.height - (confirmSize.height + verticalPadding)
        
        confirmButton.frame.origin = CGPointMake(confirmX, confirmY)
        confirmButton.alpha =  1
        let retakeX = size.width/2 - (confirmSize.width + horizontalPadding)
        let retakeY = confirmY
        
        cancelButton.frame.origin = CGPointMake(retakeX, retakeY)
        cancelButton.alpha = 1
    }
    
    internal func cancel() {
        onComplete?(nil)
    }
    
    internal func confirmPhoto() {
        if allowsCropping {
            
            var cropFrame = cropView.frame
            cropFrame.origin.x += scrollView.contentOffset.x
            cropFrame.origin.y += scrollView.contentOffset.y
            
            let croppedImage = image.crop(cropFrame, scale: scrollView.zoomScale)
            
            onComplete?(croppedImage)
        } else {
            onComplete?(image)
        }
    }
    
    internal func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    internal func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}