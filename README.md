BTBlurredView
=============
This is a view for you to either subclass or use as-is. The view comes loaded with the ability to:

1. Generate screen grab (ignoring itself)
2. Blur the image - This is lifted from Apple's example
3. Fake a live blur by scrolling the image in the opporsite direction of the motion
4. It should just work! like magic! 

**Background:**  
Since Apple do not provide us with the blur that they use in their navigation controller, I created a view that mimics the live blur. As mention above, this is not a real live blur, but a fake one. Thus limitation is to be expected. The reason that I used the fake method because on-the-fly blur is very resource draining and laggy. 

**Implementation:**  
The view is a subclass of a UIView. It has a scrollView (X) that is not user interactable as its default background. This scrollView (X) scroll in the opporsite way of the scrollView (Y) that host this blurredView (superview). This behaviour gives the illusion that the BTBlurredView is blurring the background on the fly. In reality, the whole background was blurred only once. 

**How to use:**

1. Import `BTBlurredView.h`
2. Create an instance of blurredView  
3. Setup - If superview is not the background you want, specifically assign that to `backgroundView` iVar (Most of the time it is not)
4. Setup2 - If the default `relativeOrigin` is not good enough (I highly recommend you try the default before tinkering with it), assign it a better origin (your view origin w.r.t. the device screen)
5. Blur - You can implement the delegate or just mess with the file for different blur effect  
6. Live - Make sure when you scroll background, do an update to the view by calling (If the view is static, set `isStaticOnly` to `YES`)   
	6a. scroll - `(void)viewDidMoveToPointOffset:(CGPoint)pointOffset  `  
	6b. Alernatively, create an observer by setting `shouldObserveScroll` to `YES` and send notification `PARENT_SCROLL_NOTIFICATION` with the new contentOffset
7. change background - `(void)refreshBackground` (Alternatively you can assign your own flavour with the delegate `(UIImage *)customBackgroundForBlurredView:(BTBlurredView *)blurredView`)


Please view example project to get the idea of how to implement. 

**Note:**
* `(void)refreshBackgroundWithAnimationCode:(AnimationCode)animationCode duration:(CGFloat)duration` is an experimentation that did not quite take off. However, it still contains a pretty nice effect, so I left it in there. It allows the change in the background to have animation. Sadly, it cannot do a synchronized animation since the screen is not ready to be grabbed until the background is done animating. 

* `shouldUseExperimentOptimization`, if set to `YES`, will try to determine if your view is within the bound of the device, if not, it will not update the background. This is done to optimize the use of the scrollView.
