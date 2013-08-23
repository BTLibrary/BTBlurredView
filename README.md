BTBlurredView
=============
This is a view for you to either subclass or use as-is. The view comes loaded with the ability to:  
	1. Generate screen grab (ignoring itself)  
	2. Blur the image - This is lifted from Apple's example  
	3. Fake a live blur by scrolling the image in the opporsite direction of the motion  

**Background:**  
Since Apple do not provide us with the blur that they use in their navigation controller, I created a view that mimics the live blur. As mention above, this is not a real live blur, but a fake one. Thus limitation is to be expected. The reason that I used the fake method because on-the-fly blur is very resource draining and laggy. 

**Implementation:**  
The view is a subclass of a UIView. It has a scrollView (X) that is not user interactable as its default background. This scrollView (X) scroll in the opporsite way of the scrollView (Y) that host this blurredView (superview). This behaviour gives the illusion that the BTBlurredView is blurring the background on the fly. In reality, the whole background was blurred only once. 

**How to use:**  
	1.) Import BTBlurredView.h  
	2.) Create an instance of blurredView  
	3.) If superview is not the background you want, specifically assign that to backgroundView iVar  
	4.) If the frame does not align with the background, assign that to the relativeFrame iVar  
	5.) Optional: you can implement the delegate or just mess with the file for different blur effect  
	6.) Make sure when you scroll/change background, do an update to the view by calling   
		6a.) scroll - (void)viewDidMoveToPointOffset:(CGPoint)pointOffset  
		6b.) change background - (void)refreshBackground  
	7.) Profit!  

Please view example project to get the idea of how to implement. 

**Note:**
(void)refreshBackgroundWithAnimationCode:(AnimationCode)animationCode duration:(CGFloat)duration is an experimentation that did not quite take off. However, it still contains a pretty nice effect, so I left it in there. It allows the change in the background to have animation. Sadly, it cannot do a synchronized animation since the screen is not ready to be grabbed until the background is done animating. 
