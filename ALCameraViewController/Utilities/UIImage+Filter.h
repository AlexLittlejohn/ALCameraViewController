//
//  UIImage+Filter.h
//  Updates
//
//  Created by Nebojsa Petrovic on 4/16/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ImageFilterPresetOriginal = 0,
    ImageFilterPresetBlackAndWhite,
    ImageFilterPresetEnhanceColor,
    ImageFilterPresetEnhanceExposure,
    ImageFilterPresetGrayScale
} ImageFilterPreset;

@interface UIImage (Filter)

/*
 Asynchronously applies 'filter' to the target image and
 returns the filtered image in the block.
 The target image remains unchanged.
 */
- (void)applyFilter:(CIFilter *)filter
         completion:(void (^)(UIImage *filteredImage))completionBlock;

/*
 Returns a UIImage from the filter.
 */
- (UIImage *)imageWithFilter:(CIFilter *)filter;

/*
 Returns a UIImage from a filter preset
 */
- (UIImage *)imageWithFilterPreset:(ImageFilterPreset)preset intensity:(float)intensity;

/*
 Returns a filter using a common preset, and intensity value, ranging from 0 to 1
 */
- (CIFilter *)filterWithPreset:(ImageFilterPreset)preset;
- (CIFilter *)filterWithPreset:(ImageFilterPreset)preset intensity:(float)intensity;

@end
