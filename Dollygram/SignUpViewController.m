//
//  SignUpViewController.m
//  Dollygram
//
//  Created by Shannon Beck on 2/2/15.
//  Copyright (c) 2015 Shannon Beck. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)signUpButtonTapped:(id)sender
{
    NSString *username = [self.usernameField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *password = [self.passwordField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *email = [self.emailField.text
                       stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *firstName = [self.firstNameField.text
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *lastName = [self.lastNameField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];


    if ([username length] == 0 || [password length] == 0 || [email length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Make sure you enter a username, password and an email!"
                                                           delegate:Nil cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        PFUser *newUser = [PFUser user];
        PFObject *follow = [PFObject objectWithClassName:@"Follow"];

        [newUser setUsername:username];
        [newUser setPassword:password];
        [newUser setEmail:email];
        newUser[@"firstName"] = firstName;
        newUser[@"lastName"] = lastName;

//        [follow setValue:[PFUser currentUser].objectId forKey:@"CurrentUserId"];

        [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            [newUser setValue:follow.objectId forKey:@"FollowObjectId"];

                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (error)
                     {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                         message:[error.userInfo objectForKey:@"error"]
                                                                        delegate:Nil cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                         [alertView show];
                     }
                     else
                     {
                         [follow setValue:[PFUser currentUser].objectId forKey:@"CurrentUserId"];

                         [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                         }];

                         self.usernameField.text = nil;
                         self.emailField.text = nil;
                         self.passwordField.text = nil;
                         [self dismissViewControllerAnimated:NO completion:nil];
                     }
             }];
        }];
    }

    
}

@end
