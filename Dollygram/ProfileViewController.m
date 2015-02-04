//
//  ProfileViewController.m
//  Dollygram
//
//  Created by Shannon Beck on 2/2/15.
//  Copyright (c) 2015 Shannon Beck. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
@property UIActionSheet *changeProfileImageActionSheet;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property PFFile *photoFile;
@property NSData *profileImageData;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];

        [myAlertView show];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    PFUser *currentUser = [PFUser currentUser];

    if (currentUser)
    {
        NSLog(@"Current user: %@", [currentUser username]);

        NSString *firstName = [currentUser objectForKey:@"firstName"];
        NSString *lastName = [currentUser objectForKey:@"lastName"];
        self.photoFile = [currentUser objectForKey:@"profileImage"];
        [self.photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 self.profileImage.image = [UIImage imageWithData:data];
             }
         }];
        self.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        self.navigationItem.title = [currentUser username];

    }
    else
    {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }

}

- (void)viewDidDisappear:(BOOL)animated
{
    self.photoFile = nil;
}

- (IBAction)profilePictureTapped:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo",@"Choose Existing Photo", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;

        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if (buttonIndex == 1)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

        [self presentViewController:picker animated:YES completion:NULL];
    }

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImage.image = chosenImage;

    PFUser *currentUser = [PFUser currentUser];

    self.profileImageData = UIImagePNGRepresentation(self.profileImage.image);
    self.photoFile = [PFFile fileWithData:self.profileImageData];

   // NSData *imageData = UIImagePNGRepresentation(imageView.image);
   // PFFile *file = [PFFile fileWithData:imageData]

    [currentUser setObject:self.photoFile forKey:@"profileImage"];

    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         [self.photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 self.profileImage.image = [UIImage imageWithData:data];
             }
         }];
     }];

    [picker dismissViewControllerAnimated:YES completion:NULL];

//    [self performSegueWithIdentifier:@"ApprovalSegue" sender:self];

}



@end
