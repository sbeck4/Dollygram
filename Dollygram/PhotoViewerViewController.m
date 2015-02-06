//
//  PhotoViewerViewController.m
//  Dollygram
//
//  Created by Shannon Beck on 2/5/15.
//  Copyright (c) 2015 Shannon Beck. All rights reserved.
//

#import "PhotoViewerViewController.h"
#import "PhotoViewerTableViewCell.h"
#import <Parse/Parse.h>

@interface PhotoViewerViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property PFObject *photo;
@property NSMutableArray *photosArray;
@property PFFile *photoFile;
@property PFQuery *query;
@property NSMutableArray *likesArray;
@property NSArray *tempLikeArray;

@property NSInteger numberOfImagesToLoad; // numbers of photos displayed based on Parse count

@end

@implementation PhotoViewerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.query = [PFQuery queryWithClassName:@"Photo"];
    [self.query orderByDescending:@"createdAt"];
    //[query whereKey:@"owner" equalTo:currentUser];

    self.photosArray = [[NSMutableArray alloc]init];
    [self.photosArray addObject:self.photosUser];

    NSString *photoPosterId = [self.photosUser objectForKey:@"PhotoPoster"];
    PFQuery *query2 = [PFUser query];
    [query2 whereKey:@"owner" equalTo:photoPosterId];

    self.numberOfImagesToLoad = 1;

    [self.tableView reloadData];


}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create a cell with the properties set below.
    PhotoViewerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFObject *photo = self.photosArray[indexPath.section];

    NSString *activityId = [photo objectForKey:@"PhotoActivityId"];

    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    [query whereKey:@"ActivityId" equalTo:activityId];


    self.likesArray = [[query findObjects]mutableCopy];


    PFFile *file = [photo objectForKey:@"PhotoZ"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             cell.photoImageView.image = [UIImage imageWithData:data];
             //[self animateLike];
             //cell.heartImage.image = [UIImage imageNamed:@"hearts-50"];
             //cell.photoImageView.backgroundColor = [UIColor grayColor];
         }
     }];

    // PFQuery *query2 = [PFQuery queryWithClassName:@"Like"];
    [query whereKey:@"LikingUserId" equalTo:[PFUser currentUser].objectId];
    self.tempLikeArray = [query findObjects];

    cell.likesLabel.text = [NSString stringWithFormat:@"❤️ %lu", (unsigned long)self.likesArray.count];
    [cell.commentButton addTarget:self action:@selector(onCommentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    cell.commentButton.tag = indexPath.section;



    [cell.likeButton addTarget:self action:@selector(onLikeTapped:) forControlEvents:UIControlEventTouchUpInside];
    cell.likeButton.tag = indexPath.section;
    cell.descriptionLabel.text = [NSString stringWithFormat:@"💬 %@",[photo objectForKey:@"PhotoDescription"]];


    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    tapGesture.numberOfTapsRequired = 2; //turning it into a double tap
    cell.photoImageView.tag = indexPath.section;
    [cell.photoImageView addGestureRecognizer:tapGesture];//Adding tap to imageView (Photo)
    return cell;
}

-(void)onTapGesture:(UITapGestureRecognizer *)gesture
{
    if (self.tempLikeArray.count == 0)
    {
        [self animateHeartUsingSection:gesture.view.tag]; //the photo was double tapped, call animation
        NSLog(@"like button at section %li tapped", gesture.view.tag);
    }
}

-(void)onLikeTapped:(UIButton *)button
{
    //[self animateHeartUsingSection:button.tag]; //the photo was liked, call animation
    NSLog(@"like button at section %li tapped", button.tag);
}

-(void)animateHeartUsingSection:(NSInteger)section // animation for heart icon by Evan Vandenberg
{
    PFObject *photo = self.photosArray[section];
    NSString *activityId = [photo objectForKey:@"PhotoActivityId"];

    PFObject *like = [PFObject objectWithClassName:@"Like"];

    [like setValue:[PFUser currentUser].objectId forKey:@"LikingUserId"];
    [like setValue:activityId forKey:@"ActivityId"];

    [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         [self.likesArray addObject:like];
         [self.tableView reloadData];
     }];

    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:section];
    PhotoViewerTableViewCell *cell = (PhotoViewerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath2];
    cell.heartImage.image = [UIImage imageNamed:@"hearts-50"];
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        cell.heartImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
        cell.heartImage.alpha = 1.0;
    }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                             cell.heartImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                                                  cell.heartImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                                  cell.heartImage.alpha = 0.0;
                                              }
                                                               completion:^(BOOL finished) {
                                                                   cell.heartImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                               }];
                                          }];
                     }];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 420.0; // programatticly setting the cell's height to 505 pixels. Big enough to display all info.
}

