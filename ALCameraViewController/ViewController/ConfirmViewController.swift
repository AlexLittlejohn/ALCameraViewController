//
//  ConfirmViewController.swift
//  ALCameraViewController
//
//  Created by Zhu Wu on 8/25/17.
//  Copyright © 2017 zero. All rights reserved.
//

import Foundation
import Photos

public class ConfirmViewController: UIViewController {
  let image: UIImage?
  let asset: PHAsset?
  
  @IBOutlet weak var imageView: UIImageView!
  
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var doneButton: UIButton!
  
  public var onComplete: CameraViewCompletion?
  

  public override var prefersStatusBarHidden: Bool {
    return true
  }
  
  public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return UIStatusBarAnimation.slide
  }
  
  open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  public init(_ image: UIImage?, _ asset: PHAsset?) {
    self.image = image
    self.asset = asset
    super.init(nibName: "ConfirmViewController", bundle: CameraGlobals.shared.bundle)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    image = nil
    asset = nil
    super.init(coder: aDecoder)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    if let image = image {
      configureWithImage(image)
    }
  }
  
  private func configureWithImage(_ image: UIImage) {
    setupButtonActions()
    
    imageView.image = image
  }
  
  func setupButtonActions() {
    backButton.action = { [weak self] in self?.navigationController?.popViewController(animated: false) }
    doneButton.action = { [weak self] in self?.confirmPhoto() }
  }
  
  func confirmPhoto() {
    
    guard let image = imageView.image else {
      return
    }
    
    disable()
    
    imageView.isHidden = true
    
    let spinner = showSpinner()
    
//    if let asset = asset {
//      var fetcher = SingleImageFetcher()
//        .onSuccess { [weak self] image in
//          self?.onComplete?(image, self?.asset)
//          self?.hideSpinner(spinner)
//          self?.enable()
//        }
//        .onFailure { [weak self] error in
//          self?.hideSpinner(spinner)
//          self?.showNoImageScreen(error)
//        }
//        .setAsset(asset)
//      if allowsCropping {
//        let rect = normalizedRect(makeProportionalCropRect(), orientation: image.imageOrientation)
//        fetcher = fetcher.setCropRect(rect)
//      }
//      
//      fetcher = fetcher.fetch()
//    } else {
      let newImage = image
    
      onComplete?(newImage, asset)
      hideSpinner(spinner)
      enable()
//    }
  }
  
  internal func cancel() {
    onComplete?(nil, nil)
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
    doneButton.isEnabled = false
  }
  
  func enable() {
    doneButton.isEnabled = true
  }
  
  func showNoImageScreen(_ error: NSError) {
    let permissionsView = PermissionsView(frame: view.bounds)
    
    let desc = localizedString("error.cant-fetch-photo.description")
    
    permissionsView.configureInView(view, title: error.localizedDescription, description: desc, completion: { [weak self] in self?.cancel() })
  }
}

