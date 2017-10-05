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
    let btn = UIImageView(image: UIImage(named: "anchorButton",
                                         in: CameraGlobals.shared.bundle,
                                         compatibleWith: nil))
    btn.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 28, height: 28))
    return btn
  }()
  
  
  lazy var topRightButton: UIView = {
    let btn = UIImageView(image: UIImage(named: "anchorButton",
                                         in: CameraGlobals.shared.bundle,
                                         compatibleWith: nil))
    btn.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 28, height: 28))
    return btn
  }()
  
  lazy var bottomLeftButton: UIView = {
    let btn = UIImageView(image: UIImage(named: "anchorButton",
                                         in: CameraGlobals.shared.bundle,
                                         compatibleWith: nil))
    btn.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 28, height: 28))
    return btn
  }()
  
  lazy var bottomRightButton: UIView = {
    let btn = UIImageView(image: UIImage(named: "anchorButton",
                                         in: CameraGlobals.shared.bundle,
                                         compatibleWith: nil))
    btn.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 28, height: 28))
    return btn
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupButtons()
    
    self.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.2039215686, blue: 0.2392156863, alpha: 0.5)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupButtons()
    
    self.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.2039215686, blue: 0.2392156863, alpha: 0.5)
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
  
  func layoutButtons(_ edgeInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
    topLeftButton.center = self.bounds.topLeft.translate(edgeInset.left, dy: edgeInset.top)
    topRightButton.center = self.bounds.topRight.translate(-edgeInset.right, dy: edgeInset.top)
    bottomLeftButton.center = self.bounds.bottomLeft.translate(edgeInset.left, dy: -edgeInset.bottom)
    bottomRightButton.center = self.bounds.bottomRight.translate(-edgeInset.right, dy: -edgeInset.bottom)
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
    self.backgroundColor?.setFill()
    UIRectFillUsingBlendMode(rect, .hardLight)
    
    // connect buttons via straight lines
    let path = UIBezierPath()
    path.move(to: topLeftButton.center)
    path.addLine(to: topRightButton.center)
    path.addLine(to: bottomRightButton.center)
    path.addLine(to: bottomLeftButton.center)
    path.close()
    
    
    let context = UIGraphicsGetCurrentContext()!
    
    context.saveGState()
    context.setBlendMode(.destinationOut)
    
    //set fill color
    UIColor.white.setFill()
    //draw the fill and stroke
    path.fill()
    
    context.restoreGState()
    
    let lineWidth:CGFloat = 1.5
    path.lineWidth = lineWidth
    UIColor.white.setStroke()
    path.stroke()
    
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

















