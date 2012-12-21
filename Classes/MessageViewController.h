//
//  testViewController.h
//  Camera1
//
//  Created by Mike Chen on 12/10/12.
//
//

#import <UIKit/UIKit.h>

@interface MessageViewController : UIViewController

- (IBAction)dismiss:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *mainImageView;
@property (retain, nonatomic) UIImage *mainImage;
@property (retain, nonatomic) IBOutlet UIImageView *drawImageView;
@property (retain, nonatomic) UIImage *drawImage;

@end
