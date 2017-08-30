//
//  ALCropViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public class CropViewController: UIViewController, UIScrollViewDelegate {
	
	let imageView = UIImageView()
	@IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var cropOverlayHeight: NSLayoutConstraint!
  @IBOutlet weak var cropOverlayWidth: NSLayoutConstraint!
	@IBOutlet weak var cropOverlay: OverlayView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
  @IBOutlet weak var borderDetectionButton: UIButton!
  
	var allowsCropping: Bool = false

  public var onComplete: CameraViewCompletion?
	
	let asset: PHAsset?
	let image: UIImage?
	
	public init(image: UIImage, allowsCropping: Bool) {
		self.allowsCropping = allowsCropping
		self.asset = nil
		self.image = image
		super.init(nibName: "CropViewController", bundle: CameraGlobals.shared.bundle)
	}
	
	public init(asset: PHAsset, allowsCropping: Bool) {
		self.allowsCropping = allowsCropping
		self.asset = asset
		self.image = nil
		super.init(nibName: "CropViewController", bundle: CameraGlobals.shared.bundle)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		asset = nil
		image = nil
		super.init(coder: aDecoder)
	}
	
	public override var prefersStatusBarHidden: Bool {
		return true
	}
	
	public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return UIStatusBarAnimation.slide
	}
  
  open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
    self.navigationController?.isNavigationBarHidden = true
		
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
				.onFailure { [weak self] error in
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
		let scale = calculateMinimumScale(scrollView.frame.size)
		let frame = scrollView.bounds
		
		scrollView.contentInset = calculateScrollViewInsets(frame)
		scrollView.minimumZoomScale = scale
    scrollView.maximumZoomScale = scale
		scrollView.zoomScale = scale
		centerScrollViewContents()
//		centerImageViewOnRotate()
    centerOverlayView()
    
	}
	
	public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		let scale = calculateMinimumScale(size)
		var frame = view.bounds
		
		if allowsCropping {
			frame = scrollView.frame
			let centeringFrame = scrollView.frame
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
		
		let insets = calculateScrollViewInsets(frame)
		
		coordinator.animate(alongsideTransition: { [weak self] context in
			self?.scrollView.contentInset = insets
			self?.scrollView.minimumZoomScale = scale
			self?.scrollView.zoomScale = scale
			self?.centerScrollViewContents()
			self?.centerImageViewOnRotate()
      self?.centerOverlayView()
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
		let _size = size
//		
//		if allowsCropping {
//			_size = cropOverlay.frame.size
//		}
		
		guard let image = imageView.image else {
			return 1
		}
		
		let scaleWidth = _size.width / image.size.width
		let scaleHeight = _size.height / image.size.height
		
		var scale: CGFloat
		
		if allowsCropping {
			scale = min(scaleWidth, scaleHeight)
		} else {
			scale = min(scaleWidth, scaleHeight)
		}
		
		return scale
	}
	
	private func calculateScrollViewInsets(_ frame: CGRect) -> UIEdgeInsets {
		let bottom = scrollView.frame.height - (frame.origin.y + frame.height)
		let right = scrollView.frame.width - (frame.origin.x + frame.width)
		let insets = UIEdgeInsets(top: frame.origin.y, left: frame.origin.x, bottom: bottom, right: right)
		return insets
	}
	
	private func centerImageViewOnRotate() {
		if allowsCropping {
//			let size = allowsCropping ? cropOverlay.frame.size : scrollView.frame.size
      let size = scrollView.frame.size

			let scrollInsets = scrollView.contentInset
			let imageSize = imageView.frame.size
			var contentOffset = CGPoint(x: -scrollInsets.left, y: -scrollInsets.top)
			contentOffset.x -= (size.width - imageSize.width) / 2
			contentOffset.y -= (size.height - imageSize.height) / 2
			scrollView.contentOffset = contentOffset
		}
	}
	
	private func centerScrollViewContents() {
//		let size = allowsCropping ? cropOverlay.frame.size : scrollView.frame.size
    let size = scrollView.frame.size
    
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
  
  func centerOverlayView() {
    let frame = scrollView.convert(imageView.frame, to: self.view)
    cropOverlayWidth.constant = frame.size.width
    cropOverlayHeight.constant = frame.size.height
    cropOverlay.setNeedsDisplay()
  }
	
	private func buttonActions() {
		confirmButton.action = { [weak self] in self?.confirmPhoto() }
		cancelButton.action = { [weak self] in self?.cancel() }
    borderDetectionButton.action = { [weak self] in self?.detectBorders() }
	}
  
  func detectBorders() {
    if cropOverlay.detectBorders(imageView) {
      print("found borders")
    }
    else {
      print("no borders")
    }
    borderDetectionButton.setTitle("Select All", for: .normal)
    borderDetectionButton.action = { [weak self] in self?.selectAllBorders() }
  }
  
  func selectAllBorders() {
    cropOverlay.layoutButtons()
    
    borderDetectionButton.setTitle("Find Borders", for: .normal)
    borderDetectionButton.action = { [weak self] in self?.detectBorders() }
  }
	
	internal func cancel() {
		onComplete?(nil, nil)
	}
	
	internal func confirmPhoto() {
		
		guard let image = imageView.image else {
			return
		}
		
		disable()
				
		let spinner = showSpinner()
		
//		if let asset = asset {
//			var fetcher = SingleImageFetcher()
//				.onSuccess { [weak self] image in
//					self?.onComplete?(image, self?.asset)
//					self?.hideSpinner(spinner)
//					self?.enable()
//				}
//				.onFailure { [weak self] error in
//					self?.hideSpinner(spinner)
//					self?.showNoImageScreen(error)
//				}
//				.setAsset(asset)
//			if allowsCropping {
//				let rect = normalizedRect(makeProportionalCropRect(), orientation: image.imageOrientation)
//				fetcher = fetcher.setCropRect(rect)
//			}
//			
//			fetcher = fetcher.fetch()
//		} else {
			var newImage = image
			
			if allowsCropping {
        newImage = cropOverlay.cropImage(imageView)
//				let cropRect = makeProportionalCropRect()
//				let   resizedCropRect = CGRect(x: (image.size.width) * cropRect.origin.x,
//				                     y: (image.size.height) * cropRect.origin.y,
//				                     width: (image.size.width * cropRect.width),
//				                     height: (image.size.height * cropRect.height))
//				newImage = image.crop(rect: resizedCropRect)
        self.startConfimController(uiImage: newImage)
			}
      else {
        self.onComplete?(newImage,asset)
    }
      hideSpinner(spinner)
			enable()
//		}
	}
	
	public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	public func scrollViewDidZoom(_ scrollView: UIScrollView) {
		centerScrollViewContents()
	}
	
	func showSpinner() -> UIActivityIndicatorView {
		let spinner = UIActivityIndicatorView()
		spinner.activityIndicatorViewStyle = .whiteLarge
		spinner.center = view.center
		spinner.startAnimating()
    spinner.sizeToFit()
		
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
	
  private func startConfimController(uiImage: UIImage) {
    
    let confirmController = ConfirmViewController(uiImage, asset)
    confirmController.onComplete = { [weak self] image, asset in
      guard let image = image else {
        return
      }
      
      self?.onComplete?(image, asset)
      self?.onComplete = nil
    }
    
    self.navigationController?.pushViewController(confirmController, animated: false)
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
