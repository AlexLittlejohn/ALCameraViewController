//
//  UIImage+Filter.m
//  Updates
//
//  Created by Nebojsa Petrovic on 4/16/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import "UIImage+Filter.h"

@interface ValueRange : NSObject

@property(nonatomic) float low;
@property(nonatomic) float high;

- (id)initWithLow:(float)low high:(float)high;
- (NSNumber*)valueWithIntensity:(float)intensity;
+ (id)valueWithLow:(float)low high:(float)high;

@end


@implementation ValueRange

+ (id)valueWithLow:(float)low high:(float)high {
  return [[self alloc] initWithLow:low high:high];
}

- (id)initWithLow:(float)low high:(float)high {
  if ( self = [super init] ) {
    self.low = low;
    self.high = high;
  }
  
  return self;
}

- (NSNumber*)valueWithIntensity:(float)intensity {
  return [NSNumber numberWithFloat:self.low + (self.high-self.low)*intensity];
}
@end


@implementation UIImage (Filter)

- (void)applyFilter:(CIFilter *)filter
         completion:(void (^)(UIImage *filteredImage))completionBlock {
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = filter.outputImage;
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    dispatch_async(dispatch_get_main_queue(), ^{
      completionBlock(newImg);
    });
  });
  
}

- (UIImage *)imageWithFilter:(CIFilter *)filter {
  CIContext *context = [CIContext contextWithOptions:nil];
  CIImage *outputImage = filter.outputImage;
  CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
  UIImage *newImg = [UIImage imageWithCGImage:cgimg];
  CGImageRelease(cgimg);
  return newImg;
}

- (UIImage *)imageWithFilterPreset:(ImageFilterPreset)preset {
  return [self imageWithFilterPreset:preset intensity:0.3];
}

- (UIImage *)imageWithFilterPreset:(ImageFilterPreset)preset intensity:(float)intensity{
  if (preset == ImageFilterPresetOriginal) {
    return self;
  }
  
  return [self imageWithFilter:[self filterWithPreset:preset intensity:intensity]];
}

- (CIFilter *)filterWithPreset:(ImageFilterPreset)preset {
  return [self filterWithPreset:preset intensity:0.3];
}

- (CIFilter *)filterWithPreset:(ImageFilterPreset)preset intensity:(float)intensity {
  CIImage *image = [CIImage imageWithCGImage:self.CGImage];
  CIFilter *filter = nil;
  
  switch (preset) {
    case ImageFilterPresetBlackAndWhite: {
      CIFilter* colorControl = [CIFilter filterWithName:@"CIColorControls"
                                          keysAndValues:kCIInputImageKey, image, nil];
      [self setValueForPreset:preset filter:colorControl intensity:intensity];

      
      CIFilter* sharpMask = [CIFilter filterWithName:@"CIUnsharpMask"
                                       keysAndValues:kCIInputImageKey, colorControl.outputImage, nil];
      [self setValueForPreset:preset filter:sharpMask intensity:intensity];

      filter = [CIFilter filterWithName:@"CIExposureAdjust"
                          keysAndValues:kCIInputImageKey, sharpMask.outputImage, nil];
      [self setValueForPreset:preset filter:filter intensity:intensity];

    }
      break;
    case ImageFilterPresetGrayScale: {
      CIFilter* unsharpMask = [CIFilter filterWithName:@"CIUnsharpMask"
                                         keysAndValues:kCIInputImageKey, image, nil];
      [self setValueForPreset:preset filter:unsharpMask intensity:intensity];
      
      filter = [CIFilter filterWithName:@"CIColorControls"
                          keysAndValues:kCIInputImageKey, unsharpMask.outputImage, nil];
      [self setValueForPreset:preset filter:filter intensity:intensity];


    }
      break;
    case ImageFilterPresetEnhanceColor: {
      CIFilter* colorControl = [CIFilter filterWithName:@"CIColorControls"
                                         keysAndValues:kCIInputImageKey, image, nil];
      [self setValueForPreset:preset filter:colorControl intensity:intensity];

      
      filter = [CIFilter filterWithName:@"CIUnsharpMask"
                          keysAndValues:kCIInputImageKey, colorControl.outputImage, nil];
      [self setValueForPreset:preset filter:filter intensity:intensity];
      
    }
      break;
    case ImageFilterPresetEnhanceExposure: {
      CIFilter* exposure = [CIFilter filterWithName:@"CIExposureAdjust"
                                          keysAndValues:kCIInputImageKey, image, nil];
      [self setValueForPreset:preset filter:exposure intensity:intensity];
      
      CIFilter* gamma = [CIFilter filterWithName:@"CIGammaAdjust"
                                       keysAndValues:kCIInputImageKey, exposure.outputImage, nil];
      [self setValueForPreset:preset filter:gamma intensity:intensity];

      
      
      CIFilter* noiseReduction = [CIFilter filterWithName:@"CINoiseReduction"
                                            keysAndValues:kCIInputImageKey, gamma.outputImage, nil];
      [self setValueForPreset:preset filter:noiseReduction intensity:intensity];

      
      filter = [CIFilter filterWithName:@"CIColorControls"
                          keysAndValues:kCIInputImageKey, noiseReduction.outputImage, nil];
      [self setValueForPreset:preset filter:filter intensity:intensity];

    }
      break;
    default:
      break;
  }
  
  return filter;
}

