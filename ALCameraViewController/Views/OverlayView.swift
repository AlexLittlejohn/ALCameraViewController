//
//  OverlayView.swift
//  Instashot
//
//  Created by Zhu Wu on 8/19/17.
//  Copyright © 2017 Skrapit Ltd. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

class OverlayView: UIView {
  lazy var topLeftButton: UIView = {
    let btn = UIView()
    btn.backgroundColor = UIColor.blue
    btn.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 10, height: 10))
    return btn
  }()
  
  
  lazy var topRightButton: UIView = {
    let btn = UIView()
    btn.backgroundColor = UIColor.blue
    btn.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 10, height: 10))
    return btn
  }()
  
  lazy var bottomLeftButton: UIView = {
    let btn = UIView()
    btn.backgroundColor = UIColor.blue
    btn.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 10, height: 10))
    return btn
  }()
  
  lazy var bottomRightButton: UIView = {
    let btn = UIView()
    btn.backgroundColor = UIColor.blue
    btn.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 10, height: 10))
    btn.isUserInteractionEnabled = true
    return btn
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupButtons()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupButtons()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  
  func setupButtons()  {
    _ = [topLeftButton,topRightButton,bottomLeftButton,bottomRightButton].map({
      $0.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin,.flexibleLeftMargin,.flexibleRightMargin]
      addSubview($0)
    })
    
    self.addGestureRecognizer(UIPanViewGestureRecognizer(target: self, action: #selector(parentPan)))
    
    self.layoutButtons()
  }
  
  func detectBorders(_ underneathImage: UIImageView) -> Bool {
    let imageView = underneathImage
    let ciContext =  CIContext()
    let ciImage = CIImage(image: imageView.image!)!
    
    let detector = CIDetector(ofType: CIDetectorTypeRectangle,
                              context: ciContext,
                              options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
    
    let features = detector.features(in: ciImage)
    
    // MARK: CIDetectorTypeRectangle only detects one rectangle
    if let rect = features.first as? CIRectangleFeature {
      self.layoutButtons(rect, imageView.image!.size)
      return true
    }
    
    return false
  }
  
  func layoutButtons() {
    let margin:CGFloat = 10.0
    topLeftButton.center = self.bounds.topLeft.translate(margin, dy: margin)
    topRightButton.center = self.bounds.topRight.translate(-margin, dy: margin)
    bottomLeftButton.center = self.bounds.bottomLeft.translate(margin, dy: -margin)
    bottomRightButton.center = self.bounds.bottomRight.translate(-margin, dy: -margin)
    setNeedsDisplay()
  }
  
  func layoutButtons(_ rectFeature: CIRectangleFeature, _ imageSize: CGSize) {
    let scaleTransform = CGAffineTransform(scaleX: self.bounds.size.width/imageSize.width, y: self.bounds.size.height/imageSize.height)
    
    topLeftButton.center = rectFeature.topLeft.ciPointIn(imageSize).applying(scaleTransform)
    topRightButton.center = rectFeature.topRight.ciPointIn(imageSize).applying(scaleTransform)
    bottomLeftButton.center = rectFeature.bottomLeft.ciPointIn(imageSize).applying(scaleTransform)
    bottomRightButton.center = rectFeature.bottomRight.ciPointIn(imageSize).applying(scaleTransform)
    setNeedsDisplay()
  }
  
  func cropImage(_ imageView:UIImageView) -> UIImage {
    let ciImage = CIImage(image: imageView.image!)!
    
    var t = CGAffineTransform(scaleX: 1, y: -1)
    t = t.translatedBy(x: 0, y: -imageView.frame.size.height)
    let scaleTransform = CGAffineTransform(scaleX: imageView.image!.size.width/imageView.frame.size.width, y: imageView.image!.size.height/imageView.frame.size.height)
    
    let topLeft = self.topLeftButton.frame.center.applying(t).applying(scaleTransform)
    let topRight = self.topRightButton.frame.center.applying(t).applying(scaleTransform)
    let bottomLeft = self.bottomLeftButton.frame.center.applying(t).applying(scaleTransform)
    let bottomRight = self.bottomRightButton.frame.center.applying(t).applying(scaleTransform)
    
    
    let points = [NSValue(cgPoint: topLeft),
                  NSValue(cgPoint: topRight),
                  NSValue(cgPoint: bottomLeft),
                  NSValue(cgPoint: bottomRight)]
    
    let image = ciImage.correctPerspective(withCGPoints: points)!.makeUIImage(with: CIContext())
    
    return image!
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    // connect buttons via straight lines
    
    let lineWidth:CGFloat = 3.0
    
    let path = UIBezierPath()
    path.lineWidth = lineWidth
    
    path.move(to: topLeftButton.center)
    path.addLine(to: topRightButton.center)
    path.addLine(to: bottomRightButton.center)
    path.addLine(to: bottomLeftButton.center)
    
    
    //set the stroke color
    #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 0.3).setFill()
    
    //draw the stroke
    path.fill()
    
  }
  
  func parentPan(_ sender: UIPanViewGestureRecognizer) {
    switch sender.state {
    case .began:
      sender.attachedView = self.anchor(_contains: sender.location(in: self))
      break
    case .changed:
      guard let view = sender.attachedView else { return }
      var location = sender.location(in: self)
      location.x = max(self.bounds.minX, location.x)
      location.x = min(self.bounds.maxX, location.x)
      location.y = max(self.bounds.minY, location.y)
      location.y = min(self.bounds.maxY, location.y)
      view.center = location
      self.setNeedsDisplay()
      break
    default:
      sender.attachedView = nil
      break
      
    }
  }
  
  func anchor(_contains point:CGPoint) -> UIView? {
    return [topLeftButton,topRightButton,bottomLeftButton,bottomRightButton].first(where: { (view) -> Bool in
      let frame = view.frame.insetBy(dx: -30, dy: -30)
      return frame.contains(point)
    })
  }
  
}

class UIPanViewGestureRecognizer: UIPanGestureRecognizer {
  var attachedView:UIView?
}

















