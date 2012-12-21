//
//  ShowImageViewController.m
//  MyAVController
//
//  Created by Mike Chen on 12/8/12.
//
//

#import "PreviewScreenViewController.h"
#import "MessageViewController.h"
#include <QuartzCore/QuartzCore.h>

@interface PreviewScreenViewController ()
@end

@implementation PreviewScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
		
		// Set caption on and draw pad off by default
		captionOn = TRUE;
		drawPadOn = FALSE;

		[self.captionLabel setHidden:TRUE];
		
		// Drawpad settings
		hue = 0.0;
    brush = 6.0;
    opacity = 1.0;
		self.pencilColor = [UIColor blueColor];
		self.pencilColorIndicator.backgroundColor = self.pencilColor;
		// Color picker
		self.cPicker = [[VBColorPicker alloc]
										initWithFrame:CGRectMake(0, 0, 202, 21)];
		[_cPicker setCenter:CGPointMake(130, 380)];
		[self.view addSubview:_cPicker];
		[_cPicker setDelegate:self];
		[_cPicker showPicker];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pencilColorPickerPressed) name:@"pencilColorPickerPressed" object:nil];
    
		// See if the image is the correct view
		UIImage *originalImage = self.image;
		UIImage *finalImage = originalImage;
		// If the image was from the front facing camera we need to 
		// correct the default setting, which mirrors the image, so 
		// change the image back to the original view
		if (self.isAVCaptureDeviceFrontCamera) {
				CGSize imageSize = originalImage.size;
				UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1.0);
				CGContextRef ctx = UIGraphicsGetCurrentContext();
				CGContextRotateCTM(ctx, M_PI/2);
				CGContextTranslateCTM(ctx, 0, -imageSize.width);
				CGContextScaleCTM(ctx, imageSize.height/imageSize.width, imageSize.width/imageSize.height);
				CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, imageSize.width,imageSize.height), originalImage.CGImage);
				finalImage = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
		}
		
		[self.imageView setImage:finalImage];
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
		
		[[NSNotificationCenter defaultCenter] removeObserver:self
								name:@"pencilColorPickerPressed" object:nil];
		
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
		
		[[NSNotificationCenter defaultCenter] removeObserver:self
						name:@"pencilColorPickerPressed" object:nil];
		
    [_imageView release];
		[_tempDrawImage release];
		[_eraser release];
		[_pencilButton release];
		[_pencilColorIndicator release];
		[_captionLabel release];
		[_captionButton release];
    [super dealloc];
}
- (IBAction)dismiss:(id)sender {
		[self dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark - Drawpad and Caption helper methods
// Customize touchesBegan, touchedMoved, and touchedEnded for our draw pad
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
		
		mouseSwiped = NO;
		UITouch *touch = [touches anyObject];
		
		pencilLastPoint = [touch locationInView:self.view];
		
		// Only set the location of our caption when the drawpad is not on
		if (!drawPadOn) {
				captionLastPoint = [touch locationInView:self.view];
		}

		// Caption feature appears when the user touches the screen
		// assuming that captioOn is TRUE and drawPadOn is false
		if (captionOn) {
				[self.captionLabel setHidden:FALSE];
				[self.captionLabel setCenter:CGPointMake(160, 240)];
				[self.captionLabel becomeFirstResponder];
		}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
		
		if (drawPadOn) {
				mouseSwiped = YES;
				UITouch *touch = [touches anyObject];
				CGPoint currentPoint = [touch locationInView:self.view];
    
		// Draw pencil
				UIGraphicsBeginImageContext(self.view.frame.size);
				[self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
				CGContextMoveToPoint(UIGraphicsGetCurrentContext(), pencilLastPoint.x, pencilLastPoint.y);
				CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
				CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
				CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
				CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.pencilColor.CGColor);
		// Eraser
		if (eraserOn) {
				CGContextSetBlendMode(UIGraphicsGetCurrentContext(),  kCGBlendModeClear);
		}
		else
		{
				CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
		}

				CGContextStrokePath(UIGraphicsGetCurrentContext());
				self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
				[self.tempDrawImage setAlpha:opacity];
				UIGraphicsEndImageContext();
				pencilLastPoint = currentPoint;
		}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
		
		if (drawPadOn) {
				if(!mouseSwiped) {
						UIGraphicsBeginImageContext(self.view.frame.size);
						[self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
						CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
						CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
						CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.pencilColor.CGColor);
				
				if (eraserOn ) {
						CGContextSetBlendMode(UIGraphicsGetCurrentContext(),  kCGBlendModeClear);
				}
				else
				{
						CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
				}
						
						CGContextMoveToPoint(UIGraphicsGetCurrentContext(), pencilLastPoint.x, pencilLastPoint.y);
						CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), pencilLastPoint.x, pencilLastPoint.y);
						CGContextStrokePath(UIGraphicsGetCurrentContext());
						CGContextFlush(UIGraphicsGetCurrentContext());
						self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
						UIGraphicsEndImageContext();
       }
		}
}

