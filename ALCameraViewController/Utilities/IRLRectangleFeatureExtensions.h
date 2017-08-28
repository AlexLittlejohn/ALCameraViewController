//
//  IRLRectangleFeatureExtensions.h
//  ALCameraViewController
//
//  Created by Zhu Wu on 8/28/17.
//  Copyright © 2017 zero. All rights reserved.
//

@import UIKit;
@import CoreImage;

@protocol IRLRectangleFeatureProtocol <NSObject>
@property (readonly) CGPoint topLeft;
@property (readonly) CGPoint topRight;
@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@end

@interface CIRectangleFeature()<IRLRectangleFeatureProtocol>
@end


@interface IRLRectangleFeature : CIFeature <IRLRectangleFeatureProtocol>
@property (readwrite) CGPoint topLeft;
@property (readwrite) CGPoint topRight;
@property (readwrite) CGPoint bottomLeft;
@property (readwrite) CGPoint bottomRight;
@end

@interface IRLRectangleFeature (IRLRectangleFeatureExtensions)

@end
