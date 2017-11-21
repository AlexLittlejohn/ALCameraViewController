//
//  FilterViewController.swift
//  ALCameraViewController
//
//  Created by Narek Simonyan on 10/28/17.
//  Copyright © 2017 zero. All rights reserved.
//

import UIKit
import Photos
import Crashlytics

class FilterViewController: UIViewController {
  
  @IBOutlet var filterView: UIView!
  
//  @IBOutlet var doneButton: UIButton!
  lazy var nextBarButtonItem: UIBarButtonItem = {
    var item = UIBarButtonItem(title: localizedString("crop.next"), style: .plain, target: nil, action: nil)
    return item
  }()
  
  lazy var backBarButtonItem: UIBarButtonItem = {
    let buttonImage = UIImage(named: "nav_back", in: CameraGlobals.shared.bundle, compatibleWith: nil)
    var item = UIBarButtonItem(image: buttonImage, style: .plain, target: nil, action: nil)
    return item
  }()


//  @IBOutlet var backButton: UIButton!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var grayFilter: UIButton!
  @IBOutlet var colorFilter: UIButton!
  @IBOutlet var exposureFilter: UIButton!
  @IBOutlet var bwFilter: UIButton!
  @IBOutlet var filterIntensitySlider: UISlider!
  
  let image: UIImage?
  let asset: PHAsset?
  
  var filterType:ImageFilterPreset = ImageFilterPresetOriginal {
    didSet {
      apply()
    }
  }
  var filterIntensity: Float = 0.3 {
    didSet {
      apply()
    }
  }
  
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
    super.init(nibName: "FilterViewController", bundle: CameraGlobals.shared.bundle)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    image = nil
    asset = nil
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.image = image
    self.title = localizedString("filter.viewtitle")
    self.navigationItem.rightBarButtonItem = nextBarButtonItem
    self.navigationItem.leftBarButtonItem = self.backBarButtonItem
    setupButtonActions()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  internal func setupButtonActions() {
    nextBarButtonItem.itemAction = { [weak self] in self?.confirmPhoto() }
    backBarButtonItem.itemAction = { [weak self] in self?.navigationController?.popViewController(animated: true)}

    grayFilter.action = { [weak self] in
      guard let strongSelf = self else {return}
      strongSelf.applyFilter(sender: strongSelf.grayFilter)
    }
    colorFilter.action = { [weak self] in
      guard let strongSelf = self else {return}
      strongSelf.applyFilter(sender: strongSelf.colorFilter)}
    exposureFilter.action = { [weak self] in
      guard let strongSelf = self else {return}
      strongSelf.applyFilter(sender: strongSelf.exposureFilter)
    }
    bwFilter.action = { [weak self] in
      guard let strongSelf = self else {return}
      strongSelf.applyFilter(sender: strongSelf.bwFilter)
    }
  }
  
  internal func confirmPhoto() {
    guard let image = imageView.image?.withFilterPreset(filterType, intensity: filterIntensity) else {
      return
    }
    let confirmController = ConfirmViewController(image, asset)
    
    confirmController.onComplete = { [weak self] image, asset in
      guard let image = image else {
        return
      }
      
      self?.onComplete?(image, asset)
      self?.onComplete = nil
    }
    
    self.navigationController?.pushViewController(confirmController, animated: true)
  }
  
  internal func applyFilter (sender: UIButton) {
    let dictionary = [grayFilter:ImageFilterPresetGrayScale,
                      bwFilter:ImageFilterPresetBlackAndWhite,
                      exposureFilter:ImageFilterPresetEnhanceExposure,
                      colorFilter:ImageFilterPresetEnhanceColor]
    
    guard let filter = dictionary[sender] else {
      return
    }
    
    _ = [grayFilter,colorFilter,exposureFilter,bwFilter].map({$0?.isSelected = false})
    sender.isSelected = true
    filterIntensitySlider.isEnabled = true
    filterType = filter
  }
  
  internal func apply() {
    Answers.logCustomEvent(withName: "ALCamera.Filter.ApplyFilter", customAttributes: ["Filter":filterType.rawValue,"Intensity":filterIntensitySlider.value])

    imageView.applyFilter(with: filterType, intensity: filterIntensity)
  }
  
  @IBAction func filterIntensityChanged(_ sender: UISlider) {
    filterIntensity = sender.value
  }
}
