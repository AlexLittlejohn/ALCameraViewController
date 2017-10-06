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

    let asset: PHAsset?
    let image: UIImage?
    let imageData: Data?

    public init(imageData: Data, image: UIImage, allowsCropping: Bool) {
        self.allowsCropping = allowsCropping
        asset = nil
        self.imageData = imageData
        self.image = image
        super.init(nibName: "ConfirmViewController", bundle: CameraGlobals.shared.bundle)
    }

    public init(asset: PHAsset, allowsCropping: Bool) {
        self.allowsCropping = allowsCropping
        self.asset = asset
        image = nil
        imageData = nil
        super.init(nibName: "ConfirmViewController", bundle: CameraGlobals.shared.bundle)
    }

    public required init?(coder aDecoder: NSCoder) {
        asset = nil
        image = nil
        imageData = nil
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

        let spinner = showSpinner()

        disable()

        if let asset = asset {
            _ = SingleImageFetcher()
                .setAsset(asset)
                .setTargetSize(largestPhotoSize())
                .onSuccess { [weak self] image in
                    self?.configureWithImage(image)
                    self?.hideSpinner(spinner)
                    self?.enable()
                }
                .onFailure { [weak self] _ in
                    self?.hideSpinner(spinner)
                }
                .fetch()
        } else if let image = image {
            configureWithImage(image)
            hideSpinner(spinner)
            enable()
        }
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
                let expectedX = (centeringFrame.height / 2 - frame.height / 2) + offset
                origin = CGPoint(x: expectedX, y: frame.origin.x)
            } else {
                let expectedY = (centeringFrame.width / 2 - frame.width / 2)
                origin = CGPoint(x: frame.origin.y, y: expectedY)
            }

            frame.origin = origin
        } else {
            frame.size = size
        }

        let insets = calculateScrollViewInsets(frame)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.scrollView.contentInset = insets
            self?.scrollView.minimumZoomScale = scale
            self?.scrollView.zoomScale = scale
            self?.centerScrollViewContents()
            self?.centerImageViewOnRotate()
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
        onComplete?(nil, nil, nil, nil, nil)
    }

    internal func confirmPhoto() {

        guard let image = image else {
            return
        }

        disable()

        imageView.isHidden = true

        let spinner = showSpinner()

        if let asset = asset {
            var fetcher = SingleImageFetcher()
                .onSuccess { [weak self] image in
                self?.onComplete?(nil, image, self?.asset, nil, nil)
                self?.hideSpinner(spinner)
                self?.enable()
            }
            .onFailure { [weak self] error in
                self?.hideSpinner(spinner)
                self?.showNoImageScreen(error)
            }
            .setAsset(asset)
            if allowsCropping {
                let rect = normalizedRect(makeProportionalCropRect(), orientation: image.imageOrientation)
                fetcher = fetcher.setCropRect(rect)
            }

            fetcher = fetcher.fetch()
        } else {
            var newImage = image

            if allowsCropping {
                let cropRect = makeProportionalCropRect()
                let resizedCropRect = CGRect(x: (image.size.width) * cropRect.origin.x,
                                             y: (image.size.height) * cropRect.origin.y,
                                             width: (image.size.width * cropRect.width),
                                             height: (image.size.height * cropRect.height))
                newImage = image.crop(rect: resizedCropRect)
            }

            onComplete?(imageData, newImage, nil, nil, nil)
            hideSpinner(spinner)
            enable()
        }
    }

    public func viewForZooming(in _: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_: UIScrollView) {
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

        permissionsView.configureInView(view, title: error.localizedDescription, description: desc, completion: { [weak self] in self?.cancel() })
    }

    private func makeProportionalCropRect() -> CGRect {
        var cropRect = cropOverlay.frame
        cropRect.origin.x += scrollView.contentOffset.x
        cropRect.origin.y += scrollView.contentOffset.y

        let normalizedX = cropRect.origin.x / imageView.frame.width
        let normalizedY = cropRect.origin.y / imageView.frame.height

        let normalizedWidth = cropRect.width / imageView.frame.width
        let normalizedHeight = cropRect.height / imageView.frame.height

        return CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    }
}

extension UIImage {
    func crop(rect: CGRect) -> UIImage {

        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: radians(90)).translatedBy(x: 0, y: -size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: radians(-90)).translatedBy(x: -size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: radians(-180)).translatedBy(x: -size.width, y: -size.height)
        default:
            rectTransform = CGAffineTransform.identity
        }

        rectTransform = rectTransform.scaledBy(x: scale, y: scale)

        if let cropped = cgImage?.cropping(to: rect.applying(rectTransform)) {
            return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation).fixOrientation()
        }

        return self
    }

    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
