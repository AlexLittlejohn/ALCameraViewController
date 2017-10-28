//
//  UIImageView+Filter.h
//  Updates
//
//  Created by Nebojsa Petrovic on 4/14/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Filter.h"

@interface UIImageView (Filter)

/*
 Apply 'filter' to the image view's image.
 The filter application can be animated with custom duration
 and options.  
 When the filter has finished being applied, the completionBlock is called.
 */
- (void)applyFilter:(CIFilter *)filter
  animationDuration:(NSTimeInterval)animationDuration
   animationOptions:(UIViewAnimationOptions)animationOptions
         completion:(void (^)(void))completionBlock;
- (void)applyFilterWithPreset:(ImageFilterPreset)preset
                    intensity:(float)intensity
            animationDuration:(NSTimeInterval)animationDuration
             animationOptions:(UIViewAnimationOptions)animationOptions
                   completion:(void (^)(void))completionBlock;

/*
 Apply 'filter' to the image view's image.
 If 'animated' is YES, the filter application is animated
 with a cross-disolve effect for a duration of 0.3 seconds.
 When the filter has finished being applied, the completionBlock is called.
 */
- (void)applyFilter:(CIFilter *)filter
           animated:(BOOL)animated
         completion:(void (^)(void))completionBlock;
- (void)applyFilterWithPreset:(ImageFilterPreset)preset
                    intensity:(float)intensity
                     animated:(BOOL)animated
                   completion:(void (^)(void))completionBlock;

/*
 Apply 'filter' to the image view's image without animation.
 When the filter has finished being applied, the completionBlock is called.
 */
- (void)applyFilter:(CIFilter *)filter
         completion:(void (^)(void))completionBlock;
- (void)applyFilterWithPreset:(ImageFilterPreset)preset
                    intensity:(float)intensity
                   completion:(void (^)(void))completionBlock;

/*
 Apply 'filter' to the image view's image without animation.
 */
- (void)applyFilter:(CIFilter *)filter;
- (void)applyFilterWithPreset:(ImageFilterPreset)preset intensity:(float)intensity;

/*
 Remove any filters applied.  This bring back the original image.
 */
- (void)removeFilter;

@end
