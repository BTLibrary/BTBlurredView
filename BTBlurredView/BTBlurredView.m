//
//  BTBlurredView.m
//  BTBlurredViewExample
//
//  Created by Byte on 8/19/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import "BTBlurredView.h"

@implementation BTBlurredView

- (id)initWithFrame:(CGRect)frame backgroundView:(UIView *)backgroundView relativeOrigin:(CGPoint)relativeOrigin
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _backgroundView = backgroundView;
        _relativeOrigin = relativeOrigin;
        _shouldObserveScroll = NO;
        _shouldUseExperimentOptimization = NO;
    }
    return self;
}

//called when the view is going to be shown
- (void)didMoveToWindow
{
    if (!_backgroundView) {
        _backgroundView = self.superview;
    }
    if (CGPointEqualToPoint(CGPointZero, _relativeOrigin)) {
        _relativeOrigin = [self reversePoint:[self combinePoint:self.frame.origin withPoint:self.superview.frame.origin]];
    }

    _dynamicBackgroundScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [_dynamicBackgroundScrollView setContentInset:UIEdgeInsetsMake(_backgroundView.frame.size.height - self.bounds.size.height, _backgroundView.frame.size.width - self.bounds.size.width, 0, 0)];
    [_dynamicBackgroundScrollView setContentOffset:[self reversePoint:_relativeOrigin]];
    [_dynamicBackgroundScrollView setUserInteractionEnabled:NO];
    [_dynamicBackgroundScrollView setShowsHorizontalScrollIndicator:NO];
    [_dynamicBackgroundScrollView setShowsVerticalScrollIndicator:NO];
    [self insertSubview:_dynamicBackgroundScrollView atIndex:0];
    
    [self refreshBackground];
}

#pragma mark Background Image
//simple refresh
- (void)refreshBackground
{
    //grab background
    UIImage *screenShotImage = [self screenShotImage];
    
    [self refreshBackgroundWithSpecificBackgroundImage:screenShotImage];
}

- (void)refreshBackgroundWithSpecificBackgroundImage:(UIImage *)backgroundImage
{
    //blur
    backgroundImage = [self blurImage:backgroundImage];
    
    //set background
    [_dynamicBackgroundScrollView setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];

    return;
}

//complex refresh the background with animation
//due to the limitation of screen grab, this will show delay of the duration, since doing animation in synchronize will lag and/or ugly
- (void)refreshBackgroundWithAnimationCode:(AnimationCode)animationCode duration:(CGFloat)duration
{
    //grab background
    UIImage *screenShotImage = [self screenShotImage];
    
    [self refreshBackgroundWithAnimationCode:animationCode duration:duration withSpecificBackgroundImage:screenShotImage];
}

- (void)refreshBackgroundWithAnimationCode:(AnimationCode)animationCode duration:(CGFloat)duration withSpecificBackgroundImage:(UIImage *)backgroundImage
{
    //blur
    backgroundImage = [self blurImage:backgroundImage];
    
    
    //create temporary scrollview
    UIScrollView *animateBackgroundScrollview = [[UIScrollView alloc] initWithFrame:_dynamicBackgroundScrollView.frame];
    [animateBackgroundScrollview setContentInset:_dynamicBackgroundScrollView.contentInset];
    [animateBackgroundScrollview setContentOffset:_dynamicBackgroundScrollView.contentOffset];
    [animateBackgroundScrollview setUserInteractionEnabled:NO];
    [animateBackgroundScrollview setShowsHorizontalScrollIndicator:NO];
    [animateBackgroundScrollview setShowsVerticalScrollIndicator:NO];
    [animateBackgroundScrollview setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
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

#pragma mark Movement

- (void)viewDidMoveToPointOffset:(CGPoint)pointOffset
{
    if (![self isViewVisibleOnScreenWithOffset:pointOffset]) {
        return;
    }
    
    //invert point and adjust relative frame
    pointOffset = [self reversePoint:[self combinePoint:pointOffset withPoint:_relativeOrigin]];
    [_dynamicBackgroundScrollView setContentOffset:pointOffset];
}

- (void)setShouldObserveScroll:(BOOL)shouldObserveScroll
{
    //as to not have more than 1 observer
    if (shouldObserveScroll == _shouldObserveScroll) {
        return;
    }
    
    _shouldObserveScroll = shouldObserveScroll;
    if (_shouldObserveScroll) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parentScrollViewDidScroll:) name:PARENT_SCROLL_NOTIFICATION object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PARENT_SCROLL_NOTIFICATION object:nil];
    }
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

- (void)parentScrollViewDidScroll:(NSNotification *)notification
{
    UIScrollView *parentScrollView = notification.object;
    [self viewDidMoveToPointOffset:parentScrollView.contentOffset];
}

- (CGPoint)combinePoint:(CGPoint)point1 withPoint:(CGPoint)point2
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

- (CGPoint)reversePoint:(CGPoint)point
{
    return CGPointMake(-point.x, -point.y);
}

//this method is crude and may not work at all times
//it is implemented as an idea to optimize view that are not visible to not scroll
//it has not been tested properly, initial test shows that it works
- (BOOL)isViewVisibleOnScreenWithOffset:(CGPoint)offset
{
    if (!_shouldUseExperimentOptimization) {
        //if not turned on, proceed with scroll/refresh
        return YES;
    }
    
    CGFloat originX = _relativeOrigin.x - offset.x;
    CGFloat originY = _relativeOrigin.y - offset.y;
    
    //check left
    if (originX + self.frame.size.width < 0) {
        return NO;
    }
    //check top
    if (originY + self.frame.size.height < 0) {
        return NO;
    }
    //check right
    if (originX > self.window.frame.size.width) {
        return NO;
    }
    //check bottom
    if (originY > self.window.frame.size.height) {
        return NO;
    }
    
    NSLog(@"%@",@YES);
    return YES;
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