#pragma mark - IBAction

- (IBAction)captionButtonPressed:(id)sender {
		captionOn = TRUE;
		drawPadOn = FALSE;
}

- (IBAction)eraserPressed:(id)sender {
		eraserOn = TRUE;
		drawPadOn = TRUE;
		captionOn = FALSE;
		brush = 35.0;
}

- (IBAction)pencilButtonPressed:(id)sender {
		drawPadOn = TRUE;
		captionOn = FALSE;
		eraserOn = FALSE;
		brush = 6.0;
}

// Move the caption up and down but never left or right
- (IBAction) captionMoved:(id) sender withEvent:(UIEvent *) event
{
		
		if ([self.captionLabel isFirstResponder] || (drawPadOn)) {
				return;
		}
		
    UIControl *control = sender;
    UITouch *t = [[event allTouches] anyObject];
    CGPoint pPrev = [t previousLocationInView:control];
    CGPoint p = [t locationInView:control];
    CGPoint center = control.center;
		
		// Disable the caption movement to go left or right
		// center.x += p.x - pPrev.x;
    center.y += p.y - pPrev.y;
				
		// Make sure our caption cannot be moved off the screen from the top or bottom
		if (center.y <= 20 || center.y >= 460) {
				return;
		}
    control.center = center;
		pencilLastPoint = center;
		captionLastPoint = center;
}

- (IBAction)savePic:(id)sender {
		
		//float xValue = captionLastPoint.x;
		float yValue = captionLastPoint.y;
		
		// Draw a rect with the contents of drawpad and caption
		UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
		UIView *parentView = [[UIView alloc] initWithFrame:CGRectZero];
		[parentView addSubview:self.tempDrawImage];
		[self.tempDrawImage setFrame:CGRectMake(0, 0, 320, 480)];
		[parentView addSubview:self.captionLabel];
		[self.captionLabel setFrame:CGRectMake(12, yValue -20, 296, 41)];
		[parentView sizeToFit];
		// Have to add QuartzCore class to use renderInContext
		[[parentView layer] renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *finalDrawpadImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		/* Add the drawpad and caption views back to the main view otherwise
		   you will get an error when you dismiss the MessageViewController
		   and come back to the PreviewScreenViewController */
		[self.view addSubview:self.tempDrawImage];
		[self.tempDrawImage setFrame:CGRectMake(0, 0, 320, 480)];
		[self.view addSubview:self.captionLabel];
		/* Place the caption in its last known location. You also have to
		   turn off autolayout in the xib otherwise the location of the
		   caption will always be in the same location as the point that
		   we originally set it in our xib. */
		[self.captionLabel setBounds:CGRectMake(12, yValue -20, 296, 41)];
		
		MessageViewController *message = [[MessageViewController alloc] init];
		[message setDrawImage:finalDrawpadImage];
		[message setMainImage:self.imageView.image];
		[self presentViewController:message animated:NO completion:^{
			//	NSLog(@"%@", NSStringFromCGPoint(captionLastPoint));
		}];
}

#pragma mark - Pencil color delegate
// Pressing the color picker
- (void) pickedColor:(UIColor *)color {
		self.pencilColor = color;
		self.pencilColorIndicator.backgroundColor = color;
		drawPadOn = TRUE;
		captionOn = FALSE;
}

#pragma mark - NSNotification handler
-(void)pencilColorPickerPressed
{
		eraserOn = FALSE;
		brush = 6.0;
}

#pragma mark - UITextField delegates and helpers
// Customize for our Caption location
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
		[self.captionLabel resignFirstResponder];
		[self.captionLabel setTextAlignment:NSTextAlignmentCenter];
		
		// When the user presses return on the keyboard reset the location
		// of the caption to where the user first touched the screen.
		float xValue = 160.0f;
		if (captionLastPoint.y <= 0) {
				captionLastPoint.y = 0;
		}
		else if (captionLastPoint.y >= 360) {
				captionLastPoint.y = 360;
		}
		float yValue = captionLastPoint.y;

		[self.captionLabel setCenter:CGPointMake(xValue, yValue)];
		return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
		// Place the Caption in the midde when the user starts editing
		[self.captionLabel setCenter:CGPointMake(160, 240)];
		return YES;
}

@end





































