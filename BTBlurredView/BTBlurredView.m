//
//  BTBlurredView.m
//  BTBlurredViewExample
//
//  Created by Byte on 8/19/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import "BTBlurredView.h"

@implementation BTBlurredView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundView = nil;
        _relativeOrigin = CGPointZero;
        _backgroundScrollView = nil;
        _shouldObserveScroll = NO;
        _shouldUseExperimentOptimization = NO;
        _isStaticOnly = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame backgroundView:(UIView *)backgroundView relativeOrigin:(CGPoint)relativeOrigin
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _backgroundView = backgroundView;
        _relativeOrigin = relativeOrigin;
        
    }
    return self;
}

//called when the view is going to be shown
- (void)didMoveToWindow
{
    if (!_backgroundView) {
        //this is often wrong, and should be changed
        //only way this is right is when the view is static and wont be moving
        _backgroundView = self.superview;
    }
    if (CGPointEqualToPoint(CGPointZero, _relativeOrigin)) {
        [self resetRelativeOrigin];
    }
    if (!_backgroundScrollView && !_isStaticOnly) {
        //if it is not static and has not been assigned, search through superview until finds scrollview or set to nil
        UIView *parentView = self;
        while ((parentView = parentView.superview)) {
            if ([parentView isKindOfClass:[UIScrollView class]]) {
                _backgroundScrollView = (UIScrollView *)parentView;
                break;
            }
        }
        //otherwise leave it nil
    }

    if (!_dynamicBackgroundScrollView) {
        _dynamicBackgroundScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_dynamicBackgroundScrollView setContentInset:UIEdgeInsetsMake(_backgroundView.frame.size.height - self.bounds.size.height, _backgroundView.frame.size.width - self.bounds.size.width, 0, 0)];
        [_dynamicBackgroundScrollView setUserInteractionEnabled:NO];
        [_dynamicBackgroundScrollView setShowsHorizontalScrollIndicator:NO];
        [_dynamicBackgroundScrollView setShowsVerticalScrollIndicator:NO];
        [self insertSubview:_dynamicBackgroundScrollView atIndex:0];
    }
    
    CGPoint pointOffset = _relativeOrigin;
    if (_backgroundScrollView) {
        pointOffset = [BTBlurredView combinePoint:[BTBlurredView reversePoint:_backgroundScrollView.contentOffset] withPoint:_relativeOrigin];
    }
    [_dynamicBackgroundScrollView setContentOffset:pointOffset];
    
    //use custom background is available
    [self refreshBackground];
}

#pragma mark Background Image
//simple refresh
- (void)refreshBackground
{
    //grab background
    UIImage *backgroundImage;
    if (_delegate && [_delegate respondsToSelector:@selector(customBackgroundForBlurredView:)]){
        backgroundImage = [_delegate customBackgroundForBlurredView:self];
    }else{
        backgroundImage = [self screenShotImage];
    }
    
    [self refreshBackgroundWithSpecificBackgroundImage:backgroundImage];
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
    UIImage *backgroundImage;
    if (_delegate && [_delegate respondsToSelector:@selector(customBackgroundForBlurredView:)]){
        backgroundImage = [_delegate customBackgroundForBlurredView:self];
    }else{
        backgroundImage = [self screenShotImage];
    }
    
    [self refreshBackgroundWithAnimationCode:animationCode duration:duration withSpecificBackgroundImage:backgroundImage];
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

//in case the view is reused and the frame is changed, this function is to be called
- (void)resetRelativeOrigin
{
    //this is not always the correct origin, so watch out
    //this function attemps to calculate where exactly this view situated on the screen
    //it iterates until there is no more
    _relativeOrigin = self.frame.origin;
    UIView *parentView = self;
    while ((parentView = parentView.superview)) {
        _relativeOrigin = [BTBlurredView combinePoint:parentView.frame.origin withPoint:_relativeOrigin];
    }
}

#pragma mark Movement
- (void)viewDidMoveToPointOffset:(CGPoint)pointOffset
{
    if (![self isViewVisibleOnScreenWithOffset:pointOffset]) {
        return;
    }
    
    pointOffset = [BTBlurredView combinePoint:[BTBlurredView reversePoint:pointOffset] withPoint:_relativeOrigin];
    [_dynamicBackgroundScrollView setContentOffset:pointOffset];
}

#pragma mark Setters

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

//Just in case someone decided to move from one form to another, not recommended for use
- (void)setIsStaticOnly:(BOOL)isStaticOnly
{
    if (isStaticOnly == _isStaticOnly) {
        return;
    }
    _isStaticOnly = isStaticOnly;
    
    if (_isStaticOnly) {
        _backgroundScrollView = nil;
    }else if(!_backgroundScrollView){
        //if it is not static and has not been assigned, search through superview until finds scrollview or set to nil
        UIView *parentView = self;
        while ((parentView = parentView.superview)) {
            if ([parentView isKindOfClass:[UIScrollView class]]) {
                _backgroundScrollView = (UIScrollView *)parentView;
                break;
            }
        }
    }
}

//this overwrite allows the background to scroll even with UIView animate
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    //scroll background accordingly
    [self resetRelativeOrigin];
    
    //since scrollables will have to keep track of its superview offset
    CGPoint pointOffset = _relativeOrigin;
    if (_backgroundScrollView) {
        pointOffset = [BTBlurredView combinePoint:[BTBlurredView reversePoint:_backgroundScrollView.contentOffset] withPoint:pointOffset];
    }
    [_dynamicBackgroundScrollView setFrame:CGRectOffset(frame, -frame.origin.x, -frame.origin.y)];
    [_dynamicBackgroundScrollView setContentOffset:pointOffset];
}

#pragma mark - Global
+ (UIImage *)grabScreenFromBackgroundView:(UIView *)backgroundView
{
    UIGraphicsBeginImageContextWithOptions(backgroundView.bounds.size, YES, 0.0f);
    [backgroundView drawViewHierarchyInRect:backgroundView.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (CGPoint)combinePoint:(CGPoint)point1 withPoint:(CGPoint)point2
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

+ (CGPoint)reversePoint:(CGPoint)point
{
    return CGPointMake(-point.x, -point.y);
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
    
    UIImage *image = [BTBlurredView grabScreenFromBackgroundView:_backgroundView];
    
    //put itself back
    [self setAlpha:1];
    
    return image;
}

- (void)parentScrollViewDidScroll:(NSNotification *)notification
{
    UIScrollView *parentScrollView = notification.object;
    [self viewDidMoveToPointOffset:parentScrollView.contentOffset];
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
    
    return YES;
}

@end
