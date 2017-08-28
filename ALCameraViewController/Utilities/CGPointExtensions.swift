//
//  CGPointExtensions.swift
//  ALCameraViewController
//
//  Created by Zhu Wu on 8/25/17.
//  Copyright © 2017 zero. All rights reserved.
//

import Foundation

extension CGPoint {
  internal func translate(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
    return CGPoint(x: self.x+dx, y: self.y+dy)
  }
  
  internal func transform(_ t: CGAffineTransform) -> CGPoint {
    return self.applying(t)
  }
  
  internal func transform(_ t: CATransform3D) -> CGPoint {
    return self.applying(CATransform3DGetAffineTransform(t))
  }
  
  internal func distance(_ b: CGPoint) -> CGFloat {
    return sqrt(pow(self.x - b.x, 2) + pow(self.y - b.y, 2))
  }
  
  internal func cgPointIn(_ ciSize: CGSize) -> CGPoint {
    var t = CGAffineTransform(scaleX: 1, y: -1)
    t = t.translatedBy(x: 0, y: -ciSize.height)
    
    return self.applying(t)
  }
  
  internal func ciPointIn(_ cgSize: CGSize) -> CGPoint {
    var t = CGAffineTransform(scaleX: 1, y: -1)
    t = t.translatedBy(x: 0, y: -cgSize.height)
    
    return self.applying(t)
  }
  
}
