//
//  LoginViewController.m
//  Dollygram
//
//  Created by Shannon Beck on 2/2/15.
//  Copyright (c) 2015 Shannon Beck. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}

- (IBAction)signUpButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"signUp" sender:self];

}

- (IBAction)loginButtonTapped:(id)sender
{
    NSString *username = [self.usernameField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *password = [self.passwordField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Make sure you enter a username and password!"
                                                           delegate:Nil cancelButtonTitle:@"Okey"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                    message:[error.userInfo objectForKey:@"error"]
                                                                   delegate:Nil cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
            } else
            {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //[self.tabBarController setSelectedIndex:0];
}

@end
