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
@property (weak, nonatomic) UIView *backgroundView;
//since backgroundview can be something other than superview, this allows you to calibrate the background scroll to fit nicely with the real background. defualt sets this to the superview origin
@property (assign, nonatomic) CGPoint relativeOrigin;
//we need to make sure we keep track of the offset of the superview (scrollview)
@property (weak, nonatomic) UIScrollView *backgroundScrollView;

//background scrollview to mimic the "live" blur
@property (strong, nonatomic) UIScrollView *dynamicBackgroundScrollView;

//this is defualt to NO, to enable observer, just set to YES
@property (assign, nonatomic) BOOL shouldObserveScroll;

//this property links directly to the function - isViewVisibleOnScreen
//it is an experiment that may or may not cut cycles
@property (assign, nonatomic) BOOL shouldUseExperimentOptimization;

//to make sure that the view does not try to find scrollview
@property (assign, nonatomic) BOOL isStaticOnly;

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

//if you ever need a screen grab for any number of reasons
//this will captures everything and the size of the device's bound
+ (UIImage *)grabScreenFromBackgroundView:(UIView *)backgroundView;

+ (CGPoint)combinePoint:(CGPoint)point1 withPoint:(CGPoint)point2;
+ (CGPoint)reversePoint:(CGPoint)point;
@end




@protocol BTBlurredViewDelegate <NSObject>
@optional
//by assigning an image to this, the image will be re-blurred and will be used as the background
- (UIImage *)customBackgroundForBlurredView:(BTBlurredView *)blurredView;
//this allows you to use different blur on your screenshot
- (UIImage *)blurImageForBlurredView:(BTBlurredView *)blurredView image:(UIImage *)image;
@end