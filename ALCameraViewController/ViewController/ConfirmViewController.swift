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
  
//  @IBOutlet weak var backButton: UIButton!
//  @IBOutlet weak var doneButton: UIButton!
  lazy var nextBarButtonItem: UIBarButtonItem = {
    var item = UIBarButtonItem(title: localizedString("confirm.done"), style: .plain, target: nil, action: nil)
    item.tintColor = #colorLiteral(red: 0.2392156863, green: 0.8274509804, blue: 0.3960784314, alpha: 1)
    return item
  }()
  
  lazy var backBarButtonItem: UIBarButtonItem = {
    let buttonImage = UIImage(named: "nav_back", in: CameraGlobals.shared.bundle, compatibleWith: nil)
    var item = UIBarButtonItem(image: buttonImage, style: .plain, target: nil, action: nil)
    return item
  }()

  
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
    
    self.title = localizedString("confirm.viewtitle")
    self.navigationItem.leftBarButtonItem = backBarButtonItem
    
    if let image = image {
      configureWithImage(image)
      self.navigationItem.rightBarButtonItem = nextBarButtonItem
    }
  }
  
  private func configureWithImage(_ image: UIImage) {
    setupButtonActions()
    
    imageView.image = image
  }
  
  func setupButtonActions() {
    backBarButtonItem.itemAction = { [weak self] in self?.navigationController?.popViewController(animated: true) }
    nextBarButtonItem.itemAction = { [weak self] in self?.confirmPhoto() }
  }
  
  func confirmPhoto() {
    
    guard let image = imageView.image else {
      return
    }
    
    disable()
    
//    imageView.isHidden = true
    
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
    nextBarButtonItem.isEnabled = false
  }
  
  func enable() {
    nextBarButtonItem.isEnabled = true
  }
  
  func showNoImageScreen(_ error: NSError) {
    let permissionsView = PermissionsView(frame: view.bounds)
    
    let desc = localizedString("error.cant-fetch-photo.description")
    
    permissionsView.configureInView(view, title: error.localizedDescription, description: desc, completion: { [weak self] in self?.cancel() })
  }
}

