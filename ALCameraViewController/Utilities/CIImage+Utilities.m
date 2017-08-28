//
//  CIImage+Utilities.m
//
//  Modified by Denis Martin on 12/07/2015
//  Copyright (c) 2015 iRLMobile. All rights reserved.
//  Based on IPDFCameraViewController: https://github.com/mmackh/IPDFCameraViewController/tree/master/IPDFCameraViewController
//  Copyright (c) 2015 mackh ag. All rights reserved.
//

#import "CIImage+Utilities.h"
#import "IRLRectangleFeatureExtensions.h"

@implementation CIImage (Utilities)


+ (CIImage *)imageGradientImage:(CGFloat)threshold {
  CGSize size  = CGSizeMake(256.0, 1.0);
  CGRect r = CGRectZero;
  r.size = size;
  CGRect copy = r;
  UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
  
  int points = 200;
  [[UIColor whiteColor] setFill];
  [[UIBezierPath bezierPathWithRect:r] fill];
  r.size.width =  r.size.width  * threshold;
  for (int i=0;i<points;i++){
    //CGFloat sigm = (points - i)/(CGFloat)points;
    CGFloat sigm = 1.0/(1.0 + exp(-(10.0 * (points/2-i)/((CGFloat)points))));
    
    UIColor *gray = [UIColor colorWithWhite:sigm alpha:1.0];
    [gray setFill];
    copy.size.width = (r.size.width  * threshold) + (points - i);
    [[UIBezierPath bezierPathWithRect:copy] fill];
    
  }
  [[UIColor blackColor] setFill];
  [[UIBezierPath bezierPathWithRect:r] fill];
  
  UIImage *gs = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return [[CIImage alloc] initWithCGImage:gs.CGImage options:nil];;
}

- (UIImageOrientation) imageFromCurrentDeviceOrientation {
  
  switch ([[UIApplication sharedApplication] statusBarOrientation]) {
    case UIInterfaceOrientationPortrait:            return UIImageOrientationRight;
    case UIInterfaceOrientationLandscapeLeft:       return UIImageOrientationDown;
    case UIInterfaceOrientationLandscapeRight:      return UIImageOrientationUp;
    case UIInterfaceOrientationPortraitUpsideDown:  return UIImageOrientationLeft;
    case UIInterfaceOrientationUnknown:             return UIImageOrientationUp;
  }
  return UIImageOrientationUp;
}

#pragma mark -
#pragma mark Conversion

- (UIImage*)makeUIImageWithContext:(CIContext*)context {
  
  // finally!
  UIImage * returnImage;
  
  CGImageRef processedCGImage = [context createCGImage:self
                                              fromRect:[self extent]];
  
  returnImage = [UIImage imageWithCGImage:processedCGImage];
  CGImageRelease(processedCGImage);
  
  return returnImage;
}

- (UIImage *)orientationCorrecterUIImage {
  UIImageOrientation orientation = [self imageFromCurrentDeviceOrientation];
  
  
  CGFloat w = self.extent.size.width, h = self.extent.size.height;
  
  if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight || orientation == UIImageOrientationLeftMirrored || orientation == UIImageOrientationRightMirrored){
    h = self.extent.size.width;
    w = self.extent.size.height;
  }
  
  UIGraphicsBeginImageContext(CGSizeMake(w, h));
  
  [[UIImage imageWithCIImage:self scale:1.0 orientation:orientation] drawInRect:CGRectMake(0,0, w, h)];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return image;
}

#pragma mark -
#pragma mark CoreImage Filters

- (CIImage *)filteredImageUsingUltraContrastWithGradient:(CIImage *)gradient {
  
  //return [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, image, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.14], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil].outputImage;
  
  CIImage *filtered = [CIFilter filterWithName:@"CIColorMap" keysAndValues:kCIInputImageKey, self, @"inputGradientImage", gradient, nil].outputImage;
  
  return filtered;
}

- (CIImage *)filteredImageUsingEnhanceFilter {
  
  return [CIFilter filterWithName:@"CIColorControls"
                    keysAndValues:
          kCIInputImageKey, self,
          @"inputBrightness",     @(0.0f),
          @"inputContrast",       @(1.14f),
          @"inputSaturation",     @(0.0f),
          nil
          ].outputImage;
}

- (CIImage *)filteredImageUsingContrastFilter {
  
  return [CIFilter filterWithName:@"CIColorControls"
              withInputParameters:@{
                                    @"inputContrast"      :   @(1.1),
                                    kCIInputImageKey    :   self}
          ].outputImage;
}

#pragma mark -
#pragma mark CoreImage Utilites

- (CIImage *)cropBordersWithMargin:(CGFloat)margin {
  
  CGRect original = self.extent;
  CGRect rect = CGRectMake(original.origin.x+margin, original.origin.y+margin, original.size.width-2 * margin, original.size.height-2 * margin);
  
  /*
   
   CIFilter *resizeFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
   [resizeFilter setValue:image forKey:@"inputImage"];
   [resizeFilter setValue:[NSNumber numberWithFloat:1.0f] forKey:@"inputAspectRatio"];
   [resizeFilter setValue:[NSNumber numberWithFloat:rect.size.width/original.size.width] forKey:@"inputScale"];
   
   CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
   CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];
   [cropFilter setValue:resizeFilter.outputImage forKey:@"inputImage"];
   [cropFilter setValue:cropRect forKey:@"inputRectangle"];
   CIImage *croppedImage = cropFilter.outputImage;
   */
  
  return [self imageByCroppingToRect:rect];
}

