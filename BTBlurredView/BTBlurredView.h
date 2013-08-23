//
//  BTBlurredView.h
//  BTBlurredViewExample
//
//  Created by Byte on 8/19/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"

@protocol BTBlurredViewDelegate;

typedef enum {
    AnimationCodeFade
}AnimationCode;

@interface BTBlurredView : UIView

//If the backgroundview is not superview, then set the backgroundview
@property (strong, nonatomic) UIView *backgroundView;
//since backgroundview can be something other than superview, this allows you to fix the relative view
@property (assign, nonatomic) CGRect relativeFrame;

//background scrollview to mimic the "live" blur
@property (strong, nonatomic) UIScrollView *dynamicBackgroundScrollView;

@property (weak, nonatomic) id<BTBlurredViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame backgroundView:(UIView *)backgroundView relativeFrame:(CGRect)relativeFrame;
- (void)refreshBackground;
- (void)refreshBackgroundWithAnimationCode:(AnimationCode)animationCode duration:(CGFloat)duration;
- (void)viewDidMoveToPointOffset:(CGPoint)pointOffset;
@end




@protocol BTBlurredViewDelegate <NSObject>

- (UIImage *)blurImageForBlurredView:(BTBlurredView *)blurredView image:(UIImage *)image;
@end