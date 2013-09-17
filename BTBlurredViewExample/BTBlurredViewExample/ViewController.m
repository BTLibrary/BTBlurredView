//
//  ViewController.m
//  BTBlurredViewExample
//
//  Created by Byte on 8/19/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//


#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    BTBlurredView *_staticBlurredView;
    BTBlurredView *_scrollingBlurredView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"abstract"]];
    CGFloat viewWidth = self.view.frame.size.width/3;
    CGFloat viewHeight = self.view.frame.size.height/4;
    
    //Simple implementation
    if (YES) {
        _staticBlurredView = [[BTBlurredView alloc] init];
        [_staticBlurredView setFrame:CGRectMake(viewWidth/2, viewHeight/2, viewWidth, viewHeight)];
        [self.view addSubview:_staticBlurredView];
        //YES IT IS THAT SIMPLE!!
    }
    
    //BlurView On scrollView
    if (YES) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        [scrollView setDelegate:self];
        [scrollView setContentSize:self.view.frame.size];
        [scrollView setContentInset:UIEdgeInsetsMake(self.view.frame.size.height - viewHeight, self.view.frame.size.width - viewWidth, 0, 0)];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [self.view addSubview:scrollView];
        
        
        _scrollingBlurredView = [[BTBlurredView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        //since this the scrollview is not the background view, explicitly set the background view
        [_scrollingBlurredView setBackgroundView:self.view];
        //only set it to YES if your view is surely moving in and out of the screen a lot (ie when use with un optimized tableview)
        [_scrollingBlurredView setShouldUseExperimentOptimization:YES];
    
        //delegate is optional, can call on-the-fly different blur
        [_scrollingBlurredView setDelegate:self];

        //can set up listener
        [_scrollingBlurredView setShouldObserveScroll:YES];
        [scrollView addSubview:_scrollingBlurredView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    // this is an example of animating the static blurred view, without the use of scrollView
    // you will see that the fake live blur has its limitation when this is happening
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.5 animations:^{
            _staticBlurredView.frame = CGRectOffset(_staticBlurredView.frame, 200, 200);
        } completion:^(BOOL finished) {
            //remembers that the background of other view is not live, you need to refresh
            [_scrollingBlurredView refreshBackground];
        }];
    });
}

#pragma mark - delegate
#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //there are 2 ways to do this,
    BOOL withObserverWay = NO;
    if (withObserverWay) {
        //this will hit all the scrollViews that enables it, use this when you have many blurredView in one scrollview.
        [[NSNotificationCenter defaultCenter] postNotificationName:PARENT_SCROLL_NOTIFICATION object:scrollView];
    }else{
        //this works individually
        [_scrollingBlurredView viewDidMoveToPointOffset:scrollView.contentOffset];
    }
    
    //calculate relative frame
}

#pragma mark BTBlurredView
- (UIImage *)blurImageForBlurredView:(BTBlurredView *)blurredView image:(UIImage *)image
{
    //if you like to mess around with the effect, can be done on the fly, or inside the view itself
    return /*[image applyBlurWithRadius:3 tintColor:[UIColor colorWithWhite:1.0 alpha:0.4] saturationDeltaFactor:1 maskImage:nil];*/[image applyLightEffect];
}
@end