//To use custom headers (Profile photo and username) we have to create section.
//There will be a header for each section (photo), so we can have that "pushing up" effect.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1; // one header per photo
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.photosArray.count; // How many photos will be displayed ?
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Here we're going to create a custom view in the header to display some information

    // We'll have a view the size of the header to contain all others subviews
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 50.0)];
    //View to display the user profile photo
    UIView *headerViewImage = [[UIView alloc] initWithFrame:CGRectMake(5.0, 5.0, 40.0, 40.0)];
    //View (button) that contains the username
    UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    usernameButton.tag = section;
    [usernameButton addTarget:self action:@selector(onHeaderUsernameTapped:) forControlEvents:UIControlEventTouchUpInside];
    //View to display that 1pxl line (separator)
    UIView *headerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0, 49.0, self.view.frame.size.width, 1.0)];

    usernameButton.tintColor = [UIColor blueColor];
    usernameButton.frame = CGRectMake(50.0, 3.0, 270.0, 40.0);
    usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    NSString *photoPoster = [self.photosArray[section] objectForKey:@"PhotoPoster"];
    //    PFQuery *query2 = [PFQuery queryWithClassName:@"User"];//depricated
    PFQuery *query2 = [PFUser query];
    [query2 whereKey:@"objectId" equalTo:photoPoster];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"objects returned: %@", objects);
        PFUser *photoUser = [objects firstObject];
        [usernameButton setTitle:photoUser.username forState:UIControlStateNormal];
    }];

    UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom]; // PLUS

    [followButton addTarget:self action:@selector(onFollowButtonTapped:)forControlEvents:UIControlEventTouchUpInside];  // PLUS



    followButton.frame = CGRectMake(290.0, 8.0, 80.0, 30.0); //PLUS

    [followButton setTitle:@"+ Follow" forState:UIControlStateNormal];

    [followButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    followButton.backgroundColor = [UIColor clearColor];

    [[followButton layer] setBorderWidth:1.0f];

    followButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];

    [[followButton layer] setBorderColor:[UIColor blueColor].CGColor];

    followButton.tag = section; // PLUS


    headerViewImage.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"profile.png"]];

    headerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95]; // header transparency (translucent)

    headerSeparator.backgroundColor = [UIColor grayColor]; // separator color

    // adding subview to main view
    [headerView addSubview:headerViewImage];
    [headerView addSubview:usernameButton];
    [headerView addSubview:headerSeparator];
    [headerView addSubview:followButton];

    // return the main view to display in the header
    return headerView;
}

- (void)onFollowButtonTapped:(UIButton *)button // when comment button tapped do this...

{
        PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"CurrentUserId" equalTo:[PFUser currentUser].objectId];
        NSArray *tempArray = [query findObjects];
        PFObject *follow = tempArray.firstObject;

        PFObject *following = [PFObject objectWithClassName:@"Following"];
        [following setValue:self.searchedUser.objectId forKey:@"FollowedUser"];


        [following saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             [follow setObject:following forKey:@"Following"];

             [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {

              }];

         }];

        PFQuery *query2 = [PFQuery queryWithClassName:@"Follow"];
        [query2 whereKey:@"CurrentUserId" equalTo:self.searchedUser.objectId];
        NSArray *tempArray2 = [query2 findObjects];
        PFObject *follow2 = tempArray2.firstObject;

        PFObject *follower = [PFObject objectWithClassName:@"Follower"];
        [follower setValue:[PFUser currentUser] forKey:@"FollowingUser"];

        [follower saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             [follow2 setObject:follower forKey:@"Follower"];
             
             [follow2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  
              }];
             
         }];
}

- (IBAction)onHeaderUsernameTapped:(UIButton *)button // when photo liked to this...
{
    NSLog(@"username at section %li tapped", button.tag);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0; // programmatically setting the header size
}

- (void)onCommentButtonTapped:(UIButton *)button // when comment button tapped do this...
{
    NSLog(@"Commented");
    NSLog(@"%ld",(long)button.tag);
}

//- (IBAction)onPictureTapped:(UITapGestureRecognizer *)sender
//{
//    CGPoint point = [sender locationInView:self.view];
//    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:point];
//    NSIndexPath *path2 = [NSIndexPath indexPathForRow:0 inSection:path.section];
//    UITableViewCell *pCell = [self.tableView cellForRowAtIndexPath:path2];
//    CustomTableViewCell *cell = (CustomTableViewCell *)pCell;
//    [self animateLike:cell];
//}



- (void)animateLike:(UIButton *)button
{
    PFObject *photo = self.photosArray[button.tag];
    NSString *activityId = [photo objectForKey:@"PhotoActivityId"];

    PFObject *like = [PFObject objectWithClassName:@"Like"];

    [like setValue:[PFUser currentUser].objectId forKey:@"LikingUserId"];
    [like setValue:activityId forKey:@"ActivityId"];

    [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         [self.likesArray addObject:like];
         [self.tableView reloadData];
     }];



    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:button.tag];
    PhotoViewerTableViewCell *cell = (PhotoViewerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.heartImage.image = [UIImage imageNamed:@"hearts-50"];
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        cell.heartImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
        cell.heartImage.alpha = 1.0;
    }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                             cell.heartImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                                                  cell.heartImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                                  cell.heartImage.alpha = 0.0;
                                              }
                                                               completion:^(BOOL finished) {
                                                                   cell.heartImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                               }];
                                          }];
                     }];

}




@end

