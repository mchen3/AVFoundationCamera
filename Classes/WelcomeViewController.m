#import "WelcomeViewController.h"
#import "MyAVController.h"

@implementation WelcomeViewController

- (IBAction)startFlashcodeDetection {
  [self presentViewController:[[MyAVController alloc]
															 init] animated:NO completion:^{
	}];
}

- (void)dealloc {
    [super dealloc];
}

@end
