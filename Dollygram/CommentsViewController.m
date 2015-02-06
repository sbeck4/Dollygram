//
//  CommentsViewController.m
//  InstagramFeed
//
//  Created by Gabriel Borri de Azevedo on 2/3/15.
//  Copyright (c) 2015 Gabriel Enterprises. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentTableViewCell.h"

@interface CommentsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *commentsTextField;
@property NSMutableArray *commentsArray;
@property PFObject *activity;
@property NSString *activityId;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 70.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.commentsArray = [[NSMutableArray alloc]init];

}

- (IBAction)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
    self.tableView.hidden = FALSE;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.activityId = [self.photo objectForKey:@"PhotoActivityId"];

    if (self.activityId)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
        [query whereKey:@"ActivityId" equalTo:self.activityId];
        self.commentsArray = [[query findObjects]mutableCopy];
        [self.tableView reloadData];
    }

    self.tableView.hidden = TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];

    [comment setValue:textField.text forKey:@"CommentText"];
    [comment setValue:[PFUser currentUser].username forKey:@"CommentPosterId"];
    [comment setValue:self.activityId forKey:@"ActivityId"];

    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         [self.commentsArray addObject:comment];
         [self.tableView reloadData];
         textField.text = @"";
     }];

    [textField resignFirstResponder];

    return YES;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFObject *com = self.commentsArray[indexPath.row];
    cell.commentLabel.text = [com objectForKey:@"CommentText"];
    NSString *commentPoster =  [com objectForKey:@"CommentPosterId"];
    cell.usernameLabel.text = commentPoster;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentsArray.count;
}

@end
