//
//  ViewController.m
//  testForSearchFeature
//
//  Created by Evan Vandenberg on 2/3/15.
//  Copyright (c) 2015 Evan Vandenberg. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchCollectionViewCell.h"
#import "SearchedUserViewController.h"
#import "PhotoViewerViewController.h"
#import <Parse/Parse.h>

@interface SearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *peopleView;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftTableViewConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *peopleTableView;
@property NSArray *photosArray;
@property NSArray *usersArray;
@property PFQuery *query;
@property PFQuery *query2;
@property PFUser *selectedUser;
@property NSInteger photoIndexPath;



@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //PFUser *currentUser = [PFUser currentUser];
    self.query = [PFQuery queryWithClassName:@"Photo"];
    [self.query orderByDescending:@"createdAt"];
    //[query whereKey:@"owner" equalTo:currentUser];

    self.photosArray = [[NSArray alloc]init];
    self.photosArray = [self.query findObjects];

    self.query2 = [PFUser query];
    self.usersArray = [[NSArray alloc]init];
    self.usersArray = [self.query2 findObjects];

    // Do any additional setup after loading the view, typically from a nib.

    self.leftTableViewConstraint.constant = 380;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.photoIndexPath = indexPath.row;
    [self performSegueWithIdentifier:@"photoViewSegue" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFUser *user = self.usersArray[indexPath.row];

    cell.textLabel.text = user.username;

    PFFile *file;
    file = [user objectForKey:@"profileImage"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             cell.imageView.image  = [UIImage imageWithData:data];
         }
     }];

    


    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.usersArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedUser = self.usersArray[indexPath.row];
    [self performSegueWithIdentifier:@"showUserPage" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showUserPage"])
    {
        SearchedUserViewController *searchedVC = segue.destinationViewController;
        searchedVC.searchedUser = self.selectedUser;
    }
    else if ([segue.identifier isEqualToString:@"photoViewSegue"])
    {
        PhotoViewerViewController *photoVC = segue.destinationViewController;
       photoVC.photosUser = self.photosArray[self.photoIndexPath];
    }
}

- (IBAction)segementButtonPressed:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        self.leftTableViewConstraint.constant = 380;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
    }

    else
    {
        self.leftTableViewConstraint.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    }
}

@end
