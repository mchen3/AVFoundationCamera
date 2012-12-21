//
//  MyAVController.h
//  
//
//  Created by Mike Chen on 12/8/12.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/CGImageProperties.h>

@interface MyAVController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{		
	AVCaptureSession *_captureSession;

	AVCaptureVideoPreviewLayer *_prevLayer;
}

/*!
 @brief	The capture session takes the input from the camera and capture it
 */
@property (nonatomic, retain) AVCaptureSession *captureSession;

/*!
 @brief	The CALAyer customized by apple to display the video corresponding to a capture session
 */
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;

/*!
 @brief	This method initializes the capture session
 */
- (void)initCaptureSession;

@property (nonatomic, strong) UIImage *globalImage;
@property (nonatomic, readwrite) BOOL isAVCaptureDeviceFrontCamera;
@property (nonatomic, strong) AVCaptureDeviceInput *captureInput;
@property (nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

@end
















