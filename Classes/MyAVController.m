//
//  MyAVController.h
//
//
//  Created by Mike Chen on 12/8/12.
//
//

#import "MyAVController.h"
#import "PreviewScreenViewController.h"

@implementation MyAVController
@synthesize captureSession = _captureSession;
@synthesize prevLayer = _prevLayer;

#pragma mark -
#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {

		self.prevLayer = nil;
			
		//Set our camera to be front facing.
		self.isAVCaptureDeviceFrontCamera = TRUE;
		//self.isAVCaptureDeviceFrontCamera = FALSE;

	}
	return self;
}

- (void)viewDidLoad {
		
	  // Set up AVFoundation classes
	  [self initCaptureSession];
				
		// Take a picture button
		UIButton *takePicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[takePicButton addTarget:self
											action:@selector(takePicButtonSelected)
						forControlEvents:UIControlEventTouchDown];
		[takePicButton setTitle:@"Pic" forState:UIControlStateNormal];
		takePicButton.frame = CGRectMake(250.0, 440.0, 71.0, 36.0);
		[self.view addSubview:takePicButton];

		// Customize our own switch camera button like UIImagePickerController
		UIButton *switchCameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[switchCameraButton setImage:[UIImage imageNamed:@"switchCamera.png"]
												forState:UIControlStateNormal];
		[switchCameraButton addTarget:self action:@selector(toggleCameraButtonSelected)
								        forControlEvents:UIControlEventTouchDown];
		[switchCameraButton setFrame:CGRectMake(255, 15, 60, 40)];
		[switchCameraButton setAlpha:0.5];
		[self.view addSubview:switchCameraButton];
		
		[[UIApplication sharedApplication] setStatusBarHidden:YES];

}

#pragma mark - IBAction

- (void)toggleCameraButtonSelected
{
		/* The begin and commit configuration brackets are not necessary 
		   and when I test this it did not make a difference but Apple 
		   documenation advises you to use this to ensure a smooth transition 
		   between front and back camera */
		[self.captureSession beginConfiguration];
		
		// Reconfigure our session by adding a new input
		[self.captureSession removeInput:self.captureInput];
		AVCaptureDevice *captureDevice;
    if(self.isAVCaptureDeviceFrontCamera == TRUE){
        captureDevice = [self backCamera];
				self.isAVCaptureDeviceFrontCamera = false;
    } else {
        captureDevice = [self frontFacingCameraIfAvailable];
				self.isAVCaptureDeviceFrontCamera = TRUE;
    }
    self.captureInput = [AVCaptureDeviceInput
										deviceInputWithDevice:captureDevice
										error:nil];
		[self.captureSession addInput:self.captureInput];
		[self.captureSession commitConfiguration];
}

- (void)takePicButtonSelected {
		
		// Check if there is a connection for the output
		AVCaptureConnection *videoConnection = nil;
		for (AVCaptureConnection *connection in self.stillImageOutput.connections)
		{
				for (AVCaptureInputPort *port in [connection inputPorts])
				{
						if ([[port mediaType] isEqual:AVMediaTypeVideo] )
						{
								videoConnection = connection;
								break;
						}
				}
				if (videoConnection) { break; }
		}

		// Apples's custom method from AVCaptureStillImageOutput to capture a image
		[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
		 {
				 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
				 UIImage *image = [[UIImage alloc] initWithData:imageData];
				 
				 PreviewScreenViewController *previewScreenViewController = [[PreviewScreenViewController alloc] init];
				 [previewScreenViewController setImage:image];
				 
				 // Must let the preview screen know whether the image passed
				 // is from the front facing or back camera. The front camera
				 // will create a mirror image by default so we will adjust
				 // the image in the PreviewScreenViewController
				 [previewScreenViewController setIsAVCaptureDeviceFrontCamera:self.isAVCaptureDeviceFrontCamera];
				 [self presentViewController:previewScreenViewController animated:NO completion:^{
				 }];
		}];
}

#pragma mark - AVFoundation methods
- (void)initCaptureSession {
		
    // Start with the front facing camera if it's available
    self.captureInput =
    [AVCaptureDeviceInput deviceInputWithDevice:
		 [self frontFacingCameraIfAvailable] error:nil];
		
		// Add an output object to our session so we can get a still image
		// We retain a handle to the still image output and use this when
		// we capture an image.
		self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
		[self.stillImageOutput setOutputSettings:outputSettings];
		
		
		/* Have the option to configure multiple frames by setting yourself
		 as the AVCaptionSession delegate which will call the method
		 captureOutput:didOutputSampleBuffer:fromConnection:
		 But we only only need one frame/image so we will eventually 
		 use apple's "captureStillImageAsynchronouslyFromConnection" when
		 take a picture

		AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
		captureOutput.alwaysDiscardsLateVideoFrames = NO;
		dispatch_queue_t queue;
		queue = dispatch_queue_create("cameraQueue", NULL);
		[captureOutput setSampleBufferDelegate:self queue:queue];
		dispatch_release(queue);
		*/
		
		//And we create a capture session
		self.captureSession = [[AVCaptureSession alloc] init];
		/*We add input and output*/
		[self.captureSession addInput:self.captureInput];
		//[self.captureSession addOutput:captureOutput];
		[self.captureSession addOutput:self.stillImageOutput];
		[self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
		
		/*We add the preview layer which is the actual video screen you will see*/
		self.prevLayer = [AVCaptureVideoPreviewLayer
											layerWithSession: self.captureSession];
		self.prevLayer.frame = CGRectMake(0, 0, 320, 480);
		
		//self.prevLayer.frame = self.prevLayer.bounds;
		self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		//self.prevLayer.videoGravity = AVLay;
		[self.view.layer addSublayer: self.prevLayer];
		
		/*We start the capture*/
		[self.captureSession startRunning];
}

- (AVCaptureDevice *)frontFacingCameraIfAvailable
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
		// Front facing cameras are only available for iphone4 and higher.
		// If the device does not have a front camera, then just return the default
		
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return captureDevice;
}

- (AVCaptureDevice *)backCamera
{
    //  look at all the video devices and get the first one that's on the back
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
            break;
        }
    }
		
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
		
    return captureDevice;
}

#pragma mark -
#pragma mark AVCaptureSession delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection 
{
		// Another way to handle customize frames 
		//NSLog(@"Frame sent");
} 
 
#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	//self.imageView = nil;
	//self.customLayer = nil;
	self.prevLayer = nil;
}

- (void)dealloc {
	[self.captureSession release];
    [super dealloc];
}


@end