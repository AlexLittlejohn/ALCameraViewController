//
//  ALConfirmViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal class ALConfirmViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    let imageView = UIImageView()
    @IBOutlet weak var cropOverlay: ALCropOverlay!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var centeringView: UIView!
    
    var allowsCropping: Bool = false
    var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.sizeToFit()
        }
    }
    
    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    
    var onComplete: ALCameraViewCompletion?
    
    internal init(image: UIImage, allowsCropping: Bool) {
        self.allowsCropping = allowsCropping
        self.image = image
        super.init(nibName: "ALConfirmViewController", bundle: NSBundle(forClass: ALCameraViewController.self))
        commonInit()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        self.image = UIImage()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        if UIScreen.mainScreen().bounds.size.width <= 320 {
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
        
        imageView.image = image
        imageView.sizeToFit()
        
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1
        
        if allowsCropping {
            cropOverlay.hidden = false
        } else {
            cropOverlay.hidden = true
        }
        
        buttonActions()
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
                let offset = (size.width - centeringFrame.size.height)
                let expectedX = (centeringFrame.size.height/2 - frame.size.height/2) + offset
                origin = CGPointMake(expectedX, frame.origin.x)
            } else {
                let expectedY = (centeringFrame.size.width/2 - frame.size.width/2)
                origin = CGPointMake(frame.origin.y, expectedY)
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
    
    private func calculateMinimumScale(size: CGSize) -> CGFloat {
        var _size = size
        
        if allowsCropping {
            _size = cropOverlay.frame.size
        }
        
        let scaleWidth = _size.width / image!.size.width
        let scaleHeight = _size.height / image!.size.height
        
        var scale: CGFloat
        
        if allowsCropping {
            scale = fmax(scaleWidth, scaleHeight)
        } else {
            scale = fmin(scaleWidth, scaleHeight)
        }
        
        return scale
    }
    
    private func calculateScrollViewInsets(frame: CGRect) -> UIEdgeInsets {
        let size = view.frame.size
        let bottom = size.height - (frame.origin.y + frame.size.height)
        let right = size.width - (frame.origin.x + frame.size.width)
        let insets = UIEdgeInsetsMake(frame.origin.y, frame.origin.x, bottom, right)
        return insets
    }
    
    private func centerImageViewOnRotate() {
        if allowsCropping {
            let size = allowsCropping ? cropOverlay.frame.size : scrollView.frame.size
            let scrollInsets = scrollView.contentInset
            let imageSize = imageView.frame.size
            var contentOffset = CGPointMake(-scrollInsets.left, -scrollInsets.top)
            contentOffset.x -= (size.width - imageSize.width) / 2
            contentOffset.y -= (size.height - imageSize.height) / 2
            scrollView.contentOffset = contentOffset
        }
    }
    
    private func centerScrollViewContents() {
        let size = allowsCropping ? cropOverlay.frame.size : scrollView.frame.size
        let imageSize = imageView.frame.size
        var imageOrigin = CGPointZero
        
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
        if allowsCropping {
            
            var cropFrame = cropOverlay.frame
            cropFrame.origin.x += scrollView.contentOffset.x
            cropFrame.origin.y += scrollView.contentOffset.y
            cropFrame.origin.x /= scrollView.zoomScale
            cropFrame.origin.y /= scrollView.zoomScale
            cropFrame.size.width /= scrollView.zoomScale
            cropFrame.size.height /= scrollView.zoomScale
            
            var croppedImage: UIImage? = nil
            if let i = image {
                croppedImage = i.crop(cropFrame, scale: 1)
            }
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