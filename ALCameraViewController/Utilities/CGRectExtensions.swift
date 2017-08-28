//
//  CGRectExtensions.swift
//  ALCameraViewController
//
//  Created by Zhu Wu on 8/25/17.
//  Copyright © 2017 zero. All rights reserved.
//

import Foundation

extension CGRect {
  internal var topLeft: CGPoint {
    return self.origin
  }
  internal var topRight: CGPoint {
    return self.origin.translate(self.size.width, dy: 0)
  }
  internal var bottomLeft: CGPoint {
    return self.origin.translate(0, dy: self.size.height)
  }
  internal var bottomRight: CGPoint {
    return self.origin.translate(self.size.width, dy: self.size.height)
  }
  internal var center: CGPoint {
    return CGPoint(x: origin.x + size.width/2, y: origin.y + size.height/2)
  }
  internal var bounds: CGRect {
    return CGRect(origin: CGPoint.zero, size: size)
  }
  init(center: CGPoint, size: CGSize) {
    self.init(x: center.x - size.width/2, y: center.y - size.height/2, width: size.width, height: size.height)
  }
}

