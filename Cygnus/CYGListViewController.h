//
//  CYGListViewController.h
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYGMainViewController;

@interface CYGListViewController : UIViewController

@property (strong, nonatomic)  CYGMainViewController *mainViewController;
@property (strong, nonatomic)  NSMutableArray *annotations;


@end
