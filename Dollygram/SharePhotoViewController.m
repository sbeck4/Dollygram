//
//  SharePhotoViewController.m
//  Dollygram
//
//  Created by Shannon Beck on 2/2/15.
//  Copyright (c) 2015 Shannon Beck. All rights reserved.
//

#import "SharePhotoViewController.h"
#import <Parse/Parse.h>

@interface SharePhotoViewController () <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (strong, nonatomic) IBOutlet UITextView *commentsTextField;
@property PFFile *photoFile;

@end

@implementation SharePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.thumbnailImage.image = self.thumbnail;
    self.commentsTextField.delegate = self;
    // Do any additional setup after loading the view.
}

- (IBAction)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

- (IBAction)shareImageButtonTapped:(id)sender
{
    PFObject *photo = [PFObject objectWithClassName:@"Photo"];
    PFObject *activity = [PFObject objectWithClassName:@"Activity"];

    NSData *imageData = UIImageJPEGRepresentation(self.thumbnailImage.image, 0.8f);
    self.photoFile = [PFFile fileWithData:imageData];

    [photo setObject:self.photoFile forKey:@"PhotoZ"];
    [photo setObject:[PFUser currentUser].objectId forKey:@"PhotoPoster"];
    [photo setObject:self.commentsTextField.text forKey:@"PhotoDescription"];

    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         [photo setObject:activity.objectId forKey:@"PhotoActivityId"];

         [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];

          }];

     }];

   // [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}


@end
