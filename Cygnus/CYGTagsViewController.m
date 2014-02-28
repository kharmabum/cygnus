//
//  CYGTagsViewController.m
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGTagsViewController.h"
#import "CYGTagsView.h"

@interface CYGTagsViewController ()

@property (strong, nonatomic)  CYGTagsView *view;

@end

@implementation CYGTagsViewController

#pragma mark - UIViewController

- (void)loadView
{
    self.view = [[CYGTagsView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // https://github.com/davbeck/TURecipientBar
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
