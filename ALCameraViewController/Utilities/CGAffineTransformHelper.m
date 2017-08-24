//
//  CGAffineTransform+CGAffineTransformHelper.m
//  ALCameraViewController
//
//  Created by Zhu Wu on 8/24/17.
//  Copyright © 2017 zero. All rights reserved.
//

#import "CGAffineTransformHelper.h"


NSString *affineTransformDescription(CGAffineTransform transform)
{
  // check if it's simply the identity matrix
  if (CGAffineTransformIsIdentity(transform)) {
    return @"Is the identity transform";
  }
  // the above does't catch things like a 720° rotation so also check it manually
  if (fabs(transform.a  - 1.0) < FLT_EPSILON &&
      fabs(transform.b  - 0.0) < FLT_EPSILON &&
      fabs(transform.c  - 0.0) < FLT_EPSILON &&
      fabs(transform.d  - 1.0) < FLT_EPSILON &&
      fabs(transform.tx - 0.0) < FLT_EPSILON &&
      fabs(transform.ty - 0.0) < FLT_EPSILON) {
    return @"Is the identity transform";
  }
  
  // The affine transforms is built up like this:
  
  // a b tx
  // c d ty
  // 0 0 1
  
  // An array to hold all the different descirptions, charasteristics of the transform.
  NSMutableArray *descriptions = [NSMutableArray array];
  
  // Checking for a translation
  if (fabs(transform.tx) > FLT_EPSILON) { // translation along X
    [descriptions addObject:[NSString stringWithFormat:@"Will move %.2f along the X axis",
                             transform.tx]];
  }
  if (fabs(transform.ty) > FLT_EPSILON) { // translation along Y
    [descriptions addObject:[NSString stringWithFormat:@"Will move %.2f along the Y axis",
                             transform.ty]];
  }
  
  
  // Checking for a rotation
  CGFloat angle = atan2(transform.b, transform.a); // get the angle of the rotation. Note this assumes no shearing!
  if (fabs(angle) < FLT_EPSILON || fabs(angle - M_PI) < FLT_EPSILON) {
    // there is a change that there is a 180° rotation, in that case, A and D will and be negative.
    BOOL bothAreNegative  = transform.a < 0.0 && transform.d < 0.0;
    
    if (bothAreNegative) {
      angle = M_PI;
    } else {
      angle = 0.0; // this is not considered a rotation, but a negative scale along one axis.
    }
  }
  
  // add the rotation description if there was an angle
  if (fabs(angle) > FLT_EPSILON) {
    [descriptions addObject:[NSString stringWithFormat:@"Will rotate %.1f° degrees",
                             angle*180.0/M_PI]];
  }
  
  
  // Checking for a scale (and account for the possible rotation as well)
  CGFloat scaleX = transform.a/cos(angle);
  CGFloat scaleY = transform.d/cos(angle);
  
  
  if (fabs(scaleX - scaleY) < FLT_EPSILON && fabs(scaleX - 1.0) > FLT_EPSILON) {
    // if both are the same then we can format things a little bit nicer
    [descriptions addObject:[NSString stringWithFormat:@"Will scale by %.2f along both X and Y",
                             scaleX]];
  } else {
    // otherwise we look at X and Y scale separately
    if (fabs(scaleX - 1.0) > FLT_EPSILON) { // scale along X
      [descriptions addObject:[NSString stringWithFormat:@"Will scale by %.2f along the X axis",
                               scaleX]];
    }
    
    if (fabs(scaleY - 1.0) > FLT_EPSILON) { // scale along Y
      [descriptions addObject:[NSString stringWithFormat:@"Will scale by %.2f along the Y axis",
                               scaleY]];
    }
  }
  
  // Return something else when there is nothing to say about the transform matrix
  if (descriptions.count == 0) {
    return @"Can't easilly be described.";
  }
  
  // join all the descriptions on their own line
  return [descriptions componentsJoinedByString:@",\n"];
}