- (CIImage *)correctPerspectiveWithCGPoints:(NSArray*)points {
  CGPoint min = [points[0] CGPointValue];
  CGPoint max = min;
  for (NSValue *value in points)
  {
    CGPoint point = [value CGPointValue];
    min.x = fminf(point.x, min.x);
    min.y = fminf(point.y, min.y);
    max.x = fmaxf(point.x, max.x);
    max.y = fmaxf(point.y, max.y);
  }
  
  CGPoint center =
  {
    0.5f * (min.x + max.x),
    0.5f * (min.y + max.y),
  };
  
  // TODO: Need to improve sorting algorithm
  
  NSNumber *(^angleFromPoint)(id) = ^(NSValue *value)
  {
    CGPoint point = [value CGPointValue];
    CGFloat theta = atan2f(point.y - center.y, point.x - center.x);
    CGFloat angle = fmodf(M_PI - M_PI_4 + theta, 2 * M_PI);
    return @(angle);
  };
  
  NSArray *sortedPoints = [points sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                           {
                             return [angleFromPoint(a) compare:angleFromPoint(b)];
                           }];
  
  CGPoint topLeft = [sortedPoints[3] CGPointValue];
  CGPoint topRight = [sortedPoints[2] CGPointValue];
  CGPoint bottomRight = [sortedPoints[1] CGPointValue];
  CGPoint bottomLeft = [sortedPoints[0] CGPointValue];
  
  NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
  rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:topLeft];
  rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:topRight];
  rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:bottomLeft];
  rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:bottomRight];
  
  return [self imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}

- (CIImage *)drawHighlightOverlayWithcolor:(UIColor*)color
                        CIRectangleFeature:(id<IRLRectangleFeatureProtocol>)rectangle {
  
  // Create the Overlay
  CIImage *image = self;
  CIColor *ciColor = [[CIColor alloc] initWithColor:color];
  CIImage *overlay = [CIImage imageWithColor:ciColor];
  
  overlay = [overlay imageByCroppingToRect:image.extent];
  
  overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent"
                       withInputParameters:@{
                                             @"inputExtent"       :   [CIVector vectorWithCGRect:image.extent],
                                             @"inputTopLeft"      :   [CIVector vectorWithCGPoint:rectangle.topLeft],
                                             @"inputTopRight"     :   [CIVector vectorWithCGPoint:rectangle.topRight],
                                             @"inputBottomLeft"   :   [CIVector vectorWithCGPoint:rectangle.bottomLeft],
                                             @"inputBottomRight"  :   [CIVector vectorWithCGPoint:rectangle.bottomRight]
                                             }];
  
  return [overlay imageByCompositingOverImage:image];
}

- (CIImage *)drawCenterOverlayWithColor:(UIColor*)color
                                  point:(CGPoint)point {
  
  // Create the Overlay
  CIImage *image = self;
  CIColor *ciColor = [[CIColor alloc] initWithColor:color];
  CIImage *overlay = [CIImage imageWithColor:ciColor];
  overlay = [overlay imageByCroppingToRect:image.extent];
  
  overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent"
                       withInputParameters:@{
                                             @"inputExtent"       :   [CIVector vectorWithCGRect:image.extent],
                                             @"inputTopLeft"      :   [CIVector vectorWithCGPoint:CGPointMake(point.x-5, point.y-5)],
                                             @"inputTopRight"     :   [CIVector vectorWithCGPoint:CGPointMake(point.x+5, point.y-5)],
                                             @"inputBottomLeft"   :   [CIVector vectorWithCGPoint:CGPointMake(point.x-5, point.y+5)],
                                             @"inputBottomRight"  :   [CIVector vectorWithCGPoint:CGPointMake(point.x+5, point.y+5)]
                                             }];
  
  return [overlay imageByCompositingOverImage:image];
}

- (CIImage *)drawFocusOverlayWithColor:(UIColor*)color
                                 point:(CGPoint)point
                             amplitude:(CGFloat)amplitude
{
  
  // Create the Overlay
  CIImage *image = self;
  CIColor *ciColor = [[CIColor alloc] initWithColor:color];
  CIImage *overlay = [CIImage imageWithColor:ciColor];
  overlay = [overlay imageByCroppingToRect:image.extent];
  
  overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent"
                       withInputParameters:@{
                                             @"inputExtent"       :   [CIVector vectorWithCGRect:image.extent],
                                             @"inputTopLeft"      :   [CIVector vectorWithCGPoint:CGPointMake(point.x-amplitude, point.y-amplitude)],
                                             @"inputTopRight"     :   [CIVector vectorWithCGPoint:CGPointMake(point.x+amplitude, point.y-amplitude)],
                                             @"inputBottomLeft"   :   [CIVector vectorWithCGPoint:CGPointMake(point.x-amplitude, point.y+amplitude)],
                                             @"inputBottomRight"  :   [CIVector vectorWithCGPoint:CGPointMake(point.x+amplitude, point.y+amplitude)]
                                             }];
  
  return [overlay imageByCompositingOverImage:image];
}



@end

