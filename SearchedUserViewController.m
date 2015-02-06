//
//  SearchedUserViewController.m
//  Dollygram
//
//  Created by Shannon Beck on 2/4/15.
//  Copyright (c) 2015 Shannon Beck. All rights reserved.
//

#import "SearchedUserViewController.h"
#import "ProfileCollectionViewCell.h"
#import "SearchedUserCollectionViewCell.h"

@interface SearchedUserViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
@property PFFile *photoFile;
@property NSData *profileImageData;
@property PFQuery *query;
@property PFQuery *query2;
@property NSMutableArray *photosArray;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageCropper;

@end

@implementation SearchedUserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
        NSString *firstName = [self.searchedUser objectForKey:@"firstName"];
        NSString *lastName = [self.searchedUser objectForKey:@"lastName"];

        self.photoFile = [self.searchedUser objectForKey:@"profileImage"];
        [self.photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 self.profileImage.image = [UIImage imageWithData:data];
                 self.profileImageCropper.image = [UIImage imageNamed:@"ProfileImageCircle"];

             }
         }];
        self.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        self.navigationItem.title = [self.searchedUser username];

        self.query = [PFQuery queryWithClassName:@"Photo"];
        //[self.query orderByDescending:@"createdAt"];
        [self.query whereKey:@"PhotoPoster" equalTo:self.searchedUser.objectId];
        //[self.query whereKey:@"owner" equalTo:currentUser.objectId];

        self.photosArray = [[[NSArray alloc]init]mutableCopy];
        self.photosArray = [[self.query findObjects]mutableCopy];
        [self.collectionView reloadData];

}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    self.profileImage.image = [UIImage imageNamed:@"profile-icon"];
    [self.photosArray removeAllObjects];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SearchedUserCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    PFObject *photo = self.photosArray[indexPath.row];

    PFFile *file = [photo objectForKey:@"PhotoZ"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             cell.imageView.image = [UIImage imageWithData:data];
         }
     }];

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosArray.count;
}

- (IBAction)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
