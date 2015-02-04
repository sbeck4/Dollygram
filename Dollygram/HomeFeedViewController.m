//
//  ViewController.m
//  InstagramFeed
//
//  Created by Gabriel Borri de Azevedo on 2/2/15.
//  Copyright (c) 2015 Gabriel Enterprises. All rights reserved.
//

#import "HomeFeedViewController.h"
#import <Parse/Parse.h>

@interface HomeFeedViewController () <UITableViewDataSource, UITableViewDelegate>

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    self.photo = self.photosArray[indexPath.row];

    self.photoFile = [self.photo objectForKey:@"Photo"];
    [self.photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             cell.imageView.image = [UIImage imageWithData:data];
         }
     }];

    cell.detailTextLabel.text = [self.photo objectForKey:@"PhotoDescription"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 505.0; // programatticly setting the cell's height to 505 pixels. Enough to display all info.
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

    NSString *photoPoster = [self.photo objectForKey:@"PhotoPoster"];
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

    headerViewImage.backgroundColor = [UIColor greenColor]; // color to be replaced with image
    headerViewImage.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"profile.png"]];


    headerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95]; // header transparency (translucidence)

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

- (IBAction)onLikeButtonTapped:(UIButton *)button // when photo liked to this...
{
}

- (IBAction)onCommentButtonTapped:(UIButton *)button // when comment button tapped do this...
{
}

@end
