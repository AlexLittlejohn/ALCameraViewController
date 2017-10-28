//
//  UIImageView+Filter.m
//  Updates
//
//  Created by Nebojsa Petrovic on 4/14/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import "UIImageView+Filter.h"
#import <CoreImage/CoreImage.h>

// Arbitrary tag so that we can identify filtered images.
// Otherwise we risk removing a custom subview that isn't a filter.
#define IMAGE_FILTER_TAG 123454321

@implementation UIImageView (Filter)

- (void)applyFilter:(CIFilter *)filter
  animationDuration:(NSTimeInterval)animationDuration
    animationOptions:(UIViewAnimationOptions)animationOptions
         completion:(void (^)(void))completionBlock {

    [self.image applyFilter:filter completion:^(UIImage *filteredImage) {
        // Remove any previous filters
        [self removeFilter];

        // Add the filtered image on top of the original image.
        UIImageView *filteredImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        filteredImageView.tag = IMAGE_FILTER_TAG;
        filteredImageView.contentMode = self.contentMode;
        [self addSubview:filteredImageView];

        // No animation
        if (animationDuration == 0.0f) {
            filteredImageView.image = filteredImage;
            if (completionBlock) {
                completionBlock();
            }
            return;
        }

        // Animation
        [UIView transitionWithView:self
                          duration:animationDuration
                           options:animationOptions
                        animations:^{
                            filteredImageView.image = filteredImage;
                        } completion:^(BOOL finished) {     
                            if (completionBlock) {
                                completionBlock();
                            }
                        }];
    }];
}

- (void)applyFilterWithPreset:(ImageFilterPreset)preset
            animationDuration:(NSTimeInterval)animationDuration
             animationOptions:(UIViewAnimationOptions)animationOptions
                   completion:(void (^)(void))completionBlock {
    CIFilter *filter = [self.image filterWithPreset:preset];
    [self applyFilter:filter
    animationDuration:animationDuration
     animationOptions:animationOptions
           completion:completionBlock];
}

- (void)applyFilterWithPreset:(ImageFilterPreset)preset
                    intensity:(float)intensity
            animationDuration:(NSTimeInterval)animationDuration
             animationOptions:(UIViewAnimationOptions)animationOptions
                   completion:(void (^)(void))completionBlock {
  CIFilter *filter = [self.image filterWithPreset:preset intensity:intensity];
  [self applyFilter:filter
  animationDuration:animationDuration
   animationOptions:animationOptions
         completion:completionBlock];
}

- (void)applyFilter:(CIFilter *)filter
           animated:(BOOL)animated
         completion:(void (^)(void))completionBlock {
    [self applyFilter:filter
    animationDuration:animated ? 0.3f : 0.0f
     animationOptions:UIViewAnimationOptionTransitionCrossDissolve
           completion:completionBlock];
}

- (void)applyFilterWithPreset:(ImageFilterPreset)preset
                    intensity:(float)intensity
                     animated:(BOOL)animated
                   completion:(void (^)(void))completionBlock {
    CIFilter *filter = [self.image filterWithPreset:preset intensity:intensity];
    [self applyFilter:filter
             animated:animated
           completion:completionBlock];
}

- (void)applyFilter:(CIFilter *)filter
         completion:(void (^)(void))completionBlock {
    [self applyFilter:filter animated:NO completion:completionBlock];
}

- (void)applyFilterWithPreset:(ImageFilterPreset)preset
                    intensity:(float)intensity
                   completion:(void (^)(void))completionBlock {
    CIFilter *filter = [self.image filterWithPreset:preset intensity:intensity];
    [self applyFilter:filter
           completion:completionBlock];
}

- (void)applyFilter:(CIFilter *)filter {
    [self applyFilter:filter completion:nil];
}

- (void)applyFilterWithPreset:(ImageFilterPreset)preset intensity:(float)intensity{
    CIFilter *filter = [self.image filterWithPreset:preset intensity:intensity];
    [self applyFilter:filter];
}

- (void)removeFilter {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIImageView class]] &&
            subview.tag == IMAGE_FILTER_TAG) {
            [subview removeFromSuperview];
        }
    }
}

@end
