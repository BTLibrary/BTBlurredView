//
//  BTBlurredView.m
//  BTBlurredViewExample
//
//  Created by Byte on 8/19/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import "BTBlurredView.h"

@implementation BTBlurredView

- (id)initWithFrame:(CGRect)frame backgroundView:(UIView *)backgroundView relativeFrame:(CGRect)relativeFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _backgroundView = backgroundView;
        _relativeFrame = relativeFrame;
    }
    return self;
}

//called when the view is going to be shown
- (void)didMoveToWindow
{
    if (!_backgroundView) {
        _backgroundView = self.superview;
    }
    if (CGRectEqualToRect(_relativeFrame, CGRectZero)) {
        _relativeFrame = self.frame;
    }

    _dynamicBackgroundScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [_dynamicBackgroundScrollView setContentInset:UIEdgeInsetsMake(_backgroundView.frame.size.height - self.bounds.size.height, _backgroundView.frame.size.width - self.bounds.size.width, 0, 0)];
    [_dynamicBackgroundScrollView setContentOffset:self.frame.origin];
    [_dynamicBackgroundScrollView setUserInteractionEnabled:NO];
    [_dynamicBackgroundScrollView setShowsHorizontalScrollIndicator:NO];
    [_dynamicBackgroundScrollView setShowsVerticalScrollIndicator:NO];
    [self insertSubview:_dynamicBackgroundScrollView atIndex:0];
    
    

    [self refreshBackground];
}

//complex refresh the background with animation
//due to the limitation of screen grab, this will show delay of the duration, since doing animation in synchronize will lag and/or ugly
- (void)refreshBackgroundWithAnimationCode:(AnimationCode)animationCode duration:(CGFloat)duration
{
    //grab background
    UIImage *screenShotImage = [self screenShotImage];
    
    //blur
    screenShotImage = [self blurImage:screenShotImage];
    
    //create temporary scrollview
    UIScrollView *animateBackgroundScrollview = [[UIScrollView alloc] initWithFrame:_dynamicBackgroundScrollView.frame];
    [animateBackgroundScrollview setContentInset:_dynamicBackgroundScrollView.contentInset];
    [animateBackgroundScrollview setContentOffset:_dynamicBackgroundScrollView.contentOffset];
    [animateBackgroundScrollview setUserInteractionEnabled:NO];
    [animateBackgroundScrollview setShowsHorizontalScrollIndicator:NO];
    [animateBackgroundScrollview setShowsVerticalScrollIndicator:NO];
    [animateBackgroundScrollview setBackgroundColor:[UIColor colorWithPatternImage:screenShotImage]];
    [self insertSubview:animateBackgroundScrollview belowSubview:_dynamicBackgroundScrollView];
    
    //can add other animation but after tinkering with it, adding more is just not going to look good
    switch (animationCode) {
        case AnimationCodeFade:{
            [UIView animateWithDuration:duration animations:^{
                _dynamicBackgroundScrollView.alpha = 0;
            } completion:^(BOOL finished) {
                _dynamicBackgroundScrollView = animateBackgroundScrollview;
            }];
        }
            break;
        default:
            break;
    }
}


//simple refresh
- (void)refreshBackground
{
    //grab background
    UIImage *screenShotImage = [self screenShotImage];
    
    //blur
    screenShotImage = [self blurImage:screenShotImage];
    
    //set background
    [_dynamicBackgroundScrollView setBackgroundColor:[UIColor colorWithPatternImage:screenShotImage]];
}



- (void)viewDidMoveToPointOffset:(CGPoint)pointOffset
{
    //invert point
    pointOffset = CGPointMake(-pointOffset.x, -pointOffset.y);
    [_dynamicBackgroundScrollView setContentOffset:pointOffset];
}


#pragma mark - Internal functions
- (UIImage *)blurImage:(UIImage *)image
{
    //blur
    if (_delegate && [_delegate respondsToSelector:@selector(blurImageForBlurredView:image:)]) {
        image = [_delegate blurImageForBlurredView:self image:image];
    }else{
        // play with the blur here or delegate, your choice
        image = [image applyDarkEffect];
    }
    return image;
}

- (UIImage *)screenShotImage
{
    //remove itself, if it is in the way
    [self setAlpha:0];
    
    UIGraphicsBeginImageContextWithOptions(_backgroundView.bounds.size, YES, 0.0f);
    [_backgroundView drawViewHierarchyInRect:_backgroundView.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //put itself back
    [self setAlpha:1];
    
    return image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
