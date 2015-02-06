//
//  ApprovalViewController.m
//  testProjForUsingImages
//
//  Created by Evan Vandenberg on 2/2/15.
//  Copyright (c) 2015 Evan Vandenberg. All rights reserved.
//

#import "ApprovalViewController.h"
#import "SharePhotoViewController.h"
#import <Parse/Parse.h>

@interface ApprovalViewController ()
@property PFFile *photoFile;

@end

@implementation ApprovalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passedImage.image = self.imageForApproval;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SharePhotoViewController *shareVC = segue.destinationViewController;
    shareVC.thumbnail = self.imageForApproval;
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelImageButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
