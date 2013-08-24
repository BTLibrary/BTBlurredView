//
//  BTBlurredView.h
//  BTBlurredViewExample
//
//  Created by Byte on 8/19/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"

//instead of calling viewDidMoveToPointOffset, parent can use notification center
#define PARENT_SCROLL_NOTIFICATION @"PARENT_SCROLL_NOTIFICATION"

@protocol BTBlurredViewDelegate;

typedef enum {
    AnimationCodeFade
}AnimationCode;

@interface BTBlurredView : UIView

//if the backgroundview is not superview, then set the backgroundview
@property (strong, nonatomic) UIView *backgroundView;
//since backgroundview can be something other than superview, this allows you to calibrate the background scroll to fit nicely with the real background. defualt sets this to the superview origin
@property (assign, nonatomic) CGPoint relativeOrigin;

//background scrollview to mimic the "live" blur
@property (strong, nonatomic) UIScrollView *dynamicBackgroundScrollView;

//this is defualt to NO, to enable observer, just set to YES
@property (assign, nonatomic) BOOL shouldObserveScroll;

//this property links directly to the function - isViewVisibleOnScreen
//it is an experiment that may or may not cut cycles
@property (assign, nonatomic) BOOL shouldUseExperimentOptimization;

@property (weak, nonatomic) id<BTBlurredViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame backgroundView:(UIView *)backgroundView relativeOrigin:(CGPoint)relativeOrigin;

//different types of refresh background
- (void)refreshBackground;
//this can blur something other than the screen
- (void)refreshBackgroundWithSpecificBackgroundImage:(UIImage *)backgroundImage;
//refresh baclground with different look, this is under experiment
- (void)refreshBackgroundWithAnimationCode:(AnimationCode)animationCode duration:(CGFloat)duration;
//same as above only with roll your own image
- (void)refreshBackgroundWithAnimationCode:(AnimationCode)animationCode duration:(CGFloat)duration withSpecificBackgroundImage:(UIImage *)backgroundImage;

//re calculate the relativeOrigin
- (void)resetRelativeOrigin;

//set the blur to act "live" follow motion
- (void)viewDidMoveToPointOffset:(CGPoint)pointOffset;
@end




@protocol BTBlurredViewDelegate <NSObject>
@optional
- (UIImage *)blurImageForBlurredView:(BTBlurredView *)blurredView image:(UIImage *)image;
@end