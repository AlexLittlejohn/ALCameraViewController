//
//  CIImage+Utilities.h
//
//  Modified by Denis Martin on 12/07/2015
//  Copyright (c) 2015 iRLMobile. All rights reserved.
//  Based on IPDFCameraViewController: https://github.com/mmackh/IPDFCameraViewController/tree/master/IPDFCameraViewController
//  Copyright (c) 2015 mackh ag. All rights reserved.
//

@import UIKit;
@import CoreImage;

@class IRLRectangleFeature;

@protocol IRLRectangleFeatureProtocol <NSObject>
@property (readonly) CGPoint topLeft;
@property (readonly) CGPoint topRight;
@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@end

@interface CIRectangleFeature()<IRLRectangleFeatureProtocol>
@end

@interface CIImage (Utilities)

+ (CIImage *)imageGradientImage:(CGFloat)threshold;

- (UIImage*)makeUIImageWithContext:(CIContext*)context;
- (UIImage *)orientationCorrecterUIImage;

// Filters
- (CIImage *)filteredImageUsingUltraContrastWithGradient:(CIImage *)gradient ;
- (CIImage *)filteredImageUsingEnhanceFilter ;
- (CIImage *)filteredImageUsingContrastFilter ;

- (CIImage *)cropBordersWithMargin:(CGFloat)margin;
- (CIImage *)correctPerspectiveWithCGPoints:(NSArray*)points;
- (CIImage *)drawHighlightOverlayWithcolor:(UIColor*)color CIRectangleFeature:(id<IRLRectangleFeatureProtocol>)rectangle;
- (CIImage *)drawCenterOverlayWithColor:(UIColor*)color point:(CGPoint)point;
- (CIImage *)drawFocusOverlayWithColor:(UIColor*)color point:(CGPoint)point amplitude:(CGFloat)amplitude;

@end

@interface IRLRectangleFeature : CIFeature <IRLRectangleFeatureProtocol>
@property (readwrite) CGPoint topLeft;
@property (readwrite) CGPoint topRight;
@property (readwrite) CGPoint bottomLeft;
@property (readwrite) CGPoint bottomRight;
@end
