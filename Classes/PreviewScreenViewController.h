//
//  ShowImageViewController.h
//  MyAVController
//
//  Created by Mike Chen on 12/8/12.
//
//

#import <UIKit/UIKit.h>
#import "VBColorPicker.h"

@interface PreviewScreenViewController : UIViewController  <UITextFieldDelegate,VBColorPickerDelegate>
{
		// Draw Pad
		CGPoint pencilLastPoint;
    CGFloat brush;
    CGFloat opacity;
		CGFloat hue;
    BOOL mouseSwiped;
		BOOL drawPadOn;
		BOOL eraserOn;
		UIColor *penColor;
		
		// Caption
		bool captionOn;
		CGPoint captionLastPoint;
}

- (IBAction)savePic:(id)sender;

@property (nonatomic, strong)UIImage *image;
- (IBAction)dismiss:(id)sender;
@property (nonatomic, readwrite) BOOL isAVCaptureDeviceFrontCamera;

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIImageView *tempDrawImage;

// Drawpad
@property (retain, nonatomic) IBOutlet UIButton *eraser;
- (IBAction)eraserPressed:(id)sender;
- (IBAction)pencilButtonPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *pencilButton;
@property (retain, nonatomic) IBOutlet UILabel *pencilColorIndicator;
@property (nonatomic, strong) VBColorPicker *cPicker;
@property (nonatomic, strong) UIColor *pencilColor;

//Caption
- (IBAction)captionMoved:(id)sender withEvent:(UIEvent *)event;
@property (retain, nonatomic) IBOutlet UITextField *captionLabel;
@property (retain, nonatomic) IBOutlet UIButton *captionButton;
- (IBAction)captionButtonPressed:(id)sender;

@end






