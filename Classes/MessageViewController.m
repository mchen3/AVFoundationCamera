//
//  testViewController.m
//  Camera1
//
//  Created by Mike Chen on 12/10/12.
//
//

#import "MessageViewController.h"
@interface MessageViewController ()
@end

@implementation MessageViewController

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
    // Do any additional setup after loading the view from its nib.
		
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
		
		[self.mainImageView setImage:self.mainImage];
		[self.drawImageView setImage:self.drawImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
		[_drawImageView release];
		[_mainImageView release];
    [super dealloc];
}
- (IBAction)dismiss:(id)sender {
		[self dismissViewControllerAnimated:NO
														 completion:^{}];
}

@end













