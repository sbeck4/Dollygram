//
//  ProfileViewController.m
//  Dollygram
//
//  Created by Shannon Beck on 2/2/15.
//  Copyright (c) 2015 Shannon Beck. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileCollectionViewCell.h"

@interface ProfileViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
@property UIActionSheet *changeProfileImageActionSheet;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property PFFile *photoFile;
@property NSData *profileImageData;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property PFQuery *query;
@property PFQuery *query2;
@property NSMutableArray *photosArray;
@property (strong, nonatomic) IBOutlet UILabel *postsLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersLabel;
@property (strong, nonatomic) IBOutlet UILabel *followingLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageCropper;

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
                 self.profileImageCropper.image = [UIImage imageNamed:@"ProfileImageCircle"];
             }
         }];
        self.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        self.navigationItem.title = [currentUser username];

        [self followNumbers];

        self.query = [PFQuery queryWithClassName:@"Photo"];
        //[self.query orderByDescending:@"createdAt"];
        [self.query whereKey:@"PhotoPoster" equalTo:currentUser.objectId];
        //[self.query whereKey:@"owner" equalTo:currentUser.objectId];

        self.photosArray = [[[NSArray alloc]init]mutableCopy];
        self.photosArray = [[self.query findObjects]mutableCopy];
        self.postsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.photosArray.count];
        [self.collectionView reloadData];
    }
    else
    {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
   // self.photoFile = nil;
    [super viewDidDisappear:YES];
    self.profileImage.image = [UIImage imageNamed:@"profile-icon"];
    [self.photosArray removeAllObjects];
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

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    PFObject *photo = self.photosArray[indexPath.row];

    PFFile *file = [photo objectForKey:@"PhotoZ"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             cell.profileImageView.image = [UIImage imageWithData:data];
         }
     }];

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosArray.count;
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

- (void)followNumbers
{
    NSString *followId = [[PFUser currentUser] objectForKey:@"FollowObjectId"];
    PFQuery *followZ = [PFQuery queryWithClassName:@"Follow"];
    [followZ whereKey:@"objectId" equalTo:followId];
    NSArray *thisArrayForNow = [followZ findObjects];
    PFObject *follow = thisArrayForNow.firstObject;


    PFQuery *query2 = [PFQuery queryWithClassName:@"Following"];
    NSArray *thisArray = [query2 findObjects];
    if (thisArray.count != 0)
    {
        [query2 whereKey:@"FollowObjectId" equalTo:follow.objectId];
        NSArray *tempArray2 = [query2 findObjects];
        self.followingLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)tempArray2.count];
    }

    PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
    NSArray *thisOtherArray = [query findObjects];
    if (thisOtherArray.count != 0)
    {
        [query whereKey:@"FollowObjectId" equalTo:follow.objectId];
        NSArray *tempArray = [query findObjects];
        self.followersLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)tempArray.count];
    }


}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"settingsSegue"])
//    {
//        [self.photosArray removeAllObjects];
//    }
}



@end
