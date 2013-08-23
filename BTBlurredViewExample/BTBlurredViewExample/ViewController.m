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
    BTBlurredView *_blurredView;
    
    BOOL viewIsStatic;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //turn this off to test effect of using it as live view
        viewIsStatic = NO;
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
    
    
    if (viewIsStatic) {
        //Normal circumstance
        _blurredView = [[BTBlurredView alloc] init];
        [_blurredView setFrame:CGRectMake(viewWidth/2, viewHeight/2, viewWidth, viewHeight)];
        [_blurredView setDelegate:self];
        [self.view addSubview:_blurredView];
    }else{
        
        UIView *someView = [[UIView alloc] initWithFrame:CGRectMake(30, 20, 50, 60)];
        someView.backgroundColor = [UIColor blueColor];
        [someView.layer setCornerRadius:5];
        [self.view  addSubview:someView];
        
        UIView *someView2 = [[UIView alloc] initWithFrame:CGRectMake(90, 60, 70, 40)];
        someView2.backgroundColor = [UIColor whiteColor];
        [someView2.layer setCornerRadius:5];
        [self.view  addSubview:someView2];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        [scrollView setDelegate:self];
        [scrollView setContentSize:self.view.frame.size];
        [scrollView setContentInset:UIEdgeInsetsMake(self.view.frame.size.height - viewHeight, self.view.frame.size.width - viewWidth, 0, 0)];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [self.view addSubview:scrollView];
        
        _blurredView = [[BTBlurredView alloc] init];
        [_blurredView setDelegate:self];
        [_blurredView.layer setCornerRadius:5];
        [_blurredView setFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        [_blurredView setBackgroundView:self.view];
        [_blurredView setClipsToBounds:YES];
        [scrollView addSubview:_blurredView];
    }	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate
#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //calculate relative frame
    [_blurredView viewDidMoveToPointOffset:scrollView.contentOffset];
}

#pragma mark BTBlurredView
- (UIImage *)blurImageForBlurredView:(BTBlurredView *)blurredView image:(UIImage *)image
{
    //if you like to mess around with the effect, can be done on the fly, or inside the view itself
    return [image applyLightEffect];
}
@end
