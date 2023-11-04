//
//  ALConfirmViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public class ConfirmViewController: UIViewController {
	
	let imageView = UIImageView()
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var centeredView: UIView!

    private let cropOverlay = CropOverlay()
    private var spinner: UIActivityIndicatorView? = nil
    private var cropOverlayLeftConstraint = NSLayoutConstraint()
    private var cropOverlayTopConstraint = NSLayoutConstraint()
    private var cropOverlayWidthConstraint = NSLayoutConstraint()
    private var cropOverlayHeightConstraint = NSLayoutConstraint()
    private var isFirstLayout = true
	
    var croppingParameters: CroppingParameters {
        didSet {
            cropOverlay.isResizable = croppingParameters.allowResizing
            cropOverlay.minimumSize = croppingParameters.minimumSize
        }
    }

    private var scrollViewVisibleSize: CGSize {
        let contentInset = scrollView.contentInset
        let scrollViewSize = scrollView.bounds.standardized.size
        let width = scrollViewSize.width - contentInset.left - contentInset.right
        let height = scrollViewSize.height - contentInset.top - contentInset.bottom
        return CGSize(width:width, height:height)
    }

    private var scrollViewCenter: CGPoint {
        let scrollViewSize = scrollViewVisibleSize
        return CGPoint(x: scrollViewSize.width / 2.0,
                       y: scrollViewSize.height / 2.0)
    }

    private let cropOverlayDefaultPadding: CGFloat = 20
    private var cropOverlayDefaultFrame: CGRect {
        let buttonsViewGap: CGFloat = 20 * 2 + 64
        let centeredViewBounds: CGRect
        if view.bounds.size.height > view.bounds.size.width {
            centeredViewBounds = CGRect(x: 0,
                                        y: 0,
                                        width: view.bounds.size.width,
                                        height: view.bounds.size.height - buttonsViewGap)
        } else {
            centeredViewBounds = CGRect(x: 0,
                                        y: 0,
                                        width: view.bounds.size.width - buttonsViewGap,
                                        height: view.bounds.size.height)
        }
        
        let cropOverlayWidth = min(centeredViewBounds.size.width, centeredViewBounds.size.height) - 2 * cropOverlayDefaultPadding
        let cropOverlayX = centeredViewBounds.size.width / 2 - cropOverlayWidth / 2
        let cropOverlayY = centeredViewBounds.size.height / 2 - cropOverlayWidth / 2

        return CGRect(x: cropOverlayX,
                      y: cropOverlayY,
                      width: cropOverlayWidth,
                      height: cropOverlayWidth)
    }
	
	public var onComplete: CameraViewCompletion?

	let asset: PHAsset?
	let image: UIImage?
	
	public init(image: UIImage, croppingParameters: CroppingParameters) {
		self.croppingParameters = croppingParameters
		self.asset = nil
		self.image = image
		super.init(nibName: "ConfirmViewController", bundle: CameraGlobals.shared.bundle)
	}
	
	public init(asset: PHAsset, croppingParameters: CroppingParameters) {
		self.croppingParameters = croppingParameters
		self.asset = asset
		self.image = nil
		super.init(nibName: "ConfirmViewController", bundle: CameraGlobals.shared.bundle)
	}
	
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        loadScrollView()
        loadCropOverlay()

		showSpinner()
		
		disable()
		
		if let asset = asset {
			_ = SingleImageFetcher()
				.setAsset(asset)
				.setTargetSize(largestPhotoSize())
				.onSuccess { [weak self] image in
					self?.configureWithImage(image)
					self?.hideSpinner()
					self?.enable()
				}
				.onFailure { [weak self] error in
					self?.hideSpinner()
				}
				.fetch()
		} else if let image = image {
			configureWithImage(image)
			hideSpinner()
			enable()
		}
    
    if #available(iOS 9.0, *) {
      self.view.semanticContentAttribute = .forceLeftToRight
    } else {
      // Fallback on earlier versions
    }
	}

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isFirstLayout {
            isFirstLayout = false
            activateCropOverlayConstraint()
            spinner?.center = centeredView.center
        }
    }

    private func activateCropOverlayConstraint() {
        cropOverlayLeftConstraint.constant = cropOverlayDefaultFrame.origin.x
        cropOverlayTopConstraint.constant = cropOverlayDefaultFrame.origin.y
        cropOverlayWidthConstraint.constant = cropOverlayDefaultFrame.size.width
        cropOverlayHeightConstraint.constant = cropOverlayDefaultFrame.size.height

        cropOverlayLeftConstraint.isActive = true
        cropOverlayTopConstraint.isActive = true
        cropOverlayWidthConstraint.isActive = true
        cropOverlayHeightConstraint.isActive = true
    }

    private func loadScrollView() {
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1
    }

    private func prepareScrollView() {
        let scale = calculateMinimumScale(view.bounds.size)

        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale

        centerScrollViewContent()
    }

    private func loadCropOverlay() {
        cropOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cropOverlay)

        cropOverlayLeftConstraint = cropOverlay.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        cropOverlayTopConstraint = cropOverlay.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        cropOverlayWidthConstraint = cropOverlay.widthAnchor.constraint(equalToConstant: 0)
        cropOverlayHeightConstraint = cropOverlay.heightAnchor.constraint(equalToConstant: 0)

        cropOverlay.delegate = self
        cropOverlay.isHidden = !croppingParameters.isEnabled
        cropOverlay.isResizable = croppingParameters.allowResizing
        cropOverlay.isMovable = croppingParameters.allowMoving
        cropOverlay.minimumSize = croppingParameters.minimumSize
    }
	
	private func configureWithImage(_ image: UIImage) {
		buttonActions()
		
		imageView.image = image
		imageView.sizeToFit()
        prepareScrollView()
	}
	
	private func calculateMinimumScale(_ size: CGSize) -> CGFloat {
		var _size = size
		
		if croppingParameters.isEnabled {
            _size = cropOverlayDefaultFrame.size
		}
		
		guard let image = imageView.image else {
            return 1
		}
		
		let scaleWidth = _size.width / image.size.width
		let scaleHeight = _size.height / image.size.height

		return min(scaleWidth, scaleHeight)
	}
	
	private func centerScrollViewContent() {
        guard let image = imageView.image else {
            return
        }

        let imgViewSize = imageView.frame.size
        let imageSize = image.size

        var realImgSize: CGSize
        if imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height {
            realImgSize = CGSize(width: imgViewSize.width,height: imgViewSize.width / imageSize.width * imageSize.height)
        } else {
            realImgSize = CGSize(width: imgViewSize.height / imageSize.height * imageSize.width, height: imgViewSize.height)
        }

        var frame = CGRect.zero
        frame.size = realImgSize
        imageView.frame = frame

        let screenSize  = scrollView.frame.size
        let offx = screenSize.width > realImgSize.width ? (screenSize.width - realImgSize.width) / 2 : 0
        let offy = screenSize.height > realImgSize.height ? (screenSize.height - realImgSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: offy,
                                               left: offx,
                                               bottom: offy,
                                               right: offx)
	}
	
	private func buttonActions() {
		confirmButton.action = { [weak self] in self?.confirmPhoto() }
		cancelButton.action = { [weak self] in self?.cancel() }
	}
	
	internal func cancel() {
		onComplete?(nil, nil)
	}
	
	internal func confirmPhoto() {
		
		guard let image = imageView.image else {
			return
		}
		
		disable()
		
		imageView.isHidden = true
		
		showSpinner()
		
		if let asset = asset {
			var fetcher = SingleImageFetcher()
				.onSuccess { [weak self] image in
					self?.onComplete?(image, self?.asset)
					self?.hideSpinner()
					self?.enable()
				}
				.onFailure { [weak self] error in
					self?.hideSpinner()
					self?.showNoImageScreen(error)
				}
				.setAsset(asset)
			if croppingParameters.isEnabled {
				let rect = normalizedRect(makeProportionalCropRect(), orientation: image.imageOrientation)
				fetcher = fetcher.setCropRect(rect)
			}
			
			fetcher = fetcher.fetch()
		} else {
			var newImage = image
			
			if croppingParameters.isEnabled {
				let cropRect = makeProportionalCropRect()
				let resizedCropRect = CGRect(x: (image.size.width) * cropRect.origin.x,
				                     y: (image.size.height) * cropRect.origin.y,
				                     width: (image.size.width * cropRect.width),
				                     height: (image.size.height * cropRect.height))
				newImage = image.crop(rect: resizedCropRect)
			}
			
			onComplete?(newImage, nil)
			hideSpinner()
			enable()
		}
	}
	
	func showSpinner() {
		spinner = UIActivityIndicatorView()
        spinner!.style = .white
        spinner!.center = centeredView.center
		spinner!.startAnimating()
		
		view.addSubview(spinner!)
        view.bringSubviewToFront(spinner!)
    }
	
	func hideSpinner() {
		spinner?.stopAnimating()
		spinner?.removeFromSuperview()
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
        var cropRect = cropOverlay.croppedRect
        cropRect.origin.x += scrollView.contentOffset.x - imageView.frame.origin.x
        cropRect.origin.y += scrollView.contentOffset.y - imageView.frame.origin.y

		let normalizedX = max(0, cropRect.origin.x / imageView.frame.width)
		let normalizedY = max(0, cropRect.origin.y / imageView.frame.height)

        let extraWidth = min(0, cropRect.origin.x)
        let extraHeight = min(0, cropRect.origin.y)

		let normalizedWidth = min(1, (cropRect.width + extraWidth) / imageView.frame.width)
		let normalizedHeight = min(1, (cropRect.height + extraHeight) / imageView.frame.height)
		
		return CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
	}
	
}

extension ConfirmViewController: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContent()
    }
}

extension ConfirmViewController: CropOverlayDelegate {

    func didMoveCropOverlay(newFrame: CGRect) {
        cropOverlayLeftConstraint.constant = newFrame.origin.x
        cropOverlayTopConstraint.constant = newFrame.origin.y
        cropOverlayWidthConstraint.constant = newFrame.size.width
        cropOverlayHeightConstraint.constant = newFrame.size.height
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
