//
//  ViewController.m
//  InstagramFeed
//
//  Created by Gabriel Borri de Azevedo on 2/2/15.
//  Copyright (c) 2015 Gabriel Enterprises. All rights reserved.
//

#import "HomeFeedViewController.h"
#import "CustomTableViewCell.h"
#import <Parse/Parse.h>

@interface HomeFeedViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property PFObject *photo;
@property NSArray *photosArray;
@property PFFile *photoFile;
@property PFQuery *query;

@property NSInteger numberOfImagesToLoad; // numbers of photos displayed based on Parse count

//@property BOOL isHidden;
//
//@property UIView *commentView;

@end

@implementation HomeFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    self.query = [PFQuery queryWithClassName:@"Photo"];
    [self.query orderByDescending:@"createdAt"];
    //[query whereKey:@"owner" equalTo:currentUser];

    self.photosArray = [[NSArray alloc]init];
    self.photosArray = [self.query findObjects];
    self.numberOfImagesToLoad = 10; //provisorily setting 10 photos to display
}

- (void) viewWillAppear:(BOOL)animated
{

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create a cell with the properties set below.
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

        PFObject *photo = self.photosArray[indexPath.section];

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

        cell.descriptionLabel.text = [photo objectForKey:@"PhotoDescription"];

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 505.0; // programatticly setting the cell's height to 505 pixels. Big enough to display all info.
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
    //View (Label) that contains the username
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 3.0, 270.0, 40.0)];
    //View to display that 1pxl line (separator)
    UIView *headerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0, 49.0, self.view.frame.size.width, 1.0)];

    NSString *photoPoster = [self.photosArray[section] objectForKey:@"PhotoPoster"];
//    PFQuery *query2 = [PFQuery queryWithClassName:@"User"];//depricated
    PFQuery *query2 = [PFUser query];
    [query2 whereKey:@"objectId" equalTo:photoPoster];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"objects returned: %@", objects);
        PFUser *photoUser = [objects firstObject];
        usernameLabel.text = photoUser.username;
    }];

     // placeholder text to the user name
    usernameLabel.textColor = [UIColor blueColor]; // placeholder text color

    headerViewImage.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"profile.png"]];

    headerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95]; // header transparency (translucent)

    headerSeparator.backgroundColor = [UIColor grayColor]; // separator color

    // adding subview to main view
    [headerView addSubview:headerViewImage];
    [headerView addSubview:usernameLabel];
    [headerView addSubview:headerSeparator];

    // return the main view to display in the header
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0; // programmatically setting the header size
}



- (IBAction)onPictureTapped:(UITapGestureRecognizer *)sender
{
    CGPoint point = sender.view.center;
    NSIndexPath *path =
    [self animateLike];
}



- (void)animateLike
{
    CustomTableViewCell *cell = [CustomTableViewCell new];
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
