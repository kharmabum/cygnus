//
//  CYGPointCreationViewController.h
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYGPoint, CYGPointAnnotation, CYGMainViewController;

@interface CYGPointCreationViewController : UIViewController

@property (strong, nonatomic)  CYGMainViewController *mainViewController;
@property (strong, nonatomic)  CYGPoint *point;

@end
