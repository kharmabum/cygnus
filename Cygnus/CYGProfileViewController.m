//
//  CYGProfileViewController.m
//  Cygnus
//
//  Created by IO on 2/9/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGProfileViewController.h"
#import "CYGUser.h"

@interface CYGProfileViewController ()

@end

@implementation CYGProfileViewController

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    if (user.isNew) {
        NSLog(@"User signed up and logged in with Twitter!");
    } else {
        NSLog(@"User logged in with Twitter!");
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"didFailToLogin");
    
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    NSLog(@"didCancelLogin");
    
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        logInViewController.delegate = self;
        logInViewController.fields = PFLogInFieldsTwitter | PFLogInFieldsDismissButton;
        logInViewController.logInView.logo = nil;
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                        image:[UIImage imageNamed:@"users-icon"]
                                                          tag:0];
    }
    return self;
}

@end