+(NSDictionary*)presetParameters {
  static NSDictionary *inst = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    inst = @{
             @(ImageFilterPresetEnhanceExposure): @{ @"CIExposureAdjust" : @{
                                                         @"inputEV": [ValueRange valueWithLow:0 high:5]
                                                         },
                                                     @"CIGammaAdjust": @{
                                                         @"inputPower": [ValueRange valueWithLow:1 high:0.7]
                                                         } ,
                                                     @"CINoiseReduction": @{
                                                         @"inputNoiseLevel": [ValueRange valueWithLow:0 high:0.01],
                                                         @"inputSharpness": [ValueRange valueWithLow:0.3 high:1.1]
                                                         },
                                                     @"CIColorControls":  @{
                                                         @"inputSaturation": [ValueRange valueWithLow:1 high:1],
                                                         @"inputBrightness": [ValueRange valueWithLow:0 high:0],
                                                         @"inputContrast": [ValueRange valueWithLow:1 high:1.3]
                                                         }
                                                     },
             @(ImageFilterPresetEnhanceColor): @{ @"CIColorControls" : @{
                                                      @"inputSaturation": [ValueRange valueWithLow:1 high:1.9],
                                                      @"inputBrightness": [ValueRange valueWithLow:0 high:0.1],
                                                      @"inputContrast": [ValueRange valueWithLow:1 high:1.2]
                                                      },
                                                  @"CIUnsharpMask": @{
                                                      @"inputRadius": [ValueRange valueWithLow:0 high:2.5],
                                                      @"inputIntensity": [ValueRange valueWithLow:0 high:0.5]
                                                      }
                                                  },
             @(ImageFilterPresetGrayScale): @{ @"CIColorControls" : @{
                                                   @"inputSaturation": [ValueRange valueWithLow:1 high:0],
                                                   @"inputBrightness": [ValueRange valueWithLow:0 high:0],
                                                   @"inputContrast": [ValueRange valueWithLow:1 high:1]
                                                   },
                                               @"CIUnsharpMask": @{
                                                   @"inputRadius": [ValueRange valueWithLow:0 high:2.5],
                                                   @"inputIntensity": [ValueRange valueWithLow:0 high:0.15]
                                                   }
                                               },
             @(ImageFilterPresetBlackAndWhite): @{ @"CIExposureAdjust" : @{
                                                       @"inputEV": [ValueRange valueWithLow:0 high:2.3]
                                                       },
                                                   @"CIUnsharpMask" : @{
                                                       @"inputRadius": [ValueRange valueWithLow:0 high:75.0],
                                                       @"inputIntensity": [ValueRange valueWithLow:0 high:2.0]
                                                       },
                                                   @"CIColorControls":  @{
                                                       @"inputSaturation": [ValueRange valueWithLow:1 high:0],
                                                       @"inputBrightness": [ValueRange valueWithLow:0 high:0.15],
                                                       @"inputContrast": [ValueRange valueWithLow:1 high:1.3]
                                                       }
                                                   }
             };
  });
  return inst;
}

-(void)setValueForPreset:(ImageFilterPreset)preset filter:(CIFilter*)filter intensity:(float)intensity{
  NSDictionary* presetDict =  [[[self class] presetParameters] objectForKey:@(preset)];
  
  NSDictionary *subDict = presetDict[[filter name]];

  for (NSString* key in [subDict allKeys]) {
    ValueRange *value = subDict[key];
    [filter setValue:[value valueWithIntensity:intensity] forKey:key];
  }
  
}

@end








