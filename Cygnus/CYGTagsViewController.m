//
//  CYGTagsViewController.m
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGTagsViewController.h"
#import "CYGMainViewController.h"
#import "CYGTagsView.h"
#import "CYGTokenInputField.h"

@interface CYGTagsViewController ()

@property (strong, nonatomic)  CYGTagsView *view;


@end

@implementation CYGTagsViewController

#pragma mark - Actions, Gestures, Notification Handlers


#pragma mark - UIViewController

- (void)loadView
{
    self.view = [[CYGTagsView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // https://github.com/davbeck/TURecipientBar
    
    
    // Initialize tokenField with current tags
    for (NSString *tag in self.tags) {
        [self.view.tokenInputField addTokenWithText:tag];
    }
    
    // Push all changes from tokenField to self.tags model
    RACSignal *tokenChangeSignal = [self.view.tokenInputField rac_valuesAndChangesForKeyPath:@keypath(self.view.tokenInputField, tokens)
                                                                                     options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                                                                    observer:nil];
    @weakify(self)
    [tokenChangeSignal subscribeNext:^(RACTuple *x){
        @strongify(self);
        NSDictionary *changeDictionary = x.second;
        int changeKey = [changeDictionary[NSKeyValueChangeKindKey] intValue];
        switch (changeKey) {
            case NSKeyValueChangeInsertion:
            {
                for (NSString *token in changeDictionary[NSKeyValueChangeNewKey]) {
                    [self.tags addObject:token];
                }
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                for (NSString *tag in changeDictionary[NSKeyValueChangeOldKey]) {
                    NSUInteger index = [self.tags indexOfObject:tag];
                    [self.tags removeObjectAtIndex:index]; //only want to remove one copy if multiple
                }
                break;
            }
        }
    }];
    
    [self.view.tokenInputField.rac_didEndEditingSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.mainViewController refreshOnMapViewRegion];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    self.view.tokenInputField.
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

    }
    return self;
}

#pragma mark - NSObject

- (void)dealloc
{
}


@end
