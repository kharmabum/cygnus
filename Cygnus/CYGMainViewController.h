//
//  CYGMapViewController.h
//  Cygnus
//
//  Created by IO on 2/9/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@import Foundation;
@import UIKit;

@class CYGListViewController, CYGTagsViewController, CYGPointCreationViewController;

@interface CYGMainViewController : UIViewController

@property (strong, nonatomic, readonly) CYGListViewController *listViewController;
@property (strong, nonatomic, readonly) CYGTagsViewController *tagsViewController;
@property (strong, nonatomic, readonly) CYGPointCreationViewController *pointCreationViewController;

- (void)switchToListView;
- (void)switchToTagView;
- (void)switchToPointCreationView;

- (void)switchToListViewWithCompletion:(void (^)(void))completion;
- (void)switchToTagViewWithCompletion:(void (^)(void))completion;
- (void)switchToPointCreationViewWithCompletion:(void (^)(void))completion;


@end
